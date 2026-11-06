# lean-proofs

Lean 4 formalizations for my research projects. They build on the
[AuRoRA theory](https://aurora-dtu.github.io/theory/) (MDPs, expected costs, pGCL, weakest
pre-expectations, HeyVL), on Mathlib, and on each other. I write the statements; proofs are
mostly developed by an AI agent ([OpenCode](https://opencode.ai)), using the
[lean4 skill](https://github.com/cameronfreer/lean4-skills).

- **`AGENTS.md`**: instructions for the proving agent. Read it to understand the conventions.
- **`CLAUDE.md`**: guidance for Claude Code as maintainer and overseer: setup decisions, lessons
  learned, and how to manage the agents.
- **`docs/aurora.md`**: cheat sheet for the Aurora library.
- **`LeanProofs/<Project>/`**: one folder per research project. Projects may import each other.
  `PROGRESS.md` there tracks the status of each statement.

## How it fits together

```
 laptop                                       bob (build server, 64 cores, /disk2)
 ──────                                       ─────────────────────────────────────
 git clone of this repo  ──scripts/lean──▶    ~/disk2/lean-proofs/mirror-<laptop>/
 opencode + AGENTS.md       rsync + ssh         runs inside a podman container
 .lake/ (optional local                         (nothing installed on the host)
   build: check/axioms/run)                   ~/disk2/lean-proofs/{elan-toolchains,cache}
          │
          └── git push/pull ──▶ GitHub ◀── any other machine
```

All Lean work goes through **`scripts/lean`** (`check`, `axioms`, `build`, `run`, `sorries`,
`setup`, `shell`, `where`; see `scripts/lean help`):
- If this checkout has a Lean build, `check`/`axioms`/`run` run locally.
- Otherwise the working tree is rsynced to a per-machine mirror on the build server and the
  command runs there.
- `build` (the whole project) always prefers the server.
- On the server, Lean runs in a rootless podman container (`scripts/container/Containerfile`:
  Ubuntu, git, curl, python3, elan). Toolchains, the Mathlib download cache and build output
  live under `~/disk2`.

Progress travels between machines through GitHub.

**Versions.** Lean `v4.30.0-rc2` and Mathlib exactly as pinned by Aurora (`lake-manifest.json`).
Aurora does not compile against newer Mathlib (tested with `v4.33.0-rc1`), so the Lean version
follows Aurora's.

## Setting up a machine

### 1. The build server

Nothing to install: only ssh access and rootless `podman` are needed. The first
`scripts/lean setup` from a client builds the image (~1 min, 226 MB), downloads the toolchain and
Mathlib cache into `~/disk2/lean-proofs/`, and builds Aurora (~10 min).

### 2. A client machine (laptop, desktop, …)

```bash
git clone --recurse-submodules https://github.com/TheGreatfpmK/lean-proofs.git
cd lean-proofs
scripts/lean where                                   # shows where Lean work will run
LEAN_BACKEND=remote scripts/lean setup               # once per client: prepares its mirror on bob
scripts/lean check LeanProofs/Example/Basic.lean     # smoke test
```

Requirements: `git`, `rsync`, `python3`, and `ssh bob` working without a password prompt.
For the agent: `opencode` and the API key it expects (`export OSTRAVA_API_KEY=...` in your shell
profile). The provider is configured in `opencode.json`.

**Local Lean build (recommended where disk allows, about 10 GB:** a 2.9 GB toolchain plus a 7 GB
Mathlib build). You need it for the VS Code Lean infoview and for the `lean-lsp` MCP server,
which gives the agent live goals. It also makes `check` faster, because there is no sync step.

```bash
LEAN_BACKEND=local scripts/lean setup     # needs elan installed locally
```

After that, `check`/`axioms`/`run` run locally automatically, while `build` still goes to bob.
The MCP server additionally needs [`uv`](https://docs.astral.sh/uv/). `~/.cache/mathlib` holds
compressed copies of the download (several GB). You can delete it after setup.

**Per-machine settings** go in `scripts/local.env` (git-ignored):

```bash
LEAN_REMOTE_HOST=bob                       # ssh host of the build server
LEAN_REMOTE_DIR=disk2/lean-proofs/mine     # mirror dir on the server (relative to ~)
# LEAN_BACKEND=local                       # force local / remote for every command
# LEAN_RUNNER=podman                       # run Lean in the container on this machine too
# LEAN_PODMAN_STATE=$HOME/disk2/lean-proofs  # container toolchains + Mathlib cache
# LEAN_PODMAN_MEMORY=128g                  # memory cap for the container
```

## Working with the agent

The agent can run in two places. Both use the same `AGENTS.md`, slash commands and lean4 skill.

**On the laptop**, interactively while you work:

```bash
cd lean-proofs && opencode
```

**On bob**, for long or unattended runs. It runs in tmux inside the Lean container, next to the
Lean build and the `lean-lsp` live-goal tools, and keeps running when the laptop is closed:

```bash
scripts/agent init       # once, after committing: agent clone on bob + git remote 'bob' (~5 min)
scripts/agent key        # once: copies $OSTRAVA_API_KEY to bob (~/disk2/lean-proofs/agent.env, mode 600)
scripts/agent start      # start or attach (Ctrl-b d detaches; `start -d` starts without attaching)
scripts/agent status     # running? recent commits, uncommitted changes
scripts/agent stop       # end the session; `scripts/agent start --continue` resumes it later
```

On first start, choose your model with `/models` (OpenCode remembers it in
`~/disk2/lean-proofs/agent-home`). Otherwise it uses OpenCode's built-in default.

The slash commands in `.opencode/commands/` wrap the lean4 skill's workflows:

| command | use |
|---|---|
| `/status` | summary of all projects (reads every `PROGRESS.md`) |
| `/formalize <item or text>` | draft Lean statements (proofs left as `sorry`) |
| `/prove <file or declaration>` | guided sorry-filling |
| `/autoprove <target> [budget]` | unattended proving, committing at checkpoints |
| `/disprove <statement>` | counterexample search |
| `/checkpoint` | full build, axiom check, update `PROGRESS.md`, commit |

Each research project is a folder `LeanProofs/<Project>/`. Projects can import each other, and
shared lemmas go in `LeanProofs/Common/`. The workflow:

1. **You formalize** the statements, by hand or with `/formalize` or another agent. Leave the
   proofs as `sorry`, list the statements in the project's `PROGRESS.md`, and commit them with
   `state(<Project>): …`.
2. **Hand them to the agent.** For the bob agent, run `git push bob main`. This updates its
   working tree, and only works while the tree is clean. The laptop agent already sees them.
3. **The agent proves:** `/autoprove LeanProofs/<Project>/Foo.lean`. It never changes a
   statement. If it thinks one is false or mis-formalized, it reports that instead.
4. **Collect and publish:** `git pull bob main` brings in the bob agent's commits. Read
   `PROGRESS.md`, then `git push` to GitHub yourself.

Agents only commit (`prove(<Project>): …` for proofs, `state(<Project>): …` for statements) and
never push. Publishing is always your step (`AGENTS.md` §7). The bob clone fetches nothing by
itself; everything reaches it through `git push bob`.

Parallel agents need their own working copy each. On a laptop, use `git worktree add ...` with
its own `LEAN_REMOTE_DIR`. On bob, use another `scripts/agent init` with a different
`LEAN_AGENT_DIR` and `LEAN_AGENT_SESSION`.

## Maintenance

**Updating Aurora** (the version is pinned in `lake-manifest.json`; Lean must match Aurora's):

```bash
scripts/lean run lake update pgcl
scripts/lean run cp .lake/packages/pgcl/lean-toolchain lean-toolchain   # Lean version must match Aurora's
scripts/lean setup && LEAN_BACKEND=remote scripts/lean setup         # local build + bob mirror
scripts/lean build                                                     # then fix any breakage
git add lake-manifest.json lean-toolchain && git commit -m "Bump Aurora"
```

**Updating the lean4 skill:**

```bash
git submodule update --remote vendor/lean4-skills
git add vendor/lean4-skills && git commit -m "Bump lean4-skills"
```

**Cleaning up the server:** everything lives under `~/disk2/lean-proofs/`:
- `mirror-<hostname>/`: one per client machine;
- `elan-toolchains/`: Lean versions;
- `cache/`: compressed Mathlib downloads;
- `agent/`, `agent-home/`, `agent.env`: the bob agent's clone, OpenCode state and API key;
- the `localhost/lean-proofs-env:*` podman images.

Everything except `agent/` (uncommitted agent work) and `agent.env` is a cache. Caches can be
deleted at any time and are recreated by `scripts/lean setup`.
