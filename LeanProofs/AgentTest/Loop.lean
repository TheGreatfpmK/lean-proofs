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
  sorry

/-- **Test 5.** Lower bound: the expected cost is at least 3/2 when the loop runs. -/
theorem geo_ge_three_halves (O : Optimization) :
    (fun σ ↦ if 0 < σ "x" then 3 / 2 else 0) ≤ wp[O]⟦@geo⟧ 0 := by
  sorry

/-- **Test 6.** Upper bound: the expected cost is at most 1 when the loop runs, else 0. -/
theorem geo_le_one (O : Optimization) :
    wp[O]⟦@geo⟧ 0 ≤ fun σ ↦ if 0 < σ "x" then 1 else 0 := by
  sorry

end LeanProofs.AgentTest
