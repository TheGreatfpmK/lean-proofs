# ColoredMDP: formalization progress

Sources: arXiv:2511.08078 (Heck, Macák, Češka, Junges), Definitions 2–3; JAIR 82 (2025)
(Andriushchenko, Češka, Macák, Junges, Katoen), Definition 1 and Section 3.1. These are the
shared colored-MDP foundations, reused by the paper projects.

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| arXiv Def. 2 | `LeanProofs.ColoredMDP` | Defs.lean | defined | set-based coloring `κ s α ⊆ Θ`; JAIR Def. 1 is a special case |
| arXiv Def. 3 | `LeanProofs.ColoredMDP.induced` | Defs.lean | defined | `C[η]` for nonempty `η ⊆ V` |
| — | `LeanProofs.ColoredMDP.inducedMC` | Defs.lean | defined | `C[{θ}]` |
| JAIR §3.1 | `LeanProofs.ColoredMDP.policy` | Defs.lean | defined | consistent memoryless policy of `θ` |
| JAIR `P^{M_δ}`, `E^{M_δ}` | `LeanProofs.ColoredMDP.reachProb`, `LeanProofs.ColoredMDP.expCost` | Defs.lean | defined | the single value of the Markov chain `C[{θ}]` |
| arXiv Def. 3 | `LeanProofs.ColoredMDP.act_inducedMC` | Basic.lean | proved | the only action in `C[{θ}]` is `θ`'s |
| arXiv Def. 3 | `LeanProofs.ColoredMDP.isMarkovChain_inducedMC` | Basic.lean | proved | `C[{θ}]` is a Markov chain |
| — | `ColoredMDP.reachProb_eq_Pmin/Pmax`, `ColoredMDP.expCost_eq_Vmin/Vmax` | Basic.lean | proved | the chain's value is its min = max |
| JAIR §3.1 | `LeanProofs.ColoredMDP.EC_inducedMC` | Basic.lean | proved | `C[{θ}]` behaves like `M` under `θ`'s policy (expected cost) |
| JAIR §3.1 | `LeanProofs.ColoredMDP.ReachProbN_inducedMC` | Basic.lean | proved | same, bounded reachability |
| API | `ColoredMDP.toUnderlying`, `toInduced`, `boundedToUnderlying`, `boundedToInduced` (path maps between `C[{θ}]` and `M`); `toUnderlying_prob` (probability preserved), `toUnderlying_take`; `scheduler_eq_action` (every scheduler of `C[{θ}]` picks θ's action); `inducedMC_P_action` (transition probabilities agree); `tsum_inducedMC` (transfers any path sum between `C[{θ}]` and `M`) | Basic.lean | proved | helpers from the agent's proof, made public for reuse |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### 2026-11-10 (kimi-k3.1-pro)
- Proved all eight Basic.lean targets. The action and Markov-chain facts use the induced `P`
  definition and `action_unique`. The four extrema identities follow from
  `IsMarkovChain.scheduler_eq`, `Pmin_eq_Pmax`, and `Vmin_eq_Vmax`.
- For `EC_inducedMC` and `ReachProbN_inducedMC`, added private same-state path maps between the
  induced chain and the underlying MDP. The induced path map preserves path probabilities, and
  nonzero-policy paths have induced counterparts. `tsum_eq_tsum_of_ne_zero_bij` then transfers
  both weighted path sums. No target statements or definitions were changed.
- Validation: `scripts/lean check LeanProofs/ColoredMDP/Basic.lean` reports no errors or sorries;
  all eight targets use only standard axioms; `scripts/lean build` succeeds. The whole-project
  build reports only pre-existing sorries in AgentTest/Loop.lean and OracleGuided/Theorem1.lean.

### 2026-11-06 (setup)
- Definitions written and checked to compile. Basic lemmas stated: they carry the real content
  of JAIR Theorem 1 (`LeanProofs/OracleGuided/Theorem1.lean`).

### 2026-11-10 (overseer)
- Made the nine path-transfer helpers public (API row above).
