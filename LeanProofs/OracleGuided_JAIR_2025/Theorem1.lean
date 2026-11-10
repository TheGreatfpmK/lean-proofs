import LeanProofs.ColoredMDP.Basic

/-!
# JAIR 2025, Theorem 1: the underlying MDP bounds the family

Andriushchenko, Češka, Macák, Junges, Katoen: *An Oracle-Guided Approach to Constrained Policy
Synthesis Under Uncertainty*, JAIR 82 (2025), Section 3.1, Theorem 1.

> Let `M = (M, Δ, κ)` be a coloured MDP and `T ⊆ S` a set of target states in the underlying MDP
> `M`. Then `P^M_min[◇T] ≤ min_{δ∈Δ} P^{M_δ}[◇T] ≤ max_{δ∈Δ} P^{M_δ}[◇T] ≤ P^M_max[◇T]`.

## Modelling choices

* Colored MDPs follow arXiv:2511.08078, Definition 2 (`LeanProofs.ColoredMDP`). The design space
  `Δ` is the parameter space `C.V`, and `M_δ` is the induced Markov chain `C.inducedMC`. Its
  single value `P^{M_δ}[◇T]` is `C.reachProb` (no min/max: a Markov chain has no
  nondeterminism).
* Following JAIR Section 2.1.2, policies are deterministic and memoryless, so `Pmin`/`Pmax`
  range over Aurora's Markovian schedulers `𝔏[M]`.
* The values are stated at an arbitrary state `s`, not only at the initial state.
* `min`/`max` over `Δ` become `⨅`/`⨆` over `C.V`; for a finite `C.V` they are attained. The paper
  implicitly assumes that the design space is nonempty (`hV`).
* JAIR states the theorem for reachability probabilities and notes that reward variants are
  analogous. `theorem1_reach` is the stated version. `theorem1_cost` is the expected
  total cost version, the objective of arXiv:2511.08078.
-/

namespace LeanProofs.OracleGuided_JAIR_2025

open MDP

variable {State Act Θ : Type*} (C : ColoredMDP State Act Θ)

/-- **JAIR 2025, Theorem 1** (reachability). The optimal reachability probabilities of the
underlying MDP bound those of every Markov chain in the family:
`P^M_min[◇T] ≤ min_θ P^{M_θ}[◇T] ≤ max_θ P^{M_θ}[◇T] ≤ P^M_max[◇T]`. -/
theorem theorem1_reach (hV : C.V.Nonempty) (T : Set State) (s : State) :
    C.M.Pmin T s ≤ ⨅ θ : C.V, C.reachProb θ.2 T s ∧
      ⨅ θ : C.V, C.reachProb θ.2 T s ≤ ⨆ θ : C.V, C.reachProb θ.2 T s ∧
      ⨆ θ : C.V, C.reachProb θ.2 T s ≤ C.M.Pmax T s := by
  have hval (θ : C.V) : C.reachProb θ.2 T s = C.M.ReachProb (C.policy θ.2) T s := by
    simp only [ColoredMDP.reachProb, MDP.ReachProb]
    apply iSup_congr
    intro n
    exact C.ReachProbN_inducedMC θ.2 _ T n s
  let _ : Nonempty C.V := hV.to_subtype
  refine ⟨?_, iInf_le_iSup, ?_⟩
  · refine le_iInf fun θ ↦ ?_
    rw [hval θ]
    exact iInf_le _ (C.policy θ.2)
  · refine iSup_le fun θ ↦ ?_
    rw [hval θ]
    exact le_iSup (fun ℒ : 𝔏[C.M] ↦ C.M.ReachProb ℒ T s) (C.policy θ.2)

/-- **JAIR 2025, Theorem 1** (expected total cost variant). The optimal expected total costs
of the underlying MDP bound those of every Markov chain in the family:
`V^M_min ≤ min_θ V^{M_θ} ≤ max_θ V^{M_θ} ≤ V^M_max`. -/
theorem theorem1_cost (hV : C.V.Nonempty) (c : C.M.Costs) (s : State) :
    C.M.Vmin c s ≤ ⨅ θ : C.V, C.expCost θ.2 c s ∧
      ⨅ θ : C.V, C.expCost θ.2 c s ≤ ⨆ θ : C.V, C.expCost θ.2 c s ∧
      ⨆ θ : C.V, C.expCost θ.2 c s ≤ C.M.Vmax c s := by
  have hval (θ : C.V) : C.expCost θ.2 c s = ⨆ n, C.M.EC c (C.policy θ.2) n s := by
    simp only [ColoredMDP.expCost]
    apply iSup_congr
    intro n
    exact C.EC_inducedMC θ.2 c _ n s
  let _ : Nonempty C.V := hV.to_subtype
  refine ⟨?_, iInf_le_iSup, ?_⟩
  · refine le_iInf fun θ ↦ ?_
    rw [hval θ]
    exact iInf_le _ (C.policy θ.2)
  · refine iSup_le fun θ ↦ ?_
    rw [hval θ]
    exact le_iSup (fun ℒ : 𝔏[C.M] ↦ ⨆ n, C.M.EC c ℒ n s) (C.policy θ.2)

end LeanProofs.OracleGuided_JAIR_2025
