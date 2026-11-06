---
description: Autonomous proving with a stop budget (lean4 skill autoprove workflow)
agent: build
---

Load the `lean4` skill. Then read and follow the **autoprove** workflow in
`vendor/lean4-skills/plugins/lean4/commands/autoprove.md`. Work autonomously and do not ask
questions.

Target and options: $ARGUMENTS

AGENTS.md takes precedence over the workflow wherever they differ. In particular:

- **Lean:** use only `scripts/lean` (AGENTS.md section 2 maps every `lake`/helper command).
- **Cycle tracker:** call it as `scripts/lean run lean4-skills-cycle-tracker <subcommand> ...`
  (`init`, `tick`, `status`, `stop`, ...). `scripts/lean` keeps the tracker's session between
  calls, so you do not need to pass `LEAN4_SESSION_ID`. Use the same pattern for every other
  `lean4-skills-*` helper.
- **Statements:** use `--statement-policy=preserve` and never change a target statement. If a
  target looks false or mis-formalized, follow AGENTS.md section 5: refute it in a separate
  theorem, or record the evidence. Mark it in PROGRESS.md and move on.
- **Commits:** where the workflow says `git commit -m "fill: [theorem] - [tactic]"`, use
  `git commit -m "prove(<Project>): fill <theorem> - <tactic>"`. Stage only the files you
  edited. Never push.
- **Scope:** do not use `--persist`.
- **Finishing:** keep the project's PROGRESS.md (table and log) up to date, leave the working
  tree clean, and finish with the stop summary from the workflow plus the report from AGENTS.md
  section 10.
