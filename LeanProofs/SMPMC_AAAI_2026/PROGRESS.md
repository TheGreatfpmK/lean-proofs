# SMPMC_AAAI_2026: formalization progress

Source: Heck, Macák, Češka, Junges. *Constrained and Robust Policy Synthesis with
Satisfiability-Modulo-Probabilistic-Model-Checking*. AAAI 2026, arXiv:2511.08078.

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| §4.3, Thm. 5 proof, steps (1)–(2) | `LeanProofs.SMPMC_AAAI_2026.expCost_le_Vmax_induced`, `LeanProofs.SMPMC_AAAI_2026.Vmin_induced_le_expCost` | Abstraction.lean | stated | abstraction `C[η]` is sound for every `η ⊆ V` (expected cost) |
| — | `LeanProofs.SMPMC_AAAI_2026.reachProb_le_Pmax_induced`, `LeanProofs.SMPMC_AAAI_2026.Pmin_induced_le_reachProb` | Abstraction.lean | stated | same, reachability |
| §4.3, Thm. 5 | `LeanProofs.SMPMC_AAAI_2026.theorem5_max`, `LeanProofs.SMPMC_AAAI_2026.theorem5_min` | Abstraction.lean | stated | semantic core (the SMT/`T_C` wrapper is not formalized) |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

Dependencies: the paper's route is JAIR Theorem 1 (`OracleGuided_JAIR_2025.theorem1_cost`/`_reach`, proved)
applied to `ColoredMDP.restrict C η`, plus `ColoredMDP.restrict_expCost`/`restrict_reachProb`
(`LeanProofs/ColoredMDP/Restrict.lean`). Prove `Restrict.lean` first.

## Log
### 2026-11-10 (setup)
- Statements written; modelling choices are in the module docstring of `Abstraction.lean`.

### 2026-11-10 (maintenance)
- Project folder and namespace renamed to `SMPMC_AAAI_2026`
  (paper-project naming convention, AGENTS.md §3). Statements unchanged.
