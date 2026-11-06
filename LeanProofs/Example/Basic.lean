import MDP
import PGCL

/-!
# Example paper: basic results

A minimal example of how a paper's formalization is laid out (see `AGENTS.md`):

* statements reuse Aurora's definitions (`MDP`, `pGCL`, `wp`, ...) instead of redefining them;
* every result is a named `theorem` whose docstring cites the paper item it formalizes;
* `Index.lean` maps the paper's numbering to these declarations, and `PROGRESS.md` tracks status.

It also serves as a smoke test that the Aurora dependency is built and importable.
-/

namespace LeanProofs.Example

open OrderHom Optimization.Notation pGCL

section MDP

variable {State Act : Type*} [DecidableEq State] {M : MDP State Act} [M.FiniteBranching]

/-- **Theorem 2** (example). For finitely branching MDPs, the demonic optimal expected cost
(minimizing scheduler, step bound pushed to the limit) is the least fixed point of the Bellman
operator. Restates Aurora's `MDP.iSup_iInf_EC_eq_lfp_Φ𝒟`. -/
theorem optimal_cost_eq_lfp (c : M.Costs) :
    ⨆ n, ⨅ 𝒮, M.EC c 𝒮 n = lfp (M.Φ 𝒟 c) :=
  MDP.iSup_iInf_EC_eq_lfp_Φ𝒟

end MDP

section PGCL

variable {𝒱 : Type*} [DecidableEq 𝒱] {Γ : Γ[𝒱]}

/-- **Lemma 3** (example). Running `skip` twice does not change the expected value of any
post-expectation, under either resolution of nondeterminism. -/
theorem wp_skip_seq_skip (O : Optimization) (X : 𝔼[Γ, ENNReal]) :
    wp[O]⟦skip ; skip⟧ X = X := by
  simp

end PGCL

end LeanProofs.Example
