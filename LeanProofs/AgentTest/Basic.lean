import MDP
import PGCL

/-!
# Agent test: three small statements

An end-to-end test of the proving setup (agent on the build server, `scripts/lean`, MCP tools,
commits). The statements are known to be provable and get progressively harder:

1. `wp_tick_seq_tick`: unfolding `wp` on straight-line code.
2. `wp_coin_cost`: `wp` of a probabilistic choice, then a little `ENNReal` arithmetic.
3. `oec_mono`: Aurora's optimal expected cost is monotone in the cost function.
-/

namespace LeanProofs.AgentTest

open Optimization.Notation pGCL

section PGCL

variable {𝒱 : Type*} [DecidableEq 𝒱] {Γ : Γ[𝒱]}

/-- **Test 1.** Paying 1 and then 2 adds 3 to any post-expectation `X`, under either resolution
of nondeterminism. -/
theorem wp_tick_seq_tick (O : Optimization) (X : 𝔼[Γ, ENNReal]) :
    wp[O]⟦tick(1) ; tick(2)⟧ X = 3 + X := by
  funext σ
  simp [pGCL.wp]
  ring

/-- **Test 2.** A fair coin decides whether to pay 1 or 3; the expected cost is 2. -/
theorem wp_coin_cost (O : Optimization) :
    wp[O]⟦{ tick(1) } [2⁻¹] { tick(3) }⟧ (0 : 𝔼[Γ, ENNReal]) = 2 := by
  funext σ
  simp [pGCL.wp, ProbExp.inv]
  ring_nf
  rw [show (4 : ENNReal) = 2 * 2 by norm_num, ← mul_assoc,
    ENNReal.inv_mul_cancel (by norm_num) (by norm_num), one_mul]

end PGCL

section MDP

variable {State Act : Type*} {M : MDP State Act}

/-- **Test 3.** Increasing the costs cannot decrease the optimal expected total cost
`M.OEC c s = ⨅ 𝒮, ⨆ n, M.EC c 𝒮 n s`. -/
theorem oec_mono {c c' : M.Costs} (h : c ≤ c') : M.OEC c ≤ M.OEC c' := by
  intro s
  refine le_iInf fun 𝒮 ↦ iInf_le_of_le 𝒮 ?_
  refine iSup_mono fun n ↦ ENNReal.tsum_le_tsum fun π ↦ ?_
  simp only [MDP.Path.ECost, MDP.Path.Cost]
  gcongr
  exact List.sum_le_sum fun a _ ↦ h a

end MDP

end LeanProofs.AgentTest
