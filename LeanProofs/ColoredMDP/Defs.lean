import LeanProofs.Common.MDPValues

/-!
# Colored MDPs

A *colored MDP* `C = (M, V, κ)` represents a (finite) family of Markov chains that share a
state space. Its parts are:

* an MDP `M` (Aurora's `MDP State Act`);
* a parameter space `V : Set Θ` of admissible assignments `θ`;
* a coloring `κ s α ⊆ Θ`, the assignments under which action `α` exists in state `s`.

Every `θ ∈ V` selects exactly one available action in every state. The *induced MDP* `C[η]`
keeps only the actions whose color meets a set of assignments `η ⊆ V`. For a single assignment
`θ ∈ V`, `C[{θ}]` is the Markov chain described by `θ`.

## References

* Heck, Macák, Češka, Junges: *Constrained and Robust Policy Synthesis with
  Satisfiability-Modulo-Probabilistic-Model-Checking*, arXiv:2511.08078, Definitions 2 and 3.
  This file follows that set-based definition.
* Andriushchenko, Češka, Macák, Junges, Katoen: *An Oracle-Guided Approach to Constrained Policy
  Synthesis Under Uncertainty*, JAIR 82 (2025), Definition 1. There colors are partial parameter
  assignments, which is the special case `κ s α = {θ | θ is compatible with the partial
  assignment of (s, α)}`.

## Main definitions

* `LeanProofs.ColoredMDP State Act Θ`: a colored MDP with assignments of type `Θ`.
* `ColoredMDP.induced C η`: the induced MDP `C[η]` for a nonempty `η ⊆ C.V`.
* `ColoredMDP.inducedMC C θ`: the induced Markov chain `C[{θ}]` for `θ ∈ C.V`.
* `ColoredMDP.action C θ s`: the unique action that `θ` selects in state `s`.
* `ColoredMDP.reachProb C θ T s`, `ColoredMDP.expCost C θ c s`: the (unique) reachability
  probability and expected total cost of the induced Markov chain `C[{θ}]`, i.e. `P^{M_θ}` and
  `E^{M_θ}` in the papers.
* `ColoredMDP.policy C θ`: the memoryless policy of the underlying MDP that follows `θ`
  (a *consistent* policy, JAIR Section 3.1).
-/

namespace LeanProofs

open MDP

/-- A **colored MDP** `(M, V, κ)` (arXiv:2511.08078, Definition 2). The coloring `κ s α` is the set
of assignments under which action `α` exists in state `s`. Every admissible assignment `θ ∈ V`
selects exactly one available action in every state. -/
structure ColoredMDP (State Act Θ : Type*) where
  /-- The underlying MDP. -/
  M : MDP State Act
  /-- The (constrained) parameter space: the admissible assignments. -/
  V : Set Θ
  /-- The coloring: `κ s α` is the set of assignments under which `α` exists in `s`. -/
  κ : State → Act → Set Θ
  /-- Every admissible assignment selects exactly one available action in every state. -/
  existsUnique_act : ∀ θ ∈ V, ∀ s, ∃! α, α ∈ M.act s ∧ θ ∈ κ s α

namespace ColoredMDP

variable {State Act Θ : Type*} (C : ColoredMDP State Act Θ)

/-- The unique action that the admissible assignment `θ` selects in state `s`. -/
noncomputable def action {θ : Θ} (hθ : θ ∈ C.V) (s : State) : Act :=
  (C.existsUnique_act θ hθ s).exists.choose

theorem action_spec {θ : Θ} (hθ : θ ∈ C.V) (s : State) :
    C.action hθ s ∈ C.M.act s ∧ θ ∈ C.κ s (C.action hθ s) :=
  (C.existsUnique_act θ hθ s).exists.choose_spec

theorem action_unique {θ : Θ} (hθ : θ ∈ C.V) {s : State} {α : Act}
    (hα : α ∈ C.M.act s) (hθα : θ ∈ C.κ s α) : α = C.action hθ s :=
  (C.existsUnique_act θ hθ s).unique ⟨hα, hθα⟩ (C.action_spec hθ s)

open scoped Classical in
/-- The **induced MDP** `C[η]` (arXiv:2511.08078, Definition 3): the largest sub-MDP of `C.M`
that keeps an action `α` in state `s` exactly when its color meets `η`, i.e. when
`η ∩ κ s α ≠ ∅`. Here `η` must be a nonempty set of admissible assignments. -/
noncomputable def induced (η : Set Θ) (hη : η ⊆ C.V) (hne : η.Nonempty) : MDP State Act where
  P s α := if (η ∩ C.κ s α).Nonempty then C.M.P s α else none
  exists_P_isSome s := by
    obtain ⟨θ, hθ⟩ := hne
    obtain ⟨hact, hκ⟩ := C.action_spec (hη hθ) s
    refine ⟨C.action (hη hθ) s, ?_⟩
    rw [if_pos ⟨θ, hθ, hκ⟩]
    exact hact

/-- The **induced Markov chain** `C[{θ}]` of an admissible assignment `θ ∈ V`. -/
noncomputable def inducedMC {θ : Θ} (hθ : θ ∈ C.V) : MDP State Act :=
  C.induced {θ} (Set.singleton_subset_iff.mpr hθ) (Set.singleton_nonempty θ)

/-- The **reachability probability of the induced Markov chain**, `P^{M_θ}_s[◇T]`, for an
admissible assignment `θ`. `C[{θ}]` is a Markov chain (`isMarkovChain_inducedMC`), so it has
no nondeterminism and a single value; here it is read off with the default policy. It equals
both `Pmin` and `Pmax` of `C[{θ}]` (`reachProb_eq_Pmin`, `reachProb_eq_Pmax`). -/
noncomputable def reachProb {θ : Θ} (hθ : θ ∈ C.V) (T : Set State) (s : State) : ENNReal :=
  (C.inducedMC hθ).ReachProb (C.inducedMC hθ).defaultPolicy T s

/-- The **expected total cost of the induced Markov chain**, `E^{M_θ}_s[total cost]`, for an
admissible assignment `θ`. As for `reachProb`, `C[{θ}]` has a single value; it equals both
`Vmin` and `Vmax` of `C[{θ}]` (`expCost_eq_Vmin`, `expCost_eq_Vmax`). -/
noncomputable def expCost {θ : Θ} (hθ : θ ∈ C.V) (c : C.M.Costs) (s : State) : ENNReal :=
  ⨆ n, (C.inducedMC hθ).EC c (C.inducedMC hθ).defaultPolicy n s

/-- The memoryless policy of the underlying MDP that follows the admissible assignment `θ`.
These are the *consistent* policies of JAIR Section 3.1. -/
noncomputable def policy {θ : Θ} (hθ : θ ∈ C.V) : 𝔏[C.M] :=
  MScheduler.mk' (C.action hθ) (fun s ↦ (C.action_spec hθ s).1)

end ColoredMDP

end LeanProofs
