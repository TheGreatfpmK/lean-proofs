---
description: Formalize informal statements into Lean (statements only, no proofs)
agent: build
---

Load the `lean4` skill and use the drafting part of the **formalize** workflow in `vendor/lean4-skills/plugins/lean4/commands/formalize.md`. Only write statements; do not prove them (proofs stay `sorry`).

What to formalize (paper item, text or file): $ARGUMENTS

Follow AGENTS.md strictly. In particular, run Lean only via `scripts/lean` (translate the skill's `lake`/helper commands using the table in AGENTS.md section 2), never change existing statements, and keep the project's PROGRESS.md up to date. Put the result in `LeanProofs/<Project>/` following AGENTS.md sections 3 and 5. Reuse definitions and results from other projects, `Common/`, Aurora and Mathlib. Make sure the statements compile with `scripts/lean check`. Add them to PROGRESS.md as `stated`, commit with a `state(<Project>): ...` message, and do not push: the user reviews and pushes it.
