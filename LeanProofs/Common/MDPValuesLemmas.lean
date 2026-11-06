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

/-- One additional step preserves the mass of paths that have already reached `T`. -/
private theorem ReachProbN_le_succ (n : ℕ) :
    M.ReachProbN 𝒮 T n s ≤ M.ReachProbN 𝒮 T (n + 1) s := by
  classical
  simp only [ReachProbN]
  rw [Path_eq.eq_biUnion_succs_univ]
  rw [ENNReal.tsum_biUnion
    (f := fun π : M.Path ↦ if ∃ x ∈ π.states, x ∈ T then π.Prob 𝒮 else 0)]
  · apply ENNReal.tsum_le_tsum
    intro π
    by_cases hπ : ∃ x ∈ π.val.states, x ∈ T
    · calc
        (if ∃ x ∈ π.val.states, x ∈ T then π.val.Prob 𝒮 else 0) ≤ π.val.Prob 𝒮 :=
          (if_pos hπ).le
        _ = ∑' π' : π.val.succs_univ, π'.val.Prob 𝒮 :=
          (Path.tsum_succs_univ_Prob_eq_one π.val).symm
        _ = ∑' π' : π.val.succs_univ,
            if ∃ x ∈ π'.val.states, x ∈ T then π'.val.Prob 𝒮 else 0 := by
          apply tsum_congr
          intro π'
          have hvisit : ∃ x ∈ π'.val.states, x ∈ T := by
            obtain ⟨x, hx, hxT⟩ := hπ
            refine ⟨x, ?_, hxT⟩
            have hxprev : x ∈ π'.val.prev.states := by
              rw [Path.mem_succs_univ_prev π'.property]
              exact hx
            have hlen : ‖π'.val‖ ≠ 1 := Nat.ne_of_lt' π'.property.2
            simp only [Path.prev, if_neg hlen] at hxprev
            exact List.mem_of_mem_dropLast hxprev
          rw [if_pos hvisit]
    · rw [if_neg hπ]
      exact zero_le
  · intro ⟨_, _⟩ _ ⟨_, _⟩ _ _
    apply Path_eq.succs_univ_disjoint M (s := s) (n := n + 1) <;> simp_all

/-- Allowing more steps can only increase the probability of having reached `T`. -/
theorem ReachProbN_mono : Monotone fun n ↦ M.ReachProbN 𝒮 T n s := by
  exact monotone_nat_of_le_succ (ReachProbN_le_succ 𝒮 T s)

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
  classical
  apply iSup_mono
  intro n
  apply ENNReal.tsum_le_tsum
  intro π
  by_cases hπ : ∃ x ∈ π.val.states, x ∈ T
  · have hπ' : ∃ x ∈ π.val.states, x ∈ T' := by
      obtain ⟨x, hx, hxT⟩ := hπ
      exact ⟨x, hx, h hxT⟩
    rw [if_pos hπ, if_pos hπ']
  · rw [if_neg hπ]
    exact zero_le

namespace IsMarkovChain

variable (hM : M.IsMarkovChain)
include hM

/-- On a Markov chain there is no nondeterminism: all schedulers coincide. -/
theorem scheduler_eq (𝒮₁ 𝒮₂ : 𝔖[M]) : 𝒮₁ = 𝒮₂ := by
  apply Scheduler.ext
  intro π
  exact (hM.existsUnique_act π.last).unique (𝒮₁.property π) (𝒮₂.property π)

/-- On a Markov chain, the minimal and maximal reachability probabilities agree. -/
theorem Pmin_eq_Pmax : M.Pmin T s = M.Pmax T s := by
  simp only [Pmin, Pmax]
  apply le_antisymm
  · exact iInf_le_of_le M.defaultPolicy (le_iSup_of_le M.defaultPolicy le_rfl)
  · refine iSup_le fun ℒ₁ ↦ le_iInf fun ℒ₂ ↦ ?_
    rw [hM.scheduler_eq (ℒ₁ : 𝔖[M]) (ℒ₂ : 𝔖[M])]

/-- On a Markov chain, the minimal and maximal expected total costs agree. -/
theorem Vmin_eq_Vmax (c : M.Costs) : M.Vmin c s = M.Vmax c s := by
  simp only [Vmin, Vmax]
  apply le_antisymm
  · exact iInf_le_of_le M.defaultPolicy (le_iSup_of_le M.defaultPolicy le_rfl)
  · refine iSup_le fun ℒ₁ ↦ le_iInf fun ℒ₂ ↦ ?_
    rw [hM.scheduler_eq (ℒ₁ : 𝔖[M]) (ℒ₂ : 𝔖[M])]

end IsMarkovChain

open scoped Classical in
/-- Specializing a memoryless scheduler does not change probabilities of paths with the
prescribed first state. -/
private theorem prob_specialize_markovian (ℒ : 𝔏[M]) (s : State) (s' : M.succs_univ s)
    (n : ℕ) (π : Path[M,s',=n+1]) :
    π.val.Prob (ℒ.toScheduler[s ↦ s']) = π.val.Prob ℒ := by
  have hsched : ∀ i : Fin (‖π.val‖ - 1),
      ℒ.toScheduler[s ↦ s'] (π.val.take i) = ℒ (π.val.take i) := by
    intro i
    rw [Scheduler.specialize_apply]
    have h : (π.val.take i)[0] = s' := by simp
    rw [dif_pos h]
    apply MScheduler.prepend
  simp only [Path.Prob, Fin.getElem_fin, Fin.val_succ, hsched]
  rfl

open scoped Classical in
/-- Bounded reachability in zero steps is the target's indicator function. -/
private theorem ReachProbN_zero (ℒ : 𝔏[M]) (T : Set State) (s : State) :
    M.ReachProbN ℒ T 0 s = if s ∈ T then 1 else 0 := by
  simp [ReachProbN]

/-- **Bellman characterization** (Baier & Katoen, Theorem 10.15): under a memoryless policy,
the reachability probabilities are the least fixed point of the reachability Bellman
operator. -/
theorem ReachProb_eq_lfp (ℒ : 𝔏[M]) :
    (fun s ↦ M.ReachProb ℒ T s) = OrderHom.lfp (M.reachΦℒ ℒ T) := by
  sorry

end MDP
