# Shared helpers for scripts/lean and scripts/mcp-lean-lsp. Source it; do not execute it.
# shellcheck shell=bash

LP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

# Per-machine overrides (git-ignored), e.g. LEAN_REMOTE_HOST=bob2
# shellcheck disable=SC1091
[ -f "$LP_ROOT/scripts/local.env" ] && . "$LP_ROOT/scripts/local.env"

LEAN_REMOTE_HOST="${LEAN_REMOTE_HOST:-bob}"
# Mirror directory on the build server, relative to the remote home directory (or absolute).
# One mirror per client machine so that two machines never overwrite each other's working tree.
LEAN_REMOTE_DIR="${LEAN_REMOTE_DIR:-disk2/lean-proofs/mirror-$(hostname -s)}"

# How Lean is run on this machine: `native` (elan installed on the host) or `podman` (inside the
# container from scripts/container/Containerfile; nothing installed on the host).
# Default: podman on the build server, native elsewhere.
if [ -z "${LEAN_RUNNER:-}" ]; then
  if [ "$(hostname -s)" = "$LEAN_REMOTE_HOST" ]; then LEAN_RUNNER=podman; else LEAN_RUNNER=native; fi
fi
# Podman runner: where toolchains and the Mathlib download cache are kept, and the memory cap.
LEAN_PODMAN_STATE="${LEAN_PODMAN_STATE:-$HOME/disk2/lean-proofs}"
LEAN_PODMAN_MEMORY="${LEAN_PODMAN_MEMORY:-128g}"

LEAN4_PLUGIN_ROOT="$LP_ROOT/vendor/lean4-skills/plugins/lean4"

# Put elan/lake and the lean4-skills helper wrappers on PATH.
lp_activate_env() {
  export PATH="${ELAN_HOME:-$HOME/.elan}/bin:$LEAN4_PLUGIN_ROOT/bin:$PATH"
  export LEAN4_PLUGIN_ROOT
  export LEAN4_SCRIPTS="$LEAN4_PLUGIN_ROOT/lib/scripts"
  export LEAN4_REFS="$LEAN4_PLUGIN_ROOT/skills/lean4/references"
  # The lean4-skills cycle tracker (used by /autoprove) records its session in an env file that
  # the host must re-source before every command; Claude Code does that via CLAUDE_ENV_FILE,
  # OpenCode does not, so scripts/lean does it here.
  if [ -d "$LP_ROOT/.lake" ]; then
    export LEAN4_ENV_FILE="$LP_ROOT/.lake/lean4-skills-session.env"
    # shellcheck disable=SC1090
    [ -f "$LEAN4_ENV_FILE" ] && . "$LEAN4_ENV_FILE"
  fi
}

# True when this checkout has a usable local Lean build (Mathlib oleans downloaded).
lp_env_ready() {
  [ -f "$LP_ROOT/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib.olean" ]
}

# True when we are running on the build server itself.
lp_on_server() {
  [ "$(hostname -s)" = "$LEAN_REMOTE_HOST" ]
}

lp_die() { echo "${LP_PROG:-scripts/lean}: $*" >&2; exit 2; }

# Prints the container image tag; builds the image first if this Containerfile version is new.
lp_ensure_image() {
  local cf="$LP_ROOT/scripts/container/Containerfile" tag
  tag="localhost/lean-proofs-env:$(sha256sum "$cf" | cut -c1-12)"
  if ! podman image exists "$tag"; then
    echo "[lean-proofs] building container image $tag (one-time, ~2 min)" >&2
    podman build -t "$tag" -f "$cf" "$LP_ROOT/scripts/container" >&2 || return 1
  fi
  printf '%s\n' "$tag"
}

# lp_podman_run [extra podman options...] -- COMMAND [ARGS...]
# Runs COMMAND in the container with this checkout at /work, shared toolchains and caches, and
# scripts/lean configured to run natively inside.
lp_podman_run() {
  local opts=() image tty=()
  while [ $# -gt 0 ] && [ "$1" != -- ]; do opts+=("$1"); shift; done
  [ "${1:-}" = -- ] && shift
  command -v podman >/dev/null 2>&1 || lp_die "LEAN_RUNNER=podman but podman is not installed"
  image="$(lp_ensure_image)" || lp_die "building the container image failed"
  mkdir -p "$LEAN_PODMAN_STATE/elan-toolchains" "$LEAN_PODMAN_STATE/cache"
  [ -t 0 ] && [ -t 1 ] && tty=(-it)
  podman run --rm ${tty[@]+"${tty[@]}"} --memory "$LEAN_PODMAN_MEMORY" \
    -v "$LP_ROOT:/work" -w /work \
    -v "$LEAN_PODMAN_STATE/elan-toolchains:/opt/elan/toolchains" \
    -v "$LEAN_PODMAN_STATE/cache:/cache" \
    -e LEAN_BACKEND=local -e LEAN_RUNNER=native -e LEAN_IN_CONTAINER=1 \
    ${opts[@]+"${opts[@]}"} "$image" "$@"
}
