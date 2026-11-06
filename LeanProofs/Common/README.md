# LeanProofs.Common

Lemmas that are useful beyond a single paper: facts missing from Mathlib (e.g. about `ENNReal`,
`tsum`, fixed points) and extensions of Aurora. One file per topic, e.g. `Common/ENNReal.lean`
with `namespace LeanProofs.Common` (or the namespace of the type being extended, e.g. `ENNReal`,
if the lemma is a candidate for upstreaming). Every `.lean` file here is built automatically.
