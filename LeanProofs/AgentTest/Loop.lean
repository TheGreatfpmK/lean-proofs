import PGCL

/-!
# Agent test: a geometric loop

The program `geo` runs `while 0 < x { { x := 0 } [1/2] { skip } ; tick(1) }`: every round
costs 1 and ends the loop with probability 1/2. The statements below bound its expected total
cost `wp[O]⟦geo⟧ 0`.
-/

namespace LeanProofs.AgentTest

open Optimization.Notation pGCL

/-- Variables of the test programs; every variable holds an `ENNReal`. -/
abbrev Γg : String → Type := fun _ ↦ ENNReal

/-- The geometric loop: pay 1 per round, stop with probability 1/2. -/
noncomputable def geo : pGCL Γg :=
  pgcl { while 0 < x { { x := 0 } [2⁻¹] { skip } ; tick(1) } }

/-- **Test 4.** Upper bound: the expected cost is at most 2 when the loop runs, else 0. -/
theorem geo_le_two (O : Optimization) :
    wp[O]⟦@geo⟧ 0 ≤ fun σ ↦ if 0 < σ "x" then 2 else 0 := by
  apply ParkInduction
  intro σ
  by_cases h : 0 < σ "x"
  · simp [Ψ, h, Exp.const, BExpr.lt]
    ring_nf
    rw [show (4 : ENNReal) = 2 * 2 by norm_num, ← mul_assoc,
      ENNReal.inv_mul_cancel (by norm_num) (by norm_num), one_mul]
  · simp [Ψ, h, Exp.const, BExpr.lt]

/-- **Test 5.** Lower bound: the expected cost is at least 3/2 when the loop runs. -/
theorem geo_ge_three_halves (O : Optimization) :
    (fun σ ↦ if 0 < σ "x" then 3 / 2 else 0) ≤ wp[O]⟦@geo⟧ 0 := by
  simp only [geo, wp_loop_eq_iter]
  intro σ
  simp only [_root_.iSup_apply]
  refine le_iSup_of_le 2 ?_
  by_cases h : 0 < σ "x"
  · simp [Ψ, Function.iterate_succ_apply, h, Exp.const, BExpr.lt]
    have htwo : (2 : ENNReal)⁻¹ + 2⁻¹ = 1 := by
      rw [← two_mul, ENNReal.mul_inv_cancel] <;> norm_num
    have hthree : (3 / 2 : ENNReal) = 1 + 2⁻¹ := by
      rw [div_eq_mul_inv]
      calc
        3 * (2 : ENNReal)⁻¹ = 2⁻¹ + 2 * 2⁻¹ := by ring
        _ = 2⁻¹ + 1 := by rw [ENNReal.mul_inv_cancel] <;> norm_num
        _ = 1 + 2⁻¹ := add_comm _ _
    rw [htwo, hthree, show 1 + 1 = (2 : ENNReal) by norm_num,
      ENNReal.inv_mul_cancel (by norm_num) (by norm_num), add_comm]
  · simp [Ψ, Function.iterate_succ_apply, h, Exp.const, BExpr.lt]

/-- **Test 6.** Upper bound: the expected cost is at most 1 when the loop runs, else 0. -/
theorem geo_le_one (O : Optimization) :
    wp[O]⟦@geo⟧ 0 ≤ fun σ ↦ if 0 < σ "x" then 1 else 0 := by
  sorry

end LeanProofs.AgentTest
