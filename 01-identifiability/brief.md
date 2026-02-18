# Identifiability and Diagnostic Design for Masked Series Systems

## Status: Active research

## Motivation

The foundation paper (Theorem on Identifiability) establishes necessary and
sufficient conditions for when component parameters can be recovered from
masked series system data under C1-C2-C3. But the theorem is a binary
yes/no — it doesn't address:

- **How much** diagnostic separation is needed for practical identifiability
  (finite-sample, not just asymptotic)
- **Which** candidate set structures are most informative
- **How** identifiability degrades gracefully as masking increases

This paper would provide the full treatment: formal results, simulation
ablation studies, and practical design guidance.

## Core Results to Develop

### 1. Graph-Theoretic Characterization

Define the **confounding graph** G = (V, E) where V = {1, ..., m} (components)
and (j, j') in E iff j and j' are diagnostically confounded (always co-occur
in every candidate set). Then:

- theta is identifiable iff G has no edges
- Each connected component of G corresponds to a "super-component" whose
  internal allocation is unresolvable
- The number of identifiable parameters = p - (parameters lost to confounding)

### 2. Candidate-Set Matrix Rank (Exponential Case)

For exponential components, identifiability reduces to linear algebra:

- Candidate-set matrix C in {0,1}^{|S| x m}, augmented with all-ones row
  (from survival contribution)
- theta identifiable iff rank([C; 1^T]) = m
- This gives exact conditions checkable from data

### 3. Near-Non-Identifiability and Profile Likelihood

When separability barely holds (e.g., component j appears alone in only 1%
of observations), the profile likelihood is nearly flat. Characterize:

- Ridge ratio: eigenvalue ratio of observed Fisher information
- Practical non-identifiability threshold
- Relationship between singleton frequency and estimation precision

### 4. Ablation Studies (Simulation)

Systematic experiments varying:

- Masking probability p (0 to 1)
- Number of components m (2 to 10)
- Candidate set structure (random uniform, hierarchical/nested, block)
- Sample size n (50 to 10000)
- Distribution family (exponential, homogeneous Weibull, heterogeneous Weibull)

Response variables:
- MLE bias and MSE
- Fisher information eigenvalue spectrum
- Convergence rate of optimizer
- Coverage of confidence intervals

### 5. Optimal Diagnostic Design

Given a budget constraint on diagnostic effort, which candidate set
distribution maximizes the Fisher information? This is a design-of-experiments
problem:

- More singletons = more information per observation, but higher diagnostic cost
- Tradeoff between diagnostic resolution and sample size
- Possibly related to optimal experimental design (D-optimality)

## Connection to expo-masked-fim (Proposition 2.6)

The expo-masked-fim paper now proves two results directly relevant to this work:

1. **Monotone information loss:** I(K; C_w) is strictly decreasing in w under
   uniform masking, via K → C_w → C_{w+1} Markov chain + data processing
   inequality. This provides a formal version of "how identifiability degrades
   gracefully as masking increases" (Motivation, bullet 3 above).

2. **Max-entropy characterization:** Uniform masking maximizes H(C|K) among
   C2 models. Combined with the monotonicity result, this means that uniform
   masking at w = m-1 is the *most pessimistic identifiable* scenario. The
   optimal diagnostic design problem (Section 5 above) is therefore: what
   candidate set distribution *minimizes* information loss? The expo paper
   establishes the worst case; this paper should establish the best case.

The closed-form I(K; C) = ln(m/w) under equal rates also gives a baseline
for the ablation studies: departures from equal rates will change I(K; C),
and the deviation quantifies how much the rate heterogeneity itself aids
identification.

## Open Questions

- Does the heterogeneous Weibull remain identifiable under complete masking
  (all candidate sets = {1,...,m}) when shapes are distinct? The power-function
  argument suggests yes, but need formal proof.
- What is the minimax-optimal candidate set distribution?
- Connection to compressed sensing / sparse recovery?
- How does the mutual information I(K; C) relate to the Fisher information
  about θ? The expo paper provides both quantities; a unified theory would
  clarify when "more informative diagnostics" (higher I(K;C)) translates to
  "more precise estimation" (higher FIM eigenvalues).

## Target Venue

- **Primary**: Journal of Statistical Planning and Inference (design focus)
- **Alternative**: Technometrics (practical design guidance)

## Dependencies

- Foundation paper: Theorem (Identifiability), Definition (Separability)
- R package: `maskedcauses` for simulation infrastructure

## Estimated Effort

Medium. The theoretical results are mostly sketched; the main work is the
simulation study and the optimal design section.
