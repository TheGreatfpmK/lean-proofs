# AgentTest: formalization progress

Sources: none. These are small statements for testing the proving-agent setup end to end. Each
is known to be provable with standard axioms only.

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| Test 1 | `LeanProofs.AgentTest.wp_tick_seq_tick` | Basic.lean | stated | easy: unfold `wp` |
| Test 2 | `LeanProofs.AgentTest.wp_coin_cost` | Basic.lean | stated | medium: `ENNReal` arithmetic |
| Test 3 | `LeanProofs.AgentTest.oec_mono` | Basic.lean | stated | medium: monotonicity through `⨅`/`⨆`/`∑'` |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### 2026-11-06 (setup)
- Statements created for the first end-to-end agent test.
