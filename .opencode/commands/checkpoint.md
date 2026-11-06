---
description: Verify, record progress and commit
agent: build
---

Make a checkpoint following AGENTS.md sections 6 and 7:
1. `scripts/lean build` (long timeout) must succeed.
2. Run `scripts/lean axioms` for every declaration that is newly marked proved.
3. Run `scripts/lean sorries` and make PROGRESS.md (table and log) match reality.
4. Commit with a `prove(<Project>): ...` or `state(<Project>): ...` message (AGENTS.md section 7).
5. Do not push (the user does that). Confirm that `git status` is clean.
Report what was verified.
