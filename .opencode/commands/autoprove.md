---
description: Autonomous proving with a stop budget
agent: build
---

Load the `lean4` skill, then read and follow the **autoprove** workflow in `vendor/lean4-skills/plugins/lean4/commands/autoprove.md`. Work autonomously and do not ask questions. When blocked on an item, record it in PROGRESS.md and continue with the next one.

Target and budget: $ARGUMENTS

Follow AGENTS.md strictly. In particular, run Lean only via `scripts/lean` (translate the skill's `lake`/helper commands using the table in AGENTS.md section 2), never change existing statements, and keep the project's PROGRESS.md up to date. Commit at every checkpoint with `prove(<Project>): ...` messages. Never push. Leave the working tree clean, and finish with the report from AGENTS.md section 10.
