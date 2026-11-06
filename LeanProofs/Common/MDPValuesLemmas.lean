import LeanProofs.Common.MDPValues

/-!
# Basic properties of reachability probabilities

These lemmas validate the definition of `MDP.ReachProb` in `LeanProofs/Common/MDPValues.lean`.
They show that it is a probability, that it behaves as expected on trivial targets, and, most
importantly, that it satisfies the standard **Bellman characterization**
(Baier & Katoen, *Principles of Model Checking*, Theorem 10.15). They are also the API that later
proofs about reachability will use.
-/

namespace MDP

variable {State Act : Type*} {M : MDP State Act}

open scoped Classical in
/-- The reachability Bellman operator of a memoryless policy `ℒ`:
`x ↦ (s ↦ 1 if s ∈ T, otherwise ∑ s', P(s, ℒ(s), s') * x s')`. -/
noncomputable def reachΦℒ (ℒ : 𝔏[M]) (T : Set State) : M.Costs →o M.Costs :=
  ⟨fun v s ↦ if s ∈ T then 1 else Φf s (ℒ {s}) v, by
    intro v w h s
    dsimp only
    split_ifs
    · rfl
    · exact (Φf s (ℒ {s})).mono h⟩

variable (𝒮 : 𝔖[M]) (T : Set State) (s : State)

/-- Bounded reachability is a probability. -/
theorem ReachProbN_le_one (n : ℕ) : M.ReachProbN 𝒮 T n s ≤ 1 := by
  classical
  calc
    M.ReachProbN 𝒮 T n s ≤ ∑' π : Path[M,s,=n+1], π.val.Prob 𝒮 := by
      apply ENNReal.tsum_le_tsum
      intro π
      split_ifs <;> simp
    _ = 1 := Path.tsum_Prob_eq_one n

/-- Reachability is a probability. -/
theorem ReachProb_le_one : M.ReachProb 𝒮 T s ≤ 1 := by
  exact iSup_le fun n ↦ ReachProbN_le_one 𝒮 T s n

/-- Allowing more steps can only increase the probability of having reached `T`. -/
theorem ReachProbN_mono : Monotone fun n ↦ M.ReachProbN 𝒮 T n s := by
  sorry

/-- A state in `T` reaches `T` with probability 1. -/
theorem ReachProb_of_mem (h : s ∈ T) : M.ReachProb 𝒮 T s = 1 := by
  apply le_antisymm (ReachProb_le_one 𝒮 T s)
  have h0 : M.ReachProbN 𝒮 T 0 s = 1 := by
    classical
    simp [ReachProbN, h]
  calc
    1 = M.ReachProbN 𝒮 T 0 s := h0.symm
    _ ≤ M.ReachProb 𝒮 T s := le_iSup (fun n ↦ M.ReachProbN 𝒮 T n s) 0

/-- Nothing reaches the empty set. -/
theorem ReachProb_empty : M.ReachProb 𝒮 ∅ s = 0 := by
  simp [ReachProb, ReachProbN]

/-- Reachability is monotone in the target set. -/
theorem ReachProb_mono_target {T T' : Set State} (h : T ⊆ T') :
    M.ReachProb 𝒮 T s ≤ M.ReachProb 𝒮 T' s := by
  sorry

namespace IsMarkovChain

variable (hM : M.IsMarkovChain)
include hM

/-- On a Markov chain there is no nondeterminism: all schedulers coincide. -/
theorem scheduler_eq (𝒮₁ 𝒮₂ : 𝔖[M]) : 𝒮₁ = 𝒮₂ := by
  sorry

/-- On a Markov chain, the minimal and maximal reachability probabilities agree. -/
theorem Pmin_eq_Pmax : M.Pmin T s = M.Pmax T s := by
  sorry

/-- On a Markov chain, the minimal and maximal expected total costs agree. -/
theorem Vmin_eq_Vmax (c : M.Costs) : M.Vmin c s = M.Vmax c s := by
  sorry

end IsMarkovChain

/-- **Bellman characterization** (Baier & Katoen, Theorem 10.15): under a memoryless policy,
the reachability probabilities are the least fixed point of the reachability Bellman
operator. -/
theorem ReachProb_eq_lfp (ℒ : 𝔏[M]) :
    (fun s ↦ M.ReachProb ℒ T s) = OrderHom.lfp (M.reachΦℒ ℒ T) := by
  sorry

end MDP
