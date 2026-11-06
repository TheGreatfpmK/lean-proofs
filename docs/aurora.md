# Aurora theory: quick reference for proving

The AuRoRA theory (<https://github.com/aurora-dtu/theory>, rendered docs at
<https://aurora-dtu.github.io/theory/>) is this project's base library. It is the Lake package
`pgcl`, pinned in `lake-manifest.json`. It uses Lean `v4.30.0-rc2` and brings its own pinned
Mathlib with it.

**Where the source is.** On a machine with a Lean build, it is at `.lake/packages/pgcl/`. On a
thin client, run commands against it through the wrapper. Check the source before trusting this
summary:

```bash
scripts/lean run grep -rn "theorem wp_" .lake/packages/pgcl/PGCL
scripts/lean run sed -n 100,140p .lake/packages/pgcl/PGCL/WeakestPre.lean
```

The docs site has one page per module, for example
`https://aurora-dtu.github.io/theory/PGCL/WeakestPre.html`.

## Imports

| import | brings in |
|---|---|
| `import MDP` | the MDP library (expected costs, schedulers, Bellman operators, counterexamples) |
| `import PGCL` | pGCL, `wp`/`wlp`/`wfp`, operational semantics, proof rules (imports the MDP core) |
| `import HeyVL` | HeyVL intermediate verification language, `vc[...]` and `vc_simp` |
| `import Paper.Syntax` | `Section 4, Theorem 12: term` paper-index commands |

Finer-grained imports are allowed, for example `import PGCL.WeakestPre` or `import MDP.OptimalCost`.

## Conventions you must know

- **Quantities live in `ENNReal` (`ℝ≥0∞`).** Costs, expectations and probabilities are
  `ENNReal`-valued functions. Function spaces into complete lattices are complete lattices, so
  `⨆`/`⨅`, `≤` and `⊥`/`⊤` are pointwise.
- **Monotone maps are `OrderHom`s (`α →o β`).** `wp[O]⟦C⟧ : 𝔼[Γ, ENNReal] →o 𝔼[Γ, ENNReal]`.
  Fixed points are `OrderHom.lfp`/`OrderHom.gfp`. Continuity is
  `OmegaCompletePartialOrder.ωScottContinuous`. Kleene iteration appears as
  `⨆ n, f^[n] ⊥`.
- **Aurora is compiled with `autoImplicit` ON. This project has it OFF.** Many Aurora lemmas
  have auto-bound implicit arguments, such as the cost function `c` in
  `MDP.iSup_iInf_EC_eq_lfp_Φ𝒟`. Lean usually infers them by unification; if not, pass them by
  name, for example `(c := c)`. In this repo's files, declare every variable explicitly with
  `variable`.
- **Optimization direction:** `open Optimization.Notation` gives `𝒜` (`Angelic`, sup/max) and
  `𝒟` (`Demonic`, inf/min). `O.dual` swaps them. `O.opt a b` and `O.iOpt f` are the binary and
  indexed sup/inf.
- Aurora's style uses `grind`, `gcongr`, `grw`, `simp` with `@[simp]` `_apply` lemmas, and
  `omega`. Many of its basic lemmas are tagged `@[grind]`.

## Notation (in scope after the imports; `open` as indicated)

| notation | meaning | defined in |
|---|---|---|
| `𝒜`, `𝒟` | `Optimization.Angelic` / `Demonic` (needs `open Optimization.Notation`) | `MDP/Optimization` |
| `𝔖[M]`, `𝔏[M]` | (history-dependent) schedulers / Markovian schedulers of MDP `M` | `MDP/Scheduler` |
| `𝔖[M,s,≤n]` | bounded schedulers | `MDP/BScheduler` |
| `‖π‖` | length of a path | `MDP/Paths/Defs` |
| `Path[M,s,=n]`, `Path[M,s,≤n]` | paths from `s` of length `= n` / `≤ n` | `MDP/Paths/Bounded` |
| `Γ[𝒱]` | typing context `𝒱 → Type*` (variable `x : 𝒱` holds values of type `Γ x`) | `PGCL/Exp` |
| `𝔼[Γ, α]` | expressions: `State Γ → α` | `PGCL/Exp` |
| `i[b]` | Iverson bracket (`1` if `b`, else `0`) | `PGCL/Exp` |
| `p[b]` | `BExpr` as a `ProbExp` | `PGCL/ProbExp` |
| `X[x ↦ e]` | substitution | `STDX/Subst` |
| `pgcl { ... }` | pGCL program syntax; `@C` splices a Lean term | `PGCL/pGCL` |
| `wp[O]⟦C⟧`, `wlp[O]⟦C⟧`, `wfp[O]⟦C⟧` | weakest (liberal / fault) pre-expectation | `PGCL/WeakestPre`, `WeakestLiberalPre` |
| `wlp'[O]⟦C⟧`, `wfp'[O]⟦C⟧` | the same on `ProbExp` (values in `[0,1]`) | `PGCL/WeakestLiberalPre` |
| `dwp⟦C⟧`, `awp⟦C⟧` | `wp[𝒟]`, `wp[𝒜]` | `PGCL/WeakestPre` |
| `cwp[O]⟦C⟧`, `ert[O]⟦C⟧` | conditional wp, expected runtime | `PGCL/ProofRules` |
| `Ψ[g] b X` | loop characteristic functional (`i[b] * g X + i[bᶜ] * f`) | `PGCL/WeakestPre` |
| `c ⤳[α,p] c'` | pGCL small-step relation | `PGCL/SmallStep` |
| `conf[C, σ]`, `conf[⊥]` | configurations of the operational MDP | `PGCL/Conf` |
| `vp⟦...⟧`, `vc[O, enc] {pre} C {post}` | HeyVL verification pre-expectations / VCs | `HeyVL/` |

pGCL program syntax: `skip`, `x := e`, `C₁ ; C₂`, `{ C₁ } [p] { C₂ }` (probabilistic choice),
`{ C₁ } [] { C₂ }` (nondeterministic choice), `while b { C }`, `tick(e)`, `observe(b)`,
`if b then C₁ else C₂ end`. Arithmetic uses `+ - * /` and `[b]`; Boolean expressions use
`< ≤ = ∧ ∨ ¬`.

## Main definitions

**MDP** (`namespace MDP`):
- `MDP State Act`: structure with `P : State → Act → Option (PMF State)`, where every state has
  an enabled action.
- `M.act s` (enabled actions), `M.succs α s`, `M.succs_univ s`, `M.prev ...`.
- `M.FiniteBranching`: a class asserting finitely many actions and successors.
- `M.Path` (non-empty state lists following transitions), `π.last`, `π.extend`, `π.take`,
  `π.Prob 𝒮`.
- `M.Costs := State → ENNReal`, `π.Cost c`, `π.ECost c 𝒮`.
- `M.EC c 𝒮 n s`: expected total cost of paths of length `n`. `M.OEC c s := ⨅ 𝒮, ⨆ n, M.EC c 𝒮 n s`.
- `M.Φ O c : M.Costs →o M.Costs`: Bellman operator (`dΦ = Φ 𝒟`, `aΦ = Φ 𝒜`). `M.Φℒ ℒ c` is
  the operator for a fixed Markovian scheduler. `Optimization.ΦContinuous O M`: continuity class.
- `MarkovChain`, `MarkovChain.Pr` (path measure), `M.inducedMC 𝒮 ι`.
- `SmallStepSemantics P S T A`: a generic small-step semantics with `.mdp`, `.cost`, `.op`
  (optimal expected cost as a transformer) and `.ξ`.

**pGCL** (`namespace pGCL`):
- `pGCL Γ`: an inductive with `skip | assign | seq | prob | nonDet | loop | tick | observe`.
- `State Γ`, `BExpr Γ := 𝔼[Γ, Prop]`, `ProbExp Γ := {e : 𝔼[Γ, ENNReal] // e ≤ 1}`.
- `wp O C`, `wlp O C`, `wfp O C` (and primed `ProbExp` versions), `AST C` (almost-sure
  termination), `cwp`, `ert`.
- `ParkInvariant`, `ParkKInvariant`, `IdleInvariant`, and their `Co`-variants.
- Operational side: `pGCL.Step`, `Conf₀/Conf₁`, `cost_t`, `cost_p`, `pGCL.𝒪`, and `pGCL.𝕊 f g`
  (the small-step semantics instance).

**HeyVL**: `HeyVL.Verifies C`, `Conditions E`, `Conditions.sound`, the `vc[...]` term syntax and
the `vc_simp` tactic. `HeyVL.lean` has a fully worked example (`NatLog.soundess`).

## Headline theorems (good to reuse)

- `MDP.iSup_iInf_EC_eq_lfp_Φ𝒟 [M.FiniteBranching] : ⨆ n, ⨅ 𝒮, M.EC c 𝒮 n = lfp (M.Φ 𝒟 c)`
- `MDP.iInf_iSup_EC_eq_lfp_Φ𝒟`, `MDP.iSup_iInf_EC_eq_iInf_iSup_EC`,
  `MDP.iInf_iSup_EC_eq_iInf_iSup_ECℒ`: min/limit commute, and Markovian schedulers suffice
  (finitely branching).
- `MDP.iInf_iSup_EC_comm_lfp_Φ𝒟_all_eq`: all five formulations of the optimal cost are equal.
- `MDP.iSup_iSup_EC_eq_lfp_Φ𝒜 [DecidableEq State]`: maximal expected cost as a least fixed point,
  with no finiteness assumption.
- `MDP.optℒ c`: an optimal Markovian scheduler. `MDP.lfp_Φℒ_eq_lfp_Φ`.
- `MDP.Counterexample.*`: why the finiteness assumptions are needed.
- `pGCL.wp_eq_op : wp[O]⟦@C⟧ = (𝕊 cost_t cost_p).op O C`: wp equals the operational optimal
  expected cost. Also `pGCL.wfp_eq_op`, `pGCL.iInf_iSup_EC_eq_wp`, `pGCL.iSup_iSup_EC_eq_wp`.
- `pGCL.wlp_sound : wlp'[O]⟦@C⟧ X = 1 - wfp'[O.dual]⟦@C⟧ (1 - X)`.
- `pGCL.wp_loop`, `pGCL.wp_fp`, `pGCL.wp_loop_eq_iter`, `pGCL.wlp_loop_eq_gfp`,
  `pGCL.wp.continuous`.
- Proof rules: `pGCL.ParkInduction` (`ParkInvariant wp[O]⟦@C⟧ b φ I → wp[O]⟦while @b {@C}⟧ φ ≤ I`),
  `ParkCoinduction`, `ParkKInduction`, `ParkKCoinduction`, `IdleInduction`, `IdleCoinduction`,
  `IdleKInduction`.
- Simp set for computing `wp`: `pGCL.wp.skip_apply`, `wp.assign_apply`, `wp.seq_apply`,
  `wp.prob_apply`, `wp.nonDet_apply`, `wp.tick_apply`, `wp.observe_apply`. Most are `rfl`.

## Proof tips specific to this setting

- **ENNReal arithmetic** is the usual pain point. Try `simp`, `gcongr`, `grw`, `positivity`,
  `ENNReal.mul_le_mul`, `ENNReal.add_le_add`, and `ENNReal.sub_*` lemmas, which need `≠ ⊤`
  side goals. As a last resort, move to `ℝ` with `ENNReal.toReal_le_toReal` and
  `ENNReal.toReal_add`, carrying `≠ ⊤` hypotheses. Aurora's `HeyVL.lean` (`NatLog.soundess`)
  and `MDP/ENNRealExt.lean` show working patterns.
- **Least fixed points:** upper bounds come from `OrderHom.lfp_le` (Park induction) and lower
  bounds from `OrderHom.le_lfp` or from the iteration `⨆ n, f^[n] ⊥` under ωScottContinuity
  (`MDP.lfp_Φ_eq_iSup_Φ`, `pGCL.wp_loop_eq_iter`). Unfold with `OrderHom.map_lfp`.
- **iSup/iInf over schedulers:** `iSup_le`, `le_iSup_of_le`, `iInf_le_of_le`, `le_iInf`,
  `iSup_comm`, `ENNReal.tsum_*`. For the Markovian-scheduler bookkeeping, look at
  `MDP/OptimalCost.lean`.
- **Pointwise goals** on `𝔼[Γ, ENNReal]` or `M.Costs`: `intro σ` or `funext σ` / `ext σ`, then
  `simp only [Pi.add_apply, ...]`.
- Before proving a general fact about `ENNReal`, `tsum`, lattices or fixed points, search
  Mathlib first. Then check Aurora's `MDP/ENNRealExt.lean`, `MDP/FinsetExt.lean` and
  `MDP/SetExt.lean`, which hold "to be upstreamed" lemmas.

## Paper index syntax (`import Paper.Syntax`)

```lean
Section 4, Definition 7: M.ECost          -- declares Section4.Definition7 : Link M.ECost
Section 4, Theorem 12: MDP.iSup_iSup_EC_eq_lfp_Φ𝒜 (M := M) (c := c)
Section 5, Lemma 25: ...
```

Each line must elaborate, so missing or renamed results break the build. Use it inside your own
namespace, for example `namespace LeanProofs.MyPaper.Index`, to avoid clashing with Aurora's
`Paper.Section*` names. See `LeanProofs/Example/Index.lean` and Aurora's `Paper/ITP26.lean`.
