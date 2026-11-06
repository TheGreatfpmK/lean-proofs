# AgentTest: formalization progress

Sources: none. These are small statements for testing the proving-agent setup end to end.

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| Test 1 | `LeanProofs.AgentTest.wp_tick_seq_tick` | Basic.lean | proved | Unfold `wp`, then use semiring arithmetic. |
| Test 2 | `LeanProofs.AgentTest.wp_coin_cost` | Basic.lean | proved | Simplify `wp` and evaluate the `ENNReal` expression. |
| Test 3 | `LeanProofs.AgentTest.oec_mono` | Basic.lean | proved | Reuse the scheduler and bound path costs pointwise. |
| Test 4 | `LeanProofs.AgentTest.geo_le_two` | Loop.lean | proved | Park induction with the claimed bound as invariant. |
| Test 5 | `LeanProofs.AgentTest.geo_ge_three_halves` | Loop.lean | proved | The second Kleene iterate already gives `3 / 2`. |
| Test 6 | `LeanProofs.AgentTest.geo_le_one` | Loop.lean | false | `geo_le_one_counterexample` uses `x = 1`; `geo_le_one_salvaged` restores the correct bound `2`. |

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

### 2026-11-06 (kimi-k3.1-pro, autoprove cycle 1)
- Proved `geo_le_two` by Park induction and `geo_ge_three_halves` using the second Kleene
  iterate. Both proofs finish with checked `ENNReal` arithmetic.
- Refuted `geo_le_one` with `geo_le_one_counterexample`: at the constant state `x = 1`, the
  proved lower bound `3 / 2` contradicts the claimed upper bound `1`. Added
  `geo_le_one_salvaged` with the correct bound `2`. The original false statement and its `sorry`
  remain unchanged, as required.
- `scripts/lean check LeanProofs/AgentTest/Loop.lean` passes with only the intentional `sorry` in
  the false target. The four completed declarations use only `propext`, `Classical.choice`, and
  `Quot.sound`. The whole-project build and final verification remain to be run.

### 2026-11-06 (kimi-k3.1-pro, autoprove stop)
- Cycles 2–4 made no edits: the only remaining target was the already-refuted `geo_le_one`, and
  the rerun guard prevented repeating the same blocker without new evidence. The session stopped
  on `max-stuck` after 4 cycles, with no deep-mode invocations.
- Final `scripts/lean check LeanProofs/AgentTest/Loop.lean` passed with only the intentional
  `sorry` in the false target. `scripts/lean build` passed for the whole project (2080 jobs).
- Final axiom checks for `geo_le_two`, `geo_ge_three_halves`, `geo_le_one_counterexample`, and
  `geo_le_one_salvaged` report only `propext`, `Classical.choice`, and `Quot.sound`.
- Comparing against commit `9672579` confirms that all user-supplied statements are unchanged;
  only proof bodies and the two falsification artifacts were added.
