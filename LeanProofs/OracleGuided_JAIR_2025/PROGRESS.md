# OracleGuided_JAIR_2025: formalization progress

Source: Andriushchenko, Češka, Macák, Junges, Katoen. *An Oracle-Guided Approach to Constrained
Policy Synthesis Under Uncertainty*. JAIR 82 (2025), https://doi.org/10.1613/jair.1.16593

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| Thm. 1 (§3.1) | `LeanProofs.OracleGuided_JAIR_2025.theorem1_reach` | Theorem1.lean | proved | as in the paper (reachability) |
| Thm. 1 (§3.1), reward variant | `LeanProofs.OracleGuided_JAIR_2025.theorem1_cost` | Theorem1.lean | proved | expected total cost |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

Dependencies: both follow quickly from `ColoredMDP.ReachProbN_inducedMC` / `ColoredMDP.EC_inducedMC`
(`LeanProofs/ColoredMDP/Basic.lean`), plus the fact that every MDP has a memoryless policy.

## Log
### 2026-11-06 (setup)
- Theorem 1 stated in two variants; modelling choices are in the module docstring of
  `Theorem1.lean`.

### 2026-11-10 (kimi-k3.1-pro)
- Proved `theorem1_reach` via `ColoredMDP.ReachProbN_inducedMC`: each induced chain's value is
  identified with its consistent memoryless policy, then `iInf`/`iSup` bounds give the three
  inequalities; nonemptiness supplies the middle inequality.
- Proved `theorem1_cost` analogously via `ColoredMDP.EC_inducedMC`.
- `scripts/lean check LeanProofs/OracleGuided_JAIR_2025/Theorem1.lean` and the axiom checks for both targets
  pass with only standard axioms. The internal checkpoint review found zero sorries and only two
  optional `apply`/`exact` inlining suggestions. `scripts/lean build` succeeds, including
  `OracleGuided_JAIR_2025.Index`; its only warning is the pre-existing sorry in `AgentTest.Loop`.
- No open targets remain in this project.

### 2026-11-10 (maintenance)
- Project folder and namespace renamed to `OracleGuided_JAIR_2025`
  (paper-project naming convention, AGENTS.md §3). Statements unchanged.
