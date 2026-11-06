# CLAUDE.md: guidance for Claude as overseer of this repository

OpenCode proving agents read `AGENTS.md` and ignore this file, which OpenCode loads only when
there is no `AGENTS.md`.

## Your role

You are the **overseer and maintainer**, usually not the prover. Your jobs:
- maintain the repository structure and tooling (`scripts/`, the container, `opencode.json`,
  `.opencode/commands/`, docs), and set up machines;
- help the user **draft statements** (formalization), which the user reviews;
- **manage the OpenCode proving agents** on the laptop and on bob: start them, check their
  progress, review their commits, hand them statements, and improve `AGENTS.md` when they
  misbehave.

The proving itself is done by OpenCode agents following `AGENTS.md`. Read `AGENTS.md` before
changing anything they depend on, and keep `AGENTS.md`, `README.md`, the slash commands and the
scripts consistent with each other. If you are asked to prove or formalize something yourself,
follow `AGENTS.md` sections 4–6: statements are fixed, no `sorry` or axioms, and keep
`PROGRESS.md` up to date.

## The user's rules

- **Statements are the user's specification.** Draft them for review; never silently change
  existing ones.
- **Git:** the user commits setup changes and pushes to GitHub themselves. Do not `git push` to
  GitHub, not even a push you expect to fail; the auto-mode classifier blocks it anyway. Ask
  before committing. Agents only commit, using the prefixes `prove(<Project>): …` and
  `state(<Project>): …`. The repo (TheGreatfpmK/lean-proofs) is public.
- **Heavy compute and large data go to bob.** Use `ssh bob` with `~/disk2`, never its home
  directory. Up to 128 GB RAM and 64 cores. **Nothing can be installed on bob's host**:
  everything runs in rootless podman (`scripts/container/Containerfile`). Do not run installers
  (`curl … | sh`) on bob's host; the classifier blocks that too.
- **The laptop disk is nearly full** (WSL on C:, about 12 GB free after setup). Avoid new large
  local data. Ask before deleting anything not created in the current session.
- Projects live in `LeanProofs/<Project>/` and may import each other. Shared lemmas go in
  `LeanProofs/Common/`.

## How it fits together

- **Lean:** `lakefile.toml` requires only `pgcl` (Aurora, github.com/aurora-dtu/theory).
  Mathlib comes in transitively at the revision Aurora pins. `lean-toolchain` must equal
  Aurora's, currently `v4.30.0-rc2`. Exact revisions are in `lake-manifest.json`; commit it.
  The library is built through `globs = ["LeanProofs.*"]`, so new files need no root import.
- **`scripts/lean`** is the single entry point for Lean (`check`, `axioms`, `build`, `run`,
  `sorries`, `setup`, `shell`, `where`).
  - *Backend:* `local` if this checkout has `.lake` with Mathlib, otherwise `remote`. Remote
    rsyncs the tree to `bob:~/disk2/lean-proofs/mirror-<host>` and runs `scripts/lean` there.
    `build` prefers remote.
  - *Runner:* `native`, or `podman`, which is the default on bob.
  - *Settings:* `LEAN_BACKEND`, `LEAN_RUNNER`, `LEAN_REMOTE_HOST`/`DIR`, `LEAN_PODMAN_STATE`,
    `LEAN_PODMAN_MEMORY`. Per-machine values go in `scripts/local.env` (git-ignored).
  - Shared helpers live in `scripts/lib.sh`.
- **`scripts/agent`** runs OpenCode on bob in tmux, inside the same container.
  - The clone is `~/disk2/lean-proofs/agent`, configured with
    `receive.denyCurrentBranch=updateInstead`. The laptop's git remote `bob` points at it.
  - Statements go in with `git push bob main` (only while the agent's tree is clean). Results
    come out with `git pull bob main`.
  - API key: `~/disk2/lean-proofs/agent.env` (mode 600, written by `scripts/agent key`).
  - OpenCode state: `~/disk2/lean-proofs/agent-home`, mounted as `/root`.
  - Commands: `init`, `key`, `start [-d]`, `attach`, `stop`, `restart [-d]`, `status`,
    `exec CMD`, `shell`.
  - The agent's container is named `lean-agent-<session>`, and `stop` waits for it to exit.
    The tmux command on bob does not inherit the laptop's environment, so `start` passes
    `LEAN_AGENT_SESSION`/`LEAN_AGENT_ENV` explicitly. Without that, a test session once got the
    default name, and `--replace` could have killed the real agent.
  - `LEAN_AGENT_DIR`/`LEAN_AGENT_SESSION` select another clone or session (parallel agents,
    tests).
- **Container image:** tagged `localhost/lean-proofs-env:<hash of Containerfile>` and rebuilt
  automatically when the Containerfile changes. Pinned: OpenCode 1.18.16 (keep equal to the
  laptop's `opencode --version`), uv 0.13.4, lean-lsp-mcp 0.33.0. Toolchains and caches are
  bind-mounted from `~/disk2/lean-proofs/{elan-toolchains,cache}`.
- **`opencode.json`:**
  - provider `ostrava`, with the key from `{env:OSTRAVA_API_KEY}`;
  - `instructions: docs/aurora.md`;
  - `skills.paths` pointing at the `vendor/lean4-skills` submodule;
  - MCP `lean-lsp` via `scripts/mcp-lean-lsp`, which refuses to start without a local build,
    because `lake serve` would otherwise compile Mathlib;
  - `permission.bash` denies direct `lake`/`lean`/`elan`.
- **`.opencode/commands/`:** `/prove`, `/autoprove`, `/formalize`, `/disprove`, `/checkpoint`,
  `/status`. These are thin wrappers around `vendor/lean4-skills/plugins/lean4/commands/*.md`
  plus the rules in `AGENTS.md`.
- **`LeanProofs/Example/`** is both the layout example and the smoke test, so keep it compiling.
  It uses Aurora's `Paper.Syntax` (`Section n, Theorem m: term`) for the paper index.

## Lessons learned (do not repeat these mistakes)

- **Aurora does not compile on newer Lean/Mathlib.** It was tried with v4.33.0-rc1, giving 38
  errors in base files such as `MDP/Basic` (`DFunLike.coe_injective'` was renamed),
  `MDP/Optimization` and `PGCL/KInduction`. Only bump Lean or Mathlib together with Aurora:
  `scripts/lean run lake update pgcl`, then copy Aurora's `lean-toolchain` (see README,
  "Maintenance").
- If you ever require Mathlib directly next to `pgcl`, it must be the **last** `[[require]]`.
  Lake lets the later requirement's transitive versions (batteries, aesop, …) win.
- Aurora is built with `autoImplicit` on; this repo has it off. Aurora lemmas have auto-bound
  implicits (for example `c`), so pass them by name. Bellman-operator results such as `MDP.Φ`
  need `[DecidableEq State]`.
- Lake replays dependency warnings. `scripts/lean` hides them (`hide_dependency_logs`); set
  `LEAN_CHECK_RAW=1` to see everything. Aurora's `lean-toolchain` has no trailing newline, so
  compare trimmed contents.
- **OpenCode 1.18 config:**
  - `permission` is singular, an object per tool, and the last matching rule wins;
  - `skills` takes `{paths: [...]}`;
  - `mcp.<name>` uses `{type: "local", command: [...]}`.
  Validate with `opencode debug config`, `opencode debug skill`, `opencode mcp list` and
  `opencode debug agent build`. Its built-in `customize-opencode` skill (`opencode debug skill`)
  documents the schema of the installed version; the website can lag behind.
- In a fresh OpenCode home (on bob), the default model is OpenCode Zen's "Big Pickle". Choose
  an ostrava model with `/models` (remembered in `agent-home`), or set `"model"` in
  `opencode.json` once the user has picked one.
- On the laptop, OpenCode also loads `~/.claude/CLAUDE.md` and `~/.claude/skills`. To disable
  that, set `OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1` and `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1`.
- Timings: a local `check` takes about 8 s, plus 1.5–2 s for a remote round trip. A fresh
  mirror or agent clone needs about 3–5 min to build Aurora. Mathlib comes from the cache in
  `~/disk2/lean-proofs/cache` and is shared.
- The `test/` project next door gave its Mathlib checkout to this repo. It needs
  `lake exe cache get` before it works again.
- The lean-lsp MCP tool `lean_local_search` needs `ripgrep` (`rg`). The image includes it. On the
  laptop, the shell's `rg` is only a Claude Code function that subprocesses cannot see, so a real
  `rg` must be installed (`sudo apt install ripgrep`).
- OpenCode truncates large output (about 72 KB) when stdout is a pipe. Write to a file instead,
  for example `opencode export <id> > file`.
- The lean4 skill's `/autoprove` uses `lean4-skills-cycle-tracker`, whose session ID lives in an
  env file that the host must re-source before every command. Claude Code does that; OpenCode
  does not. `scripts/lean` therefore sources `.lake/lean4-skills-session.env` (`LEAN4_ENV_FILE`
  in `lib.sh`), and `scripts/lean run lean4-skills-cycle-tracker` keeps the tracker's state in
  `.lake/lean4-skills-tmp`, because `/tmp` does not survive fresh containers. Our
  `/autoprove` wrapper overrides the workflow's `fill:` commit messages with `prove(...)`.
- Keep the answers to test statements (which ones are false, reference proofs) out of the repo.
  Agents can read every file in it.

## Checklist after changing tooling

1. `bash -n scripts/*` and `uvx --from shellcheck-py shellcheck -x -S warning scripts/lean scripts/lib.sh scripts/agent scripts/mcp-lean-lsp`
2. `scripts/lean check LeanProofs/Example/Basic.lean LeanProofs/Example/Index.lean`, locally and
   with `LEAN_BACKEND=remote`. Then run `scripts/lean build`.
3. `opencode debug config`, `opencode debug skill` (must list `lean4`) and `opencode mcp list`.
4. After Containerfile or agent changes: `scripts/agent exec opencode mcp list`. Test
   `init`/`start -d`/`status`/`stop` and `git pull/push bob` against a **throwaway repo**, with
   `LEAN_AGENT_DIR=disk2/lean-proofs/agent-test LEAN_AGENT_SESSION=lean-agent-test`. Delete it
   afterwards.

## Managing the proving agents

- Status: run `scripts/agent status`, `git fetch bob` and `git log main..bob/main`. Read
  `LeanProofs/*/PROGRESS.md`; the session log says what was tried.
- Reviewing agent work: check that no statement changed, only proof bodies and new helpers
  (`git diff main bob/main -- LeanProofs`). Check axioms with `scripts/lean axioms FILE DECL`.
  Check the commit prefixes.
- Inspecting how an agent worked (tool calls, errors, tokens):
  1. `scripts/agent exec opencode session list`;
  2. `scripts/agent exec bash -c 'opencode export <id> > /work/Scratch/s.json'`;
  3. copy it with `ssh bob cat ~/disk2/lean-proofs/agent/Scratch/s.json`, then delete it there;
  4. summarize the `messages[].parts[]` entries with `type == "tool"`.
- When an agent misbehaves (loops, changes statements, runs `lake` directly, leaves the tree
  dirty), fix the cause in `AGENTS.md` or the commands rather than only the symptom.
- First end-to-end test (2026-11-06, `LeanProofs/AgentTest`, ostrava/kimi-k3.1-pro on bob):
  3/3 statements proved in 15 min with 59 tool calls, about 92k input and 7.5k output tokens.
  It followed `AGENTS.md` fully (skill, `scripts/lean`, MCP goals and multi-attempt, check,
  axioms, build, `PROGRESS.md`, one `prove(...)` commit, clean tree, report). The only problem
  was that `rg` was missing from the image, which is now fixed.
- First `/autoprove` test (2026-11-06, `AgentTest/Loop.lean`, kimi-k3.1-pro on bob): 49 min,
  108 tool calls, about 207k input and 19k output tokens.
  - It proved the two true loop bounds (Park induction; Kleene iteration).
  - It left the deliberately false statement unchanged and refuted it in a separate theorem.
  - The cycle tracker worked through `scripts/lean run`; commits used `prove(...)`; the tree
    was left clean.
  - Two issues, now addressed in `.opencode/commands/autoprove.md`: it wasted 3 cycles on the
    already-refuted target, and it added an unrequested "salvaged" variant.

## Open items

- The bob agent works end to end with a plain prompt. Not yet tested: `/autoprove` (the lean4
  skill's cycle-tracker protocol), a laptop agent session, and harder statements.
- The user chose ostrava/kimi-k3.1-pro on bob (stored in `agent-home`). `opencode.json` sets no
  default model yet. The push policy is to be refined; for now, agents commit and the user
  pushes.
- OpenCode's `serve`/`attach` (laptop interface for the bob agent) is untested.
- Unused Lean toolchains on the laptop (v4.32.0, v4.33.0-rc1, about 5.7 GB) and
  `~/.cache/mathlib` could be removed if the user agrees.
