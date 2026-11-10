# Instructions for proving agents

This repository holds Lean 4 formalizations for several research projects. They build on the
**AuRoRA theory** (MDPs, expected costs, pGCL, weakest pre-expectations, HeyVL), on
**Mathlib**, and on each other.

**Division of labour.** The user formalizes the statements, sometimes with the help of another
agent. Your default job is to **prove** them: replace the `sorry`s in the statements you are
pointed at. Two other modes happen only when the user asks for them explicitly:

- **formalize**: turn informal statements into Lean statements (section 5);
- **disprove**: show that a statement is false (section 5).

Read this file completely before starting. Then read `docs/aurora.md`, which covers Aurora's
notation, definitions and main lemmas.

## 0. Non-negotiable rules

1. **Never run `lake`, `lean` or `elan` directly.** Every Lean-related command goes through
   `scripts/lean` (section 1). It decides whether the command runs on this machine or on the
   build server. Running `lake` on a machine without a Lean build starts downloading and
   compiling Mathlib for hours. Direct calls are blocked by `opencode.json`.
2. **Statements are the user's specification. Do not change them.** That includes hypotheses,
   types, quantifiers, names and the definitions they use. If you believe a statement is false
   or mis-formalized, follow section 5 instead of editing it.
3. **No cheating in finished work.** Forbidden: `sorry`, `admit`, new `axiom`s, `native_decide`
   or `decide +native`, `implemented_by`/`extern` tricks, `unsafe`, `set_option maxHeartbeats 0`,
   and anything that disables kernel checking. Allowed: raising heartbeats to a bounded value
   (for example `set_option maxHeartbeats 400000 in`) with a comment explaining why.
4. **Do not edit dependencies or project configuration:** `.lake/`, `lakefile.toml`,
   `lean-toolchain`, `lake-manifest.json` and `vendor/`. Do not turn `autoImplicit` back on. If
   Aurora or Mathlib lacks a lemma, prove it in this repo (section 3).
5. **Do not claim success without checking.** "Done" means the checks in section 6 pass, and
   you have seen their output in this session.
6. **Never `git push`.** Commit your work; the user reviews and pushes it (section 7).

## 1. Running Lean: `scripts/lean`

A machine either has a local Lean build (`.lake/` with Mathlib) or is a thin client. On a thin
client, `scripts/lean` rsyncs the working tree to the build server (`ssh bob`, 64 cores) and
runs the command there. If the environment variable `LEAN_AGENT=1` is set, you are already
running on the build server inside its Lean container, so everything is local. You use the same
commands in every case. `scripts/lean where` shows which case applies.

| Task | Command |
|---|---|
| Compile one or more files and see errors, warnings and `sorry`s | `scripts/lean check LeanProofs/X/Y.lean` |
| List the axioms behind theorems | `scripts/lean axioms LeanProofs/X/Y.lean [Full.Decl.Name ...]` |
| Build the whole project (checkpoints, final gate) | `scripts/lean build` |
| Run an arbitrary command in the Lean environment | `scripts/lean run <cmd> ...` |
| Experiment in a scratch file | write `Scratch/Try.lean`, then `scripts/lean check Scratch/Try.lean` |
| Count the remaining sorries (text scan, instant) | `scripts/lean sorries [path]` |

Notes:
- The first `check` of a session can take 10–60 s because it loads the Mathlib and Aurora
  `.olean` files. Rebuilding an imported project file costs extra. `setup` and `build` can take
  many minutes: give your shell tool a long timeout (for example 30 min) for those.
- `check` on a file under `LeanProofs/` runs `lake build +Module`, which first rebuilds the
  project files it imports. Files elsewhere (for example `Scratch/`) are run with
  `lake env lean`, after their `LeanProofs.*` imports are built.
- Put temporary files in `Scratch/`, never in `/tmp`. On a thin client only the repository is
  synced to the server. `Scratch/` is git-ignored.
- If `check` says the environment is missing, run `scripts/lean setup` once (long timeout).
- Use `#check`, `#print`, `#eval`, `exact?`, `apply?`, `rw?` and `simp?` inside a scratch file
  (or the file you are working on), then `check` it. Their results appear as info messages.

**Optional fast path, only on machines with a local build:** the `lean-lsp` MCP server gives
live goals (`lean_goal`), diagnostics (`lean_diagnostic_messages`), multi-tactic trials
(`lean_multi_attempt`) and search (`lean_local_search`, `lean_loogle`, `lean_leansearch`,
`lean_leanfinder`). It is configured in `opencode.json` and refuses to start on thin clients.
If its tools are available, prefer them for the inner loop. Always confirm with
`scripts/lean check` before declaring anything done.

## 2. The `lean4` skill

The `lean4` skill (from `vendor/lean4-skills`) contains detailed workflows and references:
tactic patterns, Mathlib search, `simp`, `grind`, calc chains, proof golfing and the
prove/autoprove cycle. Load it with the skill tool at the start of every Lean task, and open its
`references/*.md` files when they are relevant. The full workflow descriptions are in
`vendor/lean4-skills/plugins/lean4/commands/<workflow>.md` (`prove`, `autoprove`, `formalize`,
`autoformalize`, `disprove`, `checkpoint`, `review`, `golf`, `refactor`).

The skill was written for direct `lake` access. **Translate its commands as follows:**

| The skill says | Do this instead |
|---|---|
| `lake env lean F.lean`, `lake lean F.lean` | `scripts/lean check F.lean` |
| `lake build` | `scripts/lean build` |
| `lake exe cache get` | `scripts/lean setup` |
| `lean4-skills-check-axioms-inline F.lean` | `scripts/lean axioms F.lean` |
| `lean4-skills-sorry-analyzer ...` | `scripts/lean sorries [path]` |
| other `lean4-skills-*` helpers (search, find-usages, …) | `scripts/lean run lean4-skills-<name> ...` |
| `lean4-skills-cycle-tracker init/tick/status/stop` | `scripts/lean run lean4-skills-cycle-tracker ...` (the session is kept between calls automatically) |
| scratch files in `/tmp` | `Scratch/*.lean` |
| `lean_*` MCP tools | use them if available, else the rows above |
| "commit" / "checkpoint" | section 7 of this file (commit, never push) |

Inside `scripts/lean run`, `$LEAN4_SCRIPTS`, `$LEAN4_REFS` and the `lean4-skills-*` wrappers are
on `PATH`, and the working directory is the repository root.

## 3. Repository layout

```
LeanProofs/<Project>/      one folder per project; naming rules below
    Defs.lean              definitions specific to the project (reuse Aurora/Mathlib/other projects)
    *.lean                 statements and proofs, split by topic
    PROGRESS.md            status of every target statement + session log (keep it up to date!)
    Index.lean             optional: paper numbering -> Lean declarations, once there is a paper
LeanProofs/Common/         lemmas useful to several projects (e.g. ENNReal facts missing from
                           Mathlib, extensions of Aurora); one file per topic, e.g. Common/ENNReal.lean
LeanProofs/Example/        worked example of this layout (do not delete; it is the smoke test)
papers/<Project>/          informal sources (TeX/PDF/notes) if the user provided them
Scratch/                   throwaway experiments (git-ignored)
docs/aurora.md             Aurora cheat sheet
scripts/lean               the only way to run Lean (section 1)
```

- **Project names.** A project tied to one paper is named `<Short>_<VENUE>_<YEAR>`, for example
  `OracleGuided_JAIR_2025` or `SMPMC_AAAI_2026`; it holds that paper's numbered results and its
  `Index.lean`. Use underscores, not hyphens: hyphens are not allowed in Lean module names.
  Material shared by several papers (a model, its basic theory) goes in a generic CamelCase
  project such as `ColoredMDP`, which the paper projects import. The user chooses and renames
  projects; do not create or rename a project folder unless asked.
- Namespaces follow the folders: `namespace LeanProofs.<Project>`, for example
  `LeanProofs.SMPMC_AAAI_2026.theorem5_max`. Use `LeanProofs.Common` for shared lemmas.
- **Projects build on each other.** A project may import another project's modules
  (`import LeanProofs.OtherProject.Foo`), and you should reuse results proved elsewhere in the
  repo rather than re-proving them. Imports must not form a cycle. If two projects need each
  other's material, the shared part belongs in `LeanProofs/Common/` or in the more basic project.
  Moving *statements* between files counts as changing them, so ask the user first.
- Every file under `LeanProofs/` is built automatically (`globs` in `lakefile.toml`). You do not
  need to add it to `LeanProofs.lean`. A broken file anywhere breaks `scripts/lean build`.
- Imports: `import MDP`, `import PGCL`, `import HeyVL`, `import Mathlib.<…>`,
  `import LeanProofs.<…>`. Prefer the smallest import that works.

**Targets vs. helpers.** The *target statements* of a task are the declarations the user points
you at, or, if the user names a file or project, the `sorry`ed declarations listed in its
`PROGRESS.md`. Their statements are fixed. You may add *helper lemmas* freely. Give them names
and docstrings, and put general ones in `LeanProofs/Common/`.

**Keep reusable helpers public.** Helpers are the API later proofs build on. Keep public every
helper that states a general fact about the repo's definitions: recurrences, transfer or
correspondence lemmas, maps between path types, continuity, base cases. Mark a helper `private`
only if it is a narrow step of one proof, with an awkward statement (for example, one that
contains a proof term). List the public helpers in an "API" row of `PROGRESS.md`.

## 4. Workflow for a proving task

1. **Orient.** Run `git status` and `git log --oneline -10`. Read the project's `PROGRESS.md`,
   especially the log of earlier sessions, so you do not repeat known dead ends. Run
   `scripts/lean where`.
2. **Understand the statement.** Read it and the definitions it uses: Aurora's (see
   `docs/aurora.md`, then the source via `scripts/lean run grep/sed .lake/packages/pgcl/...`),
   this project's, and other projects' it imports. Write down in your own words what must be
   shown, and the informal proof if you have one (from the project notes or your own).
3. **Search before proving.** Look for the result, or close variants, in this repo (other
   projects and `Common/`), Aurora and Mathlib:
   `grep -rn "<pattern>" LeanProofs` for this repo;
   `exact?` / `apply?` in a scratch file;
   `scripts/lean run lean4-skills-search-mathlib "<name fragment>" name`;
   `scripts/lean run grep -rn "<pattern>" .lake/packages/pgcl .lake/packages/mathlib/Mathlib`;
   and the MCP search tools if available. Naming conventions help: `iSup_le`,
   `le_iSup_of_le`, `lfp_le`, `tsum_le_tsum`, `ENNReal.*`.
4. **Skeleton first.** Write the proof as a chain of `have` steps or helper lemmas, each closed
   by `sorry`. `check` that the skeleton compiles. Then fill one `sorry` at a time, running
   `check` after each meaningful edit. Never write long stretches of tactic code without
   compiling.
5. **When it works:** run the checks in section 6, update `PROGRESS.md`, and commit
   (section 7).
6. **When stuck** (several attempts on the same goal have failed):
   - restate the goal with `show`/`change` and print it, then simplify;
   - split it into smaller lemmas, or generalize, which often makes `simp` and `gcongr` work;
   - check that the goal is actually true. Look for a counterexample, especially for edge cases
     such as `⊤` in `ENNReal`, empty sets, or `0` probabilities;
   - consult the skill's `references/sorry-filling.md` and `references/tactic-patterns.md`;
   - if still stuck, leave a clearly marked `sorry` with a comment saying what is missing.
     Record the attempts and the obstacle in `PROGRESS.md`, then move on to the next target or
     stop and report. Do not loop on the same failing approach.

## 5. Statements: when they look wrong, and formalizing new ones

- **False statement:** do not weaken it. Prove the negation, or a concrete counterexample, as a
  separate theorem named `<name>_counterexample` or `not_<name>`. Mark the target `false` in
  `PROGRESS.md`, explain, and report it to the user.
- **Mis-formalized** (the Lean statement does not say what was intended), or **needs an extra
  hypothesis**: do not touch the original. Describe the problem and the fix you propose in
  `PROGRESS.md` and in your report. Write the corrected variant (`<name>'` or `<name>_of_<hyp>`)
  only if the user asks. The user decides whether statements change.
- **Formalizing (only when asked):** cite the source in the docstring (`/-- **Lemma 3.2.** … -/`).
  Record modelling choices (which Aurora definitions, `ENNReal` vs `ℝ`, finiteness assumptions)
  in the docstring. Leave the proofs as `sorry`, add the statements to `PROGRESS.md` with status
  `stated`, and commit with a `state(...)` message. The user reviews it.

## 6. Definition of done (for each target you claim as proved)

1. `scripts/lean check <file>` reports no errors and no `declaration uses 'sorry'` for it.
2. `scripts/lean axioms <file> <Full.Decl.Name>` lists only `propext`, `Classical.choice` and
   `Quot.sound` (or "does not depend on any axioms").
3. The statement is unchanged. Check with `git diff`: only proof bodies and new helpers may
   differ.
4. `PROGRESS.md` says `proved`. If the project has an `Index.lean`, it still compiles.
5. Before ending a session: `scripts/lean build` succeeds for the whole project.

## 7. Git: committing (never pushing)

Work is continued across machines and sessions through git, so commit often. The user reviews
your commits and pushes them to GitHub. You may be running in a clone on the build server that
the user pulls from directly.

- **Commit at every checkpoint:** a target proved, a skeleton that compiles, or the end of a
  work block. Committing work in progress with `sorry`s is fine if the project still compiles
  and `PROGRESS.md` says what is open. Never commit a state that does not compile.
- **Commit message prefixes:**
  - `prove(<Project>): …` for proof work: filling `sorry`s, adding helper lemmas, golfing, and
    `PROGRESS.md` updates. Example: `prove(MyProject): wp_le_of_invariant`.
  - `state(<Project>): …` for formalization: new or changed statements or definitions.
  - Use `prove(Common): …` for general lemmas added to `LeanProofs/Common/`.
- **Never `git push`**, and do not fetch, pull, rebase, amend published commits, or change
  remotes unless the user asks. New statements arrive in your working tree from the user.
- **Leave the working tree clean** at the end of a session: everything committed, with
  `git status` showing nothing. The user can only hand you new statements when there are no
  uncommitted changes.
- Do not commit `Scratch/`, `.lake/` or `scripts/local.env`. They are git-ignored.
- If `lake-manifest.json` or `lean-toolchain` changed without you meaning to change them, do
  not commit them. Mention it in your report.

## 8. `PROGRESS.md` format (one per project)

```markdown
# <Project>: formalization progress

Sources: <paper link, papers/<Project>/..., or notes>

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| Def. 2.1 | `LeanProofs.MyProject.foo` | Defs.lean | defined | |
| Lemma 3.2 | `LeanProofs.MyProject.bar_le` | Main.lean | proved | |
| Thm. 4.1 | `LeanProofs.MyProject.main` | Main.lean | in progress | needs Lemma 3.3 |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### YYYY-MM-DD (model name)
- What was done; what was tried and why it failed; what to do next.
```

The log matters most: the next session, possibly on another machine with another model,
starts from it.

## 9. Lean style

- Mathlib style: lines of 100 characters or fewer, `fun x ↦ …`, `theorem` for `Prop`s,
  `snake_case` theorem names that describe the statement (`wp_le_of_invariant`), and
  `UpperCamelCase` for types and structures.
- One docstring per public declaration, citing the source item where applicable.
- Prefer structured proofs (`have`, `calc`, `obtain`, `refine ⟨?_, ?_⟩`) over long `simp`
  chains. Use `simp only [...]` in non-terminal positions.
- Terminal `simp`, `grind`, `omega`, `positivity`, `gcongr` and `aesop` are fine. Avoid fragile
  proofs that depend on `simp` normal forms in the middle of a proof.
- Do not leave `#eval`/`#check`/`#print` commands or `set_option trace…` in committed files.

## 10. Reporting back

End every session with a short report:
- what was proved (declaration names);
- what is still open and why;
- any statements you believe are false or mis-formalized, with evidence;
- what you committed (`git log --oneline` of this session), and confirmation that the
  working tree is clean.

The same information belongs in the `PROGRESS.md` log.
