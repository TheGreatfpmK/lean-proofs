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
  classical
  ext α
  simp only [MDP.act, inducedMC, induced, Set.mem_setOf_eq, Set.mem_singleton_iff,
    Set.singleton_inter_nonempty]
  split_ifs with hκ
  · exact ⟨fun hact ↦ C.action_unique hθ hact hκ, fun h ↦ h ▸ (C.action_spec hθ s).1⟩
  · simp only [Option.isSome_none, Bool.false_eq_true, false_iff]
    exact fun h ↦ hκ (h ▸ (C.action_spec hθ s).2)

/-- `C[{θ}]` is a Markov chain in the sense of `MDP.IsMarkovChain`. -/
theorem isMarkovChain_inducedMC : (C.inducedMC hθ).IsMarkovChain := by
  refine ⟨fun s ↦ ?_⟩
  rw [C.act_inducedMC hθ s]
  simp

/-- `C.reachProb` is the minimal reachability probability of `C[{θ}]`; on a Markov chain this
is its only value. -/
theorem reachProb_eq_Pmin (T : Set State) (s : State) :
    C.reachProb hθ T s = (C.inducedMC hθ).Pmin T s := by
  exact le_antisymm
    (le_iInf fun ℒ ↦ (C.isMarkovChain_inducedMC hθ).scheduler_eq
      (C.inducedMC hθ).defaultPolicy ℒ ▸ le_rfl)
    (iInf_le _ (C.inducedMC hθ).defaultPolicy)

/-- `C.reachProb` is the maximal reachability probability of `C[{θ}]`; on a Markov chain this
is its only value. -/
theorem reachProb_eq_Pmax (T : Set State) (s : State) :
    C.reachProb hθ T s = (C.inducedMC hθ).Pmax T s := by
  calc
    C.reachProb hθ T s = (C.inducedMC hθ).Pmin T s := C.reachProb_eq_Pmin hθ T s
    _ = (C.inducedMC hθ).Pmax T s := (C.isMarkovChain_inducedMC hθ).Pmin_eq_Pmax T s

/-- `C.expCost` is the minimal expected total cost of `C[{θ}]`. -/
theorem expCost_eq_Vmin (c : C.M.Costs) (s : State) :
    C.expCost hθ c s = (C.inducedMC hθ).Vmin c s := by
  exact le_antisymm
    (le_iInf fun ℒ ↦ (C.isMarkovChain_inducedMC hθ).scheduler_eq
      (C.inducedMC hθ).defaultPolicy ℒ ▸ le_rfl)
    (iInf_le _ (C.inducedMC hθ).defaultPolicy)

/-- `C.expCost` is the maximal expected total cost of `C[{θ}]`. -/
theorem expCost_eq_Vmax (c : C.M.Costs) (s : State) :
    C.expCost hθ c s = (C.inducedMC hθ).Vmax c s := by
  exact (C.expCost_eq_Vmin hθ c s).trans
    (MDP.IsMarkovChain.Vmin_eq_Vmax s (C.isMarkovChain_inducedMC hθ) c)

/-- View an induced-chain path as a path of the underlying MDP, with the same states. -/
private noncomputable def toUnderlying (π : (C.inducedMC hθ).Path) : C.M.Path where
  states := π.states
  nonempty := π.nonempty
  property := by
    classical
    intro i hi
    have h := π.property i hi
    simp only [MDP.succs_univ, MDP.succs, Set.mem_iUnion, Set.mem_setOf_eq] at h ⊢
    obtain ⟨α, hα⟩ := h
    refine ⟨α, ?_⟩
    by_cases hne : ({θ} ∩ C.κ π.states[i] α).Nonempty
    · simp only [inducedMC, induced] at hα
      rw [if_pos hne] at hα
      exact hα
    · simp only [inducedMC, induced] at hα
      rw [if_neg hne] at hα
      exact (hα rfl).elim

/-- Every scheduler of the induced chain chooses the action prescribed by `θ`. -/
private theorem scheduler_eq_action (𝒮 : 𝔖[C.inducedMC hθ]) (π : (C.inducedMC hθ).Path) :
    𝒮 π = C.action hθ π.last := by
  have h := 𝒮.property π
  rwa [C.act_inducedMC hθ π.last, Set.mem_singleton_iff] at h

/-- The induced chain and underlying MDP agree on the action prescribed by `θ`. -/
private theorem inducedMC_P_action (s s' : State) :
    (C.inducedMC hθ).P s (C.action hθ s) s' = C.M.P s (C.action hθ s) s' := by
  classical
  simp only [MDP.P_apply_eq]
  simp [inducedMC, induced, (C.action_spec hθ s).2]

/-- The raw path map commutes with taking prefixes. -/
private theorem toUnderlying_take (π : (C.inducedMC hθ).Path) (i : ℕ) :
    toUnderlying C hθ (π.take i) = (toUnderlying C hθ π).take i :=
  MDP.Path.ext_states rfl

/-- Transferring a path to the underlying MDP preserves its probability. -/
private theorem toUnderlying_prob (π : (C.inducedMC hθ).Path) (𝒮 : 𝔖[C.inducedMC hθ]) :
    (toUnderlying C hθ π).Prob (C.policy hθ) = π.Prob 𝒮 := by
  classical
  unfold MDP.Path.Prob
  apply Finset.prod_congr rfl
  intro i hi
  rw [← toUnderlying_take C hθ π i]
  rw [scheduler_eq_action C hθ 𝒮 (π.take i)]
  change C.M.P _ (C.action hθ (toUnderlying C hθ (π.take i)).last) _ =
    (C.inducedMC hθ).P _ (C.action hθ (π.take i).last) _
  rw [show (toUnderlying C hθ (π.take i)).last = (π.take i).last from rfl,
    MDP.Path.take_last']
  exact (inducedMC_P_action C hθ _ _).symm

/-- A path of nonzero probability under the consistent policy is also an induced-chain path. -/
private noncomputable def toInduced (π : C.M.Path) (hπ : π.Prob (C.policy hθ) ≠ 0) :
    (C.inducedMC hθ).Path where
  states := π.states
  nonempty := π.nonempty
  property := by
    intro i hi
    let j : Fin (‖π‖ - 1) := ⟨i, hi⟩
    have hstep : C.M.P π[j] (C.policy hθ (π.take j)) π[j.succ] ≠ 0 := by
      intro hzero
      apply hπ
      unfold MDP.Path.Prob
      exact Finset.prod_eq_zero (Finset.mem_univ j) hzero
    have hlast : (π.take j).last = π[j] := π.take_last' j
    change C.M.P π[j] (C.action hθ (π.take j).last) π[j.succ] ≠ 0 at hstep
    rw [hlast] at hstep
    simp only [MDP.succs_univ, MDP.succs, Set.mem_iUnion, Set.mem_setOf_eq]
    refine ⟨C.action hθ π[j], ?_⟩
    change (C.inducedMC hθ).P π[j] (C.action hθ π[j]) π[j.succ] ≠ 0
    rw [inducedMC_P_action]
    exact hstep

/-- Transfer a bounded induced-chain path to the underlying MDP. -/
private noncomputable def boundedToUnderlying {n : ℕ} {s : State}
    (π : Path[C.inducedMC hθ,s,=n]) : Path[C.M,s,=n] :=
  ⟨toUnderlying C hθ π.val, ⟨π.prop.1, π.prop.2⟩⟩

/-- Transfer a bounded underlying path of nonzero policy probability to the induced chain. -/
private noncomputable def boundedToInduced {n : ℕ} {s : State} (π : Path[C.M,s,=n])
    (hπ : π.val.Prob (C.policy hθ) ≠ 0) : Path[C.inducedMC hθ,s,=n] :=
  ⟨toInduced C hθ π.val hπ, ⟨π.prop.1, π.prop.2⟩⟩

/-- A weight-preserving map of bounded paths identifies sums on nonzero supports. -/
private theorem tsum_inducedMC {n : ℕ} {s : State}
    (F : Path[C.inducedMC hθ,s,=n] → ENNReal) (G : Path[C.M,s,=n] → ENNReal)
    (hmap : ∀ π, G (boundedToUnderlying C hθ π) = F π)
    (hprob : ∀ π, G π ≠ 0 → π.val.Prob (C.policy hθ) ≠ 0) :
    (∑' π, F π) = ∑' π, G π := by
  classical
  symm
  apply tsum_eq_tsum_of_ne_zero_bij fun x ↦ boundedToUnderlying C hθ x.val
  · intro x y hxy
    apply Subtype.ext
    apply Subtype.ext
    apply MDP.Path.ext_states
    exact congrArg (fun π : Path[C.M,s,=n] ↦ π.val.states) hxy
  · intro π hπ
    have hp := hprob π hπ
    let ρ : Path[C.inducedMC hθ,s,=n] := boundedToInduced C hθ π hp
    have hρ : boundedToUnderlying C hθ ρ = π := by
      apply Subtype.ext
      apply MDP.Path.ext_states
      rfl
    have hρ0 : F ρ ≠ 0 := by
      rw [← hmap ρ, hρ]
      exact hπ
    exact ⟨⟨ρ, hρ0⟩, hρ⟩
  · intro π
    exact hmap π.val

/-- The expected cost (within `n` steps) of the induced Markov chain `C[{θ}]`, under any of its
schedulers, equals that of the underlying MDP under the consistent policy of `θ`. -/
theorem EC_inducedMC (c : C.M.Costs) (𝒮 : 𝔖[C.inducedMC hθ]) (n : ℕ) (s : State) :
    (C.inducedMC hθ).EC c 𝒮 n s = C.M.EC c (C.policy hθ) n s := by
  classical
  simp only [MDP.EC]
  apply tsum_inducedMC C hθ
  · intro π
    change MDP.Path.ECost (M := C.M) c (C.policy hθ) (toUnderlying C hθ π.val) =
      MDP.Path.ECost (M := C.inducedMC hθ) c 𝒮 π.val
    unfold MDP.Path.ECost
    rw [toUnderlying_prob]
    rfl
  · intro π hπ hp
    apply hπ
    simp [MDP.Path.ECost, hp]

/-- Bounded reachability in the induced Markov chain `C[{θ}]`, under any of its schedulers,
equals bounded reachability in the underlying MDP under the consistent policy of `θ`. -/
theorem ReachProbN_inducedMC (𝒮 : 𝔖[C.inducedMC hθ]) (T : Set State) (n : ℕ) (s : State) :
    (C.inducedMC hθ).ReachProbN 𝒮 T n s = C.M.ReachProbN (C.policy hθ) T n s := by
  classical
  simp only [MDP.ReachProbN]
  apply tsum_inducedMC C hθ
  · intro π
    simp only [boundedToUnderlying]
    rw [toUnderlying_prob]
    rfl
  · intro π hπ hp
    apply hπ
    simp [hp]

end LeanProofs.ColoredMDP
