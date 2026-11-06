# Example paper: formalization progress

Source: none (this folder demonstrates the layout and is the Aurora smoke test).

| Item | Lean declaration | File | Status | Notes |
|---|---|---|---|---|
| Def. 1 (Sec. 2) | `MDP` (Aurora) | — | defined | reused from Aurora |
| Thm. 2 (Sec. 2) | `LeanProofs.Example.optimal_cost_eq_lfp` | Basic.lean | proved | restates `MDP.iSup_iInf_EC_eq_lfp_Φ𝒟` |
| Def. 1 (Sec. 3) | `pGCL` (Aurora) | — | defined | reused from Aurora |
| Lemma 3 (Sec. 3) | `LeanProofs.Example.wp_skip_seq_skip` | Basic.lean | proved | `simp` with `wp.seq_apply`, `wp.skip_apply` |

Status: stated (has `sorry`, ready to prove) · in progress · proved · blocked · false

## Log
### 2026-11-05 (setup)
- Created the example layout.
