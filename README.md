# Companion Research Directions for Masked Series Systems

Research ideas, ablation studies, and companion paper drafts building on the
foundation paper:

> Towell, A. (2025). *Masked Causes of Failure in Series Systems: A Likelihood
> Framework.* [arXiv/Zenodo forthcoming]

## Ecosystem Map

```
                    Foundation Paper
                  (distribution-agnostic
                   C1-C2-C3 likelihood)
                          |
          +---------------+---------------+
          |               |               |
    Identifiability   Information     Observation
    & Separability    Loss from       Scheme
    (this repo)       Masking         Composition
                      (this repo)     (this repo)
          |
          +-------+-------+-------+
          |       |       |       |
        Expo    Weibull  Model   Other
        Case    Case     Select  Families
        (done)  (planned)(paper) (planned)
```

### Existing Papers/Repos

| Paper | Repo | Status |
|-------|------|--------|
| Foundation (C1-C2-C3 framework) | [`masked-causes-in-series-systems`](../masked-causes-in-series-systems) | Draft complete |
| Exponential case (closed-form FIM) | [`expo-masked-fim`](../expo-masked-fim) | Draft complete |
| Model selection (LRT, nesting chain) | [`masked-series-model-selection`](../masked-series-model-selection) | Paper + simulations; software folded into `maskedcauses` vignette |
| Master's project (original Weibull treatment) | [`reliability-estimation-in-series-systems`](../reliability-estimation-in-series-systems) | Published |
| Relaxed C1/C2/C3 conditions | [`mdrelax/paper`](../../rlang/mdrelax/paper) | Draft |

### R Package Stack

```
flexhaz --> serieshaz --> maskedhaz
                              |
                        maskedcauses       mdrelax
```

For the full ecosystem map (all papers, packages, dependencies, and local
paths), see [ECOSYSTEM.md](ECOSYSTEM.md).

## Research Directions in This Repo

Each directory contains a research brief, literature notes, and (eventually)
draft content.

| Directory | Working Title | Novelty | Effort |
|-----------|---------------|---------|--------|
| [`identifiability-info-loss/`](identifiability-info-loss/) | Identifiability and Information Loss in Masked Series Systems | High | Medium |
| [`observation-composition/`](observation-composition/) | Composable Observation Schemes for Masked Reliability Data | Medium | Low |
| [`nesting-vs-structure/`](nesting-vs-structure/) | Statistical Parsimony vs Physical Structure in Series System Modeling | Medium | Low |
| [`weibull-masked-fim/`](weibull-masked-fim/) | Closed-Form FIM for Weibull Series with Masked Failure Causes | Medium | High |
| [`deterministic-masking/`](deterministic-masking/) | Information Recovery under Deterministic Masking | — | — |

## How to Use This Repo

1. Each research direction has a `brief.md` with the core idea, scope, and open questions
2. As ideas mature, they get promoted to their own paper repo
3. Cross-reference the foundation paper's theorems and notation throughout
