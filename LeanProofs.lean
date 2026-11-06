/-!
# LeanProofs

Formalizations for several research projects, built on the AuRoRA theory
(<https://aurora-dtu.github.io/theory/>, Lake package `pgcl`, libraries `MDP`, `PGCL`, `HeyVL`,
`STDX`, `Paper`) and Mathlib.

Layout (see `AGENTS.md` for the conventions):

* `LeanProofs/<Project>/` — one folder per research project: definitions, statements, proofs,
  `PROGRESS.md` (status of every statement) and, once there is a paper, `Index.lean` (paper
  numbering → Lean declarations). Projects may import each other.
* `LeanProofs/Common/` — reusable lemmas shared by several projects.
* `LeanProofs/Example/` — a worked example of the layout; doubles as a smoke test for Aurora.

Every file under `LeanProofs/` is part of the library (`globs` in `lakefile.toml`), so
`lake build` checks all of them; this root file does not need to import them.
-/
