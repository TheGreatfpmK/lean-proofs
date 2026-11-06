---
description: Summarize formalization status across projects
agent: build
---

Summarize the state of this repository without editing anything: run `git status`, `git log --oneline -15`, `git log --oneline @{u}..HEAD` (unpushed commits, if an upstream is configured) and `scripts/lean sorries`, and read every `LeanProofs/*/PROGRESS.md`. Report per project what is proved, in progress, blocked or false, and the next steps suggested by the latest log entries. $ARGUMENTS
