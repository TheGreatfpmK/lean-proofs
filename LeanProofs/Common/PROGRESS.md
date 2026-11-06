# Common: progress

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| — | `MDP.Vmin`, `MDP.Vmax`, `MDP.ReachProb(N)`, `MDP.Pmin`, `MDP.Pmax` | MDPValues.lean | defined | memoryless optimal values |
| — | `MDP.ReachProbN_le_one`, `MDP.ReachProb_le_one` | MDPValuesLemmas.lean | proved | reachability is a probability |
| — | `MDP.ReachProbN_mono` | MDPValuesLemmas.lean | proved | monotone in the step bound |
| — | `MDP.ReachProb_of_mem`, `MDP.ReachProb_empty`, `MDP.ReachProb_mono_target` | MDPValuesLemmas.lean | proved | trivial targets |
| JAIR §2.1.2 | `MDP.IsMarkovChain` | MDPValues.lean | defined | one action per state |
| — | `MDP.IsMarkovChain.scheduler_eq` | MDPValuesLemmas.lean | proved | an MC has only one scheduler |
| — | `MDP.IsMarkovChain.Pmin_eq_Pmax`, `MDP.IsMarkovChain.Vmin_eq_Vmax` | MDPValuesLemmas.lean | proved | min = max on an MC |
| Baier–Katoen Thm. 10.15 | `MDP.ReachProb_eq_lfp` | MDPValuesLemmas.lean | proved | Bellman characterization; validates the definition |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### 2026-11-06 (setup)
- Reachability defined from Aurora's path probabilities. The lemmas above pin the definition
  down and form its API.

### 2026-11-06 (kimi-k3.1-pro)
- Proved all ten target declarations in `MDPValuesLemmas.lean`; no target statements changed.
- Bounded probabilities are bounded by `Path.tsum_Prob_eq_one`; monotonicity in the step bound
  uses a one-step path-extension decomposition, and the Markov-chain extrema follow from
  scheduler extensionality.
- Proved the Bellman characterization using a first-transition/tail recurrence for `ReachProbN`,
  ω-Scott continuity of `reachΦℒ`, and the Kleene iterates
  `ReachProbN n = reachΦℒ^[n + 1] ⊥`.
- Verification: `scripts/lean check LeanProofs/Common/MDPValuesLemmas.lean` passed with no
  warnings; the file has zero sorries. Every target's axiom report contains only `propext`,
  `Classical.choice`, and `Quot.sound`. `scripts/lean build` passed all 2086 jobs (only unrelated
  pre-existing sorry warnings elsewhere).
