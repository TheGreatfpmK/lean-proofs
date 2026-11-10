import LeanProofs.ColoredMDP.Basic

/-!
# Restricting a colored MDP to a set of assignments

For a nonempty set of admissible assignments `η ⊆ C.V`, the colored MDP
`C_η := (C[η], η, κ)` is `C` restricted to the parameter space `η`. Only the actions that some
`θ ∈ η` can select remain, and only the assignments in `η` are admissible. This construction
appears in arXiv:2511.08078 (proof of Theorem 5). With it, results about the underlying MDP of a
colored MDP, such as JAIR Theorem 1, can be applied to the sub-MDP `C[η]`.

## Main definitions and results

* `ColoredMDP.restrict C η`: the colored MDP `C_η = (C[η], η, κ)`.
* `ColoredMDP.restrict_induced`: `C_η[η'] = C[η']` for `η' ⊆ η` (stated in the paper's proof).
* `ColoredMDP.restrict_inducedMC`, `restrict_reachProb`, `restrict_expCost`: for `θ ∈ η`, the
  Markov chain of `θ` and its values are the same in `C_η` and in `C`.
-/

namespace LeanProofs.ColoredMDP

open MDP

variable {State Act Θ : Type*} (C : ColoredMDP State Act Θ)

/-- An action is available in the induced MDP `C[η]` only if it is available in `C.M`. -/
theorem mem_act_of_mem_act_induced {η : Set Θ} {hη : η ⊆ C.V} {hne : η.Nonempty} {s : State}
    {α : Act} (h : α ∈ (C.induced η hη hne).act s) : α ∈ C.M.act s := by
  classical
  simp only [MDP.act, induced, Set.mem_setOf_eq] at h ⊢
  split_ifs at h <;> simp_all

/-- The action that an assignment `θ ∈ η` selects is available in the induced MDP `C[η]`. -/
theorem action_mem_act_induced {η : Set Θ} (hη : η ⊆ C.V) (hne : η.Nonempty) {θ : Θ}
    (hθ : θ ∈ η) (s : State) : C.action (hη hθ) s ∈ (C.induced η hη hne).act s := by
  classical
  simp only [MDP.act, induced, Set.mem_setOf_eq]
  rw [if_pos (show (η ∩ C.κ s (C.action (hη hθ) s)).Nonempty from
    ⟨θ, hθ, (C.action_spec (hη hθ) s).2⟩)]
  exact (C.action_spec (hη hθ) s).1

/-- Every `θ ∈ η` selects exactly one action that is available in `C[η]`. This is the
condition that makes `C_η = (C[η], η, κ)` a colored MDP. -/
theorem existsUnique_act_induced {η : Set Θ} (hη : η ⊆ C.V) (hne : η.Nonempty) {θ : Θ}
    (hθ : θ ∈ η) (s : State) : ∃! α, α ∈ (C.induced η hη hne).act s ∧ θ ∈ C.κ s α := by
  have hact := C.action_mem_act_induced hη hne hθ s
  have hspec := C.action_spec (hη hθ) s
  exact ⟨C.action (hη hθ) s, ⟨hact, hspec.2⟩, fun α hα ↦
    C.action_unique (hη hθ) (C.mem_act_of_mem_act_induced hα.1) hα.2⟩

/-- The colored MDP `C_η = (C[η], η, κ)`: `C` restricted to the nonempty parameter space
`η ⊆ C.V` (arXiv:2511.08078, proof of Theorem 5). -/
noncomputable def restrict (η : Set Θ) (hη : η ⊆ C.V) (hne : η.Nonempty) :
    ColoredMDP State Act Θ where
  M := C.induced η hη hne
  V := η
  κ := C.κ
  existsUnique_act _ hθ s := C.existsUnique_act_induced hη hne hθ s

variable (η : Set Θ) (hη : η ⊆ C.V) (hne : η.Nonempty)

/-- Restricting `C_η` further to `η' ⊆ η` gives the same MDP as restricting `C` to `η'`:
`C_η[η'] = C[η']` (arXiv:2511.08078, proof of Theorem 5). -/
theorem restrict_induced (η' : Set Θ) (hη' : η' ⊆ η) (hne' : η'.Nonempty) :
    (C.restrict η hη hne).induced η' hη' hne' = C.induced η' (hη'.trans hη) hne' := by
  classical
  simp only [restrict, induced, MDP.mk.injEq]
  funext s α
  by_cases h' : (η' ∩ C.κ s α).Nonempty
  · have h : (η ∩ C.κ s α).Nonempty := by
      obtain ⟨θ, hθ, hκ⟩ := h'
      exact ⟨θ, hη' hθ, hκ⟩
    simp [h', h]
  · simp [h']

/-- For `θ ∈ η`, the Markov chain of `θ` is the same in `C_η` as in `C`. -/
theorem restrict_inducedMC {θ : Θ} (hθ : θ ∈ η) :
    (C.restrict η hη hne).inducedMC hθ = C.inducedMC (hη hθ) := by
  exact C.restrict_induced η hη hne {θ} (Set.singleton_subset_iff.mpr hθ)
    (Set.singleton_nonempty θ)

/-- For `θ ∈ η`, the reachability probability of `θ`'s Markov chain is the same in `C_η` as in
`C`. -/
theorem restrict_reachProb {θ : Θ} (hθ : θ ∈ η) (T : Set State) (s : State) :
    (C.restrict η hη hne).reachProb hθ T s = C.reachProb (hη hθ) T s := by
  rw [reachProb, reachProb, C.restrict_inducedMC η hη hne hθ]

/-- For `θ ∈ η`, the expected total cost of `θ`'s Markov chain is the same in `C_η` as in `C`. -/
theorem restrict_expCost {θ : Θ} (hθ : θ ∈ η) (c : C.M.Costs) (s : State) :
    (C.restrict η hη hne).expCost hθ c s = C.expCost (hη hθ) c s := by
  sorry

end LeanProofs.ColoredMDP
