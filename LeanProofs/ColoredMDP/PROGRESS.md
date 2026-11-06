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
| arXiv Def. 3 | `LeanProofs.ColoredMDP.act_inducedMC` | Basic.lean | stated | the only action in `C[{θ}]` is `θ`'s |
| arXiv Def. 3 | `LeanProofs.ColoredMDP.isMarkovChain_inducedMC` | Basic.lean | stated | `C[{θ}]` is a Markov chain |
| — | `ColoredMDP.reachProb_eq_Pmin/Pmax`, `ColoredMDP.expCost_eq_Vmin/Vmax` | Basic.lean | stated | the chain's value is its min = max |
| JAIR §3.1 | `LeanProofs.ColoredMDP.EC_inducedMC` | Basic.lean | stated | `C[{θ}]` behaves like `M` under `θ`'s policy (expected cost) |
| JAIR §3.1 | `LeanProofs.ColoredMDP.ReachProbN_inducedMC` | Basic.lean | stated | same, bounded reachability |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### 2026-11-06 (setup)
- Definitions written and checked to compile. Basic lemmas stated: they carry the real content
  of JAIR Theorem 1 (`LeanProofs/OracleGuided/Theorem1.lean`).
