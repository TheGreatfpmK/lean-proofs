---
description: Search for a counterexample to a statement
agent: build
---

Load the `lean4` skill, then read and follow the **disprove** workflow in `vendor/lean4-skills/plugins/lean4/commands/disprove.md`.

Statement: $ARGUMENTS

Follow AGENTS.md strictly. In particular, run Lean only via `scripts/lean` (translate the skill's `lake`/helper commands using the table in AGENTS.md section 2), never change existing statements, and keep the project's PROGRESS.md up to date. A refutation is a separate theorem (`not_<name>` or `<name>_counterexample`), per AGENTS.md section 5.
