import MDP

/-!
# Values of MDPs: expected total cost and reachability

Optimal values over **memoryless** policies, as used in the colored-MDP papers:

* `MDP.Vmin`, `MDP.Vmax`: minimal and maximal expected total cost, using Aurora's `MDP.EC`.
* `MDP.ReachProb`: the probability that a scheduler's paths from `s` reach a target set `T`.
* `MDP.Pmin`, `MDP.Pmax`: minimal and maximal reachability probability.

## Definition of reachability

`M.ReachProbN 𝒮 T n s` sums `Prob_𝒮(π)` over the paths `π` of `n + 1` states from `s` that
visit `T`, i.e. the probability of visiting `T` within `n` steps. The probability of eventually
visiting `T` is the supremum over `n`. The paths of each length carry total probability 1
(`MDP.Path.tsum_Prob_eq_one`), so this is the textbook notion (Baier & Katoen, *Principles of Model
Checking*, Section 10.1). Lemmas that pin it down, such as the Bellman characterization, are
in `LeanProofs/Common/MDPValuesLemmas.lean`.
-/

namespace MDP

variable {State Act : Type*} (M : MDP State Act)

/-- `M` is a **Markov chain** (MC): every state has exactly one available action. This is the
definition of JAIR Section 2.1.2 and arXiv:2511.08078 Definition 1 ("an MDP with `|Act(s)| = 1`
for all `s`").

Aurora's `MarkovChain` is a different, standalone type (a transition distribution per state,
with a path measure); it is not used here. -/
structure IsMarkovChain : Prop where
  /-- Every state has exactly one available action. -/
  existsUnique_act : ∀ s, ∃! α, α ∈ M.act s

/-- A fixed memoryless policy of `M` (some available action in every state). On a Markov chain
it is the only policy, so it can be used to read off the chain's values. -/
noncomputable def defaultPolicy : 𝔏[M] :=
  MScheduler.mk' M.default_act M.default_act_spec

/-- Minimal expected total cost from `s` over memoryless policies:
`V^min(M)(s) = ⨅ σ, E^{M[σ]}_s[total cost]`. -/
noncomputable def Vmin (c : M.Costs) (s : State) : ENNReal :=
  ⨅ ℒ : 𝔏[M], ⨆ n, M.EC c ℒ n s

/-- Maximal expected total cost from `s` over memoryless policies:
`V^max(M)(s) = ⨆ σ, E^{M[σ]}_s[total cost]`. -/
noncomputable def Vmax (c : M.Costs) (s : State) : ENNReal :=
  ⨆ ℒ : 𝔏[M], ⨆ n, M.EC c ℒ n s

open scoped Classical in
/-- Probability under scheduler `𝒮` that a path from `s` visits `T` within its first `n + 1`
states, i.e. within `n` steps. -/
noncomputable def ReachProbN (𝒮 : 𝔖[M]) (T : Set State) (n : ℕ) (s : State) : ENNReal :=
  ∑' π : Path[M,s,=n+1], if ∃ x ∈ π.val.states, x ∈ T then π.val.Prob 𝒮 else 0

/-- Probability under scheduler `𝒮` of eventually reaching `T` from `s`, `P^𝒮_s(◇T)`. -/
noncomputable def ReachProb (𝒮 : 𝔖[M]) (T : Set State) (s : State) : ENNReal :=
  ⨆ n, M.ReachProbN 𝒮 T n s

/-- Minimal reachability probability over memoryless policies, `P^min_s(◇T)`. -/
noncomputable def Pmin (T : Set State) (s : State) : ENNReal :=
  ⨅ ℒ : 𝔏[M], M.ReachProb ℒ T s

/-- Maximal reachability probability over memoryless policies, `P^max_s(◇T)`. -/
noncomputable def Pmax (T : Set State) (s : State) : ENNReal :=
  ⨆ ℒ : 𝔏[M], M.ReachProb ℒ T s

end MDP
