# AgentTest: formalization progress

Sources: none. These are small statements for testing the proving-agent setup end to end.

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| Test 1 | `LeanProofs.AgentTest.wp_tick_seq_tick` | Basic.lean | proved | Unfold `wp`, then use semiring arithmetic. |
| Test 2 | `LeanProofs.AgentTest.wp_coin_cost` | Basic.lean | proved | Simplify `wp` and evaluate the `ENNReal` expression. |
| Test 3 | `LeanProofs.AgentTest.oec_mono` | Basic.lean | proved | Reuse the scheduler and bound path costs pointwise. |
| Test 4 | `LeanProofs.AgentTest.geo_le_two` | Loop.lean | stated | upper bound on a loop's expected cost |
| Test 5 | `LeanProofs.AgentTest.geo_ge_three_halves` | Loop.lean | stated | lower bound on a loop's expected cost |
| Test 6 | `LeanProofs.AgentTest.geo_le_one` | Loop.lean | stated | upper bound on a loop's expected cost |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### 2026-11-06 (setup)
- Statements created for the first end-to-end agent test.

### 2026-11-06 (kimi-k3.1-pro)
- Proved `wp_tick_seq_tick` by unfolding `wp` and normalizing the resulting sum.
- Proved `wp_coin_cost` by simplifying `wp` and `ProbExp.inv`, then cancelling the inverse of `2`.
- Proved `oec_mono` by reusing each scheduler, applying monotonicity of `iSup` and `tsum`, and
  comparing path costs with `List.sum_le_sum`.
- `scripts/lean check LeanProofs/AgentTest/Basic.lean` passed with no errors or sorries. All three
  declarations depend only on `propext`, `Classical.choice`, and `Quot.sound`. The full
  `scripts/lean build` also passed.

### 2026-11-06 (setup)
- Added Tests 4–6 in `Loop.lean`: bounds on the expected cost of a geometric loop.
