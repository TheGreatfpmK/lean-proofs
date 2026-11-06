import LeanProofs.ColoredMDP.Defs
import LeanProofs.Common.MDPValuesLemmas

/-!
# Basic properties of colored MDPs

The induced Markov chain `C[{θ}]` of an admissible assignment `θ` is a Markov chain: one
action per state. Its behaviour coincides with that of the underlying MDP `C.M` under the
consistent policy `C.policy θ`. JAIR (Section 2.2.2 and Section 3.1) uses this correspondence
implicitly, as `M_δ = M^δ = M^{σ_δ}`.
-/

namespace LeanProofs.ColoredMDP

open MDP

variable {State Act Θ : Type*} (C : ColoredMDP State Act Θ) {θ : Θ} (hθ : θ ∈ C.V)

/-- `C[{θ}]` is a Markov chain: in every state, the only available action is the one `θ`
selects. -/
theorem act_inducedMC (s : State) : (C.inducedMC hθ).act s = {C.action hθ s} := by
  sorry

/-- `C[{θ}]` is a Markov chain in the sense of `MDP.IsMarkovChain`. -/
theorem isMarkovChain_inducedMC : (C.inducedMC hθ).IsMarkovChain := by
  sorry

/-- `C.reachProb` is the minimal reachability probability of `C[{θ}]`; on a Markov chain this
is its only value. -/
theorem reachProb_eq_Pmin (T : Set State) (s : State) :
    C.reachProb hθ T s = (C.inducedMC hθ).Pmin T s := by
  sorry

/-- `C.reachProb` is the maximal reachability probability of `C[{θ}]`; on a Markov chain this
is its only value. -/
theorem reachProb_eq_Pmax (T : Set State) (s : State) :
    C.reachProb hθ T s = (C.inducedMC hθ).Pmax T s := by
  sorry

/-- `C.expCost` is the minimal expected total cost of `C[{θ}]`. -/
theorem expCost_eq_Vmin (c : C.M.Costs) (s : State) :
    C.expCost hθ c s = (C.inducedMC hθ).Vmin c s := by
  sorry

/-- `C.expCost` is the maximal expected total cost of `C[{θ}]`. -/
theorem expCost_eq_Vmax (c : C.M.Costs) (s : State) :
    C.expCost hθ c s = (C.inducedMC hθ).Vmax c s := by
  sorry

/-- The expected cost (within `n` steps) of the induced Markov chain `C[{θ}]`, under any of its
schedulers, equals that of the underlying MDP under the consistent policy of `θ`. -/
theorem EC_inducedMC (c : C.M.Costs) (𝒮 : 𝔖[C.inducedMC hθ]) (n : ℕ) (s : State) :
    (C.inducedMC hθ).EC c 𝒮 n s = C.M.EC c (C.policy hθ) n s := by
  sorry

/-- Bounded reachability in the induced Markov chain `C[{θ}]`, under any of its schedulers,
equals bounded reachability in the underlying MDP under the consistent policy of `θ`. -/
theorem ReachProbN_inducedMC (𝒮 : 𝔖[C.inducedMC hθ]) (T : Set State) (n : ℕ) (s : State) :
    (C.inducedMC hθ).ReachProbN 𝒮 T n s = C.M.ReachProbN (C.policy hθ) T n s := by
  sorry

end LeanProofs.ColoredMDP
