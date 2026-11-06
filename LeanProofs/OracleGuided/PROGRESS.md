# OracleGuided: formalization progress

Source: Andriushchenko, Češka, Macák, Junges, Katoen. *An Oracle-Guided Approach to Constrained
Policy Synthesis Under Uncertainty*. JAIR 82 (2025), https://doi.org/10.1613/jair.1.16593

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| Thm. 1 (§3.1) | `LeanProofs.OracleGuided.theorem1_reach` | Theorem1.lean | stated | as in the paper (reachability) |
| Thm. 1 (§3.1), reward variant | `LeanProofs.OracleGuided.theorem1_cost` | Theorem1.lean | stated | expected total cost |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

Dependencies: both follow quickly from `ColoredMDP.ReachProbN_inducedMC` / `ColoredMDP.EC_inducedMC`
(`LeanProofs/ColoredMDP/Basic.lean`), plus the fact that every MDP has a memoryless policy.

## Log
### 2026-11-06 (setup)
- Theorem 1 stated in two variants; modelling choices are in the module docstring of
  `Theorem1.lean`.
