# Common: progress

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| — | `MDP.Vmin`, `MDP.Vmax`, `MDP.ReachProb(N)`, `MDP.Pmin`, `MDP.Pmax` | MDPValues.lean | defined | memoryless optimal values |
| — | `MDP.ReachProbN_le_one`, `MDP.ReachProb_le_one` | MDPValuesLemmas.lean | stated | reachability is a probability |
| — | `MDP.ReachProbN_mono` | MDPValuesLemmas.lean | stated | monotone in the step bound |
| — | `MDP.ReachProb_of_mem`, `MDP.ReachProb_empty`, `MDP.ReachProb_mono_target` | MDPValuesLemmas.lean | stated | trivial targets |
| JAIR §2.1.2 | `MDP.IsMarkovChain` | MDPValues.lean | defined | one action per state |
| — | `MDP.IsMarkovChain.scheduler_eq` | MDPValuesLemmas.lean | stated | an MC has only one scheduler |
| — | `MDP.IsMarkovChain.Pmin_eq_Pmax`, `MDP.IsMarkovChain.Vmin_eq_Vmax` | MDPValuesLemmas.lean | stated | min = max on an MC |
| Baier–Katoen Thm. 10.15 | `MDP.ReachProb_eq_lfp` | MDPValuesLemmas.lean | stated | Bellman characterization; validates the definition |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### 2026-11-06 (setup)
- Reachability defined from Aurora's path probabilities. The lemmas above pin the definition
  down and form its API.
