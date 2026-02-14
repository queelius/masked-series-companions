# Composable Observation Schemes for Masked Reliability Data

## Status: Idea stage

## Motivation

The R package `maskedcauses` implements composable observation
functors: `observe_right_censor()`, `observe_left_censor()`,
`observe_periodic()`, and `observe_mixture()`. The `observe_mixture()` functor
takes arbitrary observation schemes and randomly assigns each unit to one,
modeling heterogeneous monitoring environments.

This software design embodies a mathematical principle that hasn't been
formalized: the C1-C2-C3 conditions are properties of the masking mechanism,
and they are preserved under composition with independent censoring schemes.
This means practitioners can mix and match observation protocols without
re-deriving the likelihood each time.

## Core Result Sketch

### Formal Setup

Define an **observation scheme** as a measurable map:

```
O: (complete data) -> (observed data)
O: (T_1, ..., T_m, K) -> (s, omega, c)
```

where (s, omega, c) is the observed tuple (time info, observation type,
candidate set).

### Closure Theorems

**Theorem (Mixture closure):**
If O_1, ..., O_k are observation schemes satisfying C1-C2-C3, and
pi_1, ..., pi_k are mixing weights (sum to 1), then the mixture scheme
O_mix (which applies O_j with probability pi_j, independently of
component lifetimes) also satisfies C1-C2-C3.

**Theorem (Censoring composition):**
If O is an observation scheme satisfying C1-C2-C3, and C is a censoring
mechanism that depends only on the system lifetime T (not on K or the
candidate set), then the composition C . O satisfies C1-C2-C3.

### Implications

1. Heterogeneous monitoring environments (some units monitored continuously,
   others inspected periodically) can be analyzed in a single likelihood
2. The observation scheme is a parameter of the model, not a structural
   assumption — practitioners configure it at analysis time
3. The software design (composable functors) is mathematically justified

## Connection to Foundation Paper

The foundation paper derives the likelihood for four observation types
separately. This paper shows they're all instances of a single abstract
construction, and that new observation types can be added without
re-deriving the theory.

## Open Questions

- Is there a category-theoretic formulation? (Observation schemes as morphisms
  in a category of data-reduction maps)
- Can we characterize ALL observation schemes satisfying C1-C2-C3?
- Information ordering: when does O_1 dominate O_2 in the Blackwell sense?

## Target Venue

- **Primary**: Statistics and Computing (software + theory)
- **Alternative**: Short communication in JRSS-B or Annals of Statistics

## Estimated Effort

Low for the closure theorems (proofs are straightforward).
Medium if adding the information ordering / Blackwell dominance results.
