import LeanProofs.ColoredMDP.Restrict
import LeanProofs.OracleGuided_JAIR_2025.Theorem1

/-!
# SMPMC (AAAI 2026): the induced-MDP abstraction is sound for every set of assignments

Heck, Macák, Češka, Junges: *Constrained and Robust Policy Synthesis with
Satisfiability-Modulo-Probabilistic-Model-Checking*, AAAI 2026 (arXiv:2511.08078), Section 4.3.

The SMPMC theory solver does not enumerate the assignments in a set `η ⊆ V`. Instead it
model-checks a single MDP, the induced MDP `C[η]`, as an abstraction of all the Markov chains
`C[{θ}]` with `θ ∈ η`. This file states that the abstraction is sound. For every nonempty
`η ⊆ V` and every `θ ∈ η`,

  `V^min(C[η]) ≤ V(C[θ]) ≤ V^max(C[η])`,

for expected total cost (the paper's objective) and for reachability. The paper's proof of
Theorem 5 (Appendix B.2) applies JAIR Theorem 1 to the restricted colored MDP
`C_η = (C[η], η, κ)` (`ColoredMDP.restrict`) and uses `C_η[{θ}] = C[{θ}]`
(`ColoredMDP.restrict_inducedMC`).

`theorem5_max` and `theorem5_min` are the semantic core of Theorem 5. If the abstraction's
optimum is below (resp. at least) the threshold `ν`, then so is every Markov chain in `η`; the
SMT solver then reports the partial assignment as a `T_C`-conflict. The surrounding SMT notions
(partial assignments `K`, the theory `T_C`, conflicts) are not formalized here.

## Modelling choices

* As in `OracleGuided_JAIR_2025/Theorem1.lean`, `V^min`/`V^max` range over memoryless policies, and
  `V(C[θ])` is the single value `C.expCost`/`C.reachProb` of the induced Markov chain.
* Values are stated at every state `s`, not only at the initial state.
-/

namespace LeanProofs.SMPMC_AAAI_2026

open MDP

variable {State Act Θ : Type*} (C : ColoredMDP State Act Θ)
  (η : Set Θ) (hη : η ⊆ C.V) (hne : η.Nonempty)

/-- **Abstraction soundness, upper bound** (expected total cost). Every Markov chain of the
family `η` has expected cost at most the maximal expected cost of the induced MDP `C[η]`. -/
theorem expCost_le_Vmax_induced {θ : Θ} (hθ : θ ∈ η) (c : C.M.Costs) (s : State) :
    C.expCost (hη hθ) c s ≤ (C.induced η hη hne).Vmax c s := by
  sorry

/-- **Abstraction soundness, lower bound** (expected total cost). Every Markov chain of the
family `η` has expected cost at least the minimal expected cost of the induced MDP `C[η]`. -/
theorem Vmin_induced_le_expCost {θ : Θ} (hθ : θ ∈ η) (c : C.M.Costs) (s : State) :
    (C.induced η hη hne).Vmin c s ≤ C.expCost (hη hθ) c s := by
  sorry

/-- **Abstraction soundness, upper bound** (reachability). -/
theorem reachProb_le_Pmax_induced {θ : Θ} (hθ : θ ∈ η) (T : Set State) (s : State) :
    C.reachProb (hη hθ) T s ≤ (C.induced η hη hne).Pmax T s := by
  sorry

/-- **Abstraction soundness, lower bound** (reachability). -/
theorem Pmin_induced_le_reachProb {θ : Θ} (hθ : θ ∈ η) (T : Set State) (s : State) :
    (C.induced η hη hne).Pmin T s ≤ C.reachProb (hη hθ) T s := by
  sorry

/-- **arXiv:2511.08078, Theorem 5** (semantic core, `viable` case). If the maximal expected cost
of the abstraction `C[η]` is below the threshold `ν`, then every Markov chain of the family `η`
is below `ν`. -/
theorem theorem5_max (c : C.M.Costs) (s : State) (ν : ENNReal)
    (hlt : (C.induced η hη hne).Vmax c s < ν) {θ : Θ} (hθ : θ ∈ η) :
    C.expCost (hη hθ) c s < ν := by
  sorry

/-- **arXiv:2511.08078, Theorem 5** (semantic core, `¬viable` case). If the minimal expected
cost of the abstraction `C[η]` is at least the threshold `ν`, then every Markov chain of the
family `η` is at least `ν`. -/
theorem theorem5_min (c : C.M.Costs) (s : State) (ν : ENNReal)
    (hge : ν ≤ (C.induced η hη hne).Vmin c s) {θ : Θ} (hθ : θ ∈ η) :
    ν ≤ C.expCost (hη hθ) c s := by
  sorry

end LeanProofs.SMPMC_AAAI_2026
