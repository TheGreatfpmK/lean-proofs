import Paper.Syntax
import LeanProofs.OracleGuided.Theorem1

/-!
# JAIR 2025 (Oracle-guided policy synthesis): index

Maps the numbered items of the paper to Lean declarations (see `LeanProofs/Example/Index.lean`).
-/

namespace LeanProofs.OracleGuided.Index

set_option linter.unusedSectionVars false

variable {State Act Θ : Type*} (C : ColoredMDP State Act Θ)

/-! ## Section 2 – Problem Statement -/

/-- Coloured MDP, in the set-based form of arXiv:2511.08078 (Definition 2). -/
Section 2, Definition 1: ColoredMDP State Act Θ

/-! ## Section 3 – Abstraction Refinement -/

Section 3, Theorem 1: LeanProofs.OracleGuided.theorem1_reach C

end LeanProofs.OracleGuided.Index
