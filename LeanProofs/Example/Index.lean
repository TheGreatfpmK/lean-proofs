import Paper.Syntax
import LeanProofs.Example.Basic

/-!
# Example paper: index

Maps the numbered definitions, lemmas and theorems of the paper to Lean declarations, using
Aurora's `Paper.Syntax` (the same mechanism as Aurora's `Paper/ITP26.lean`):

    Section <s>, Theorem <n>: <term>

declares `Section<s>.Theorem<n>`, which type-checks `<term>`. A missing or renamed declaration
breaks the build. Readers can jump from each entry to the formal statement.
-/

namespace LeanProofs.Example.Index

set_option linter.unusedSectionVars false

open Optimization.Notation pGCL

variable {State Act : Type*} [DecidableEq State] {M : MDP State Act} [M.FiniteBranching]
  (c : M.Costs)
variable {𝒱 : Type*} [DecidableEq 𝒱] {Γ : Γ[𝒱]}

/-! ## Section 2 – Preliminaries -/

Section 2, Definition 1: MDP
Section 2, Theorem 2: LeanProofs.Example.optimal_cost_eq_lfp (M := M) c

/-! ## Section 3 – Programs -/

Section 3, Definition 1: pGCL Γ
Section 3, Lemma 3: LeanProofs.Example.wp_skip_seq_skip (Γ := Γ) 𝒟

end LeanProofs.Example.Index
