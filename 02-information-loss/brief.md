# Fisher Information Loss from Masking

## Status: Idea stage

## Motivation

Under C1-C2-C3, the masking distribution drops out of the likelihood — but
it does NOT drop out of the Fisher information. The amount of information
about theta per observation depends on how much masking occurs, even though
the likelihood function itself doesn't depend on the masking mechanism.

This creates a paradox for practitioners: the MLE is the same regardless of
the masking level (the likelihood is invariant), but the precision of the
MLE depends critically on how much masking is present (the information
changes). This paper would formalize and quantify this phenomenon.

## Core Result Sketch

### Information Decomposition

For a single exact-failure observation with candidate set c:

```
I_masked(theta) = I_complete(theta) - Delta(theta, pi)
```

where:
- I_complete(theta) = Fisher information with known cause (singleton c = {K})
- Delta(theta, pi) >= 0 is the information loss due to masking
- pi is the distribution over candidate sets

### Key Properties

1. Delta = 0 when all candidate sets are singletons (no masking)
2. Delta is maximized when c = {1, ..., m} always (complete masking)
3. Delta depends on how "spread out" the hazard is across candidate set members
4. For exponential components, closed-form Delta

### Exponential Case (Closed Form)

The complete-data Fisher information for exponential series is known
(see expo-masked-fim paper). The masked-data information involves the
candidate-set-weighted harmonic mean of rates. The difference gives
an explicit information loss formula.

### Effective Sample Size

Define n_eff = n * (I_masked / I_complete). This tells practitioners:
"your n masked observations are worth n_eff unmasked observations."
Gives immediate practical guidance for sample size planning.

## Connection to Foundation Paper

The foundation paper's identifiability theorem
(Theorem on Identifiability) gives the binary condition. This paper provides
the continuous version: not just "is theta identifiable?" but "how precisely
can theta be estimated, as a function of the masking distribution?"

## Connection to expo-masked-fim

The `expo-masked-fim` paper already derives the Fisher information matrix for
exponential components. This paper would:
1. Generalize to arbitrary parametric families
2. Decompose into complete-data vs masking-loss components
3. Add the study design / effective sample size interpretation

## Open Questions

- Is there a clean matrix inequality I_masked <= I_complete in the Loewner order?
- Can we characterize the masking distribution that minimizes information loss
  for a given expected candidate set size?
- Connection to missing data theory (Little & Rubin): masking as a specific
  missing data mechanism, information loss analogous to fraction of missing
  information

## Target Venue

- **Primary**: Biometrika (theoretical, clean result)
- **Alternative**: Lifetime Data Analysis

## Estimated Effort

Medium. Exponential case is tractable; general case requires careful matrix
analysis. Simulation study to validate the approximations.
