# Masked Causes in Series Systems: Research Ecosystem

This document maps the full research ecosystem — papers, R packages, and their
relationships — for the **masked series system reliability** program.

## Motivation

In reliability engineering, a *series system* fails when any one of its $m$
components fails. In practice, diagnostics often cannot pinpoint the exact
failed component — they return a *candidate set* of plausible causes. This is
the *masking problem*.

The research program develops a likelihood-based framework for estimating
component reliability from masked failure data. It spans:

- A **foundation paper** establishing the distribution-agnostic theory
- **Companion papers** exploring specific distributions, information loss,
  identifiability, and extensions
- A **layered R package ecosystem** implementing the theory at multiple levels
  of abstraction

---

## Papers

### Foundation

| Paper | Location | Status | Scope |
|-------|----------|--------|-------|
| **Masked Causes of Failure in Series Systems: A Likelihood Framework** | [`~/github/papers/masked-causes-in-series-systems`](../masked-causes-in-series-systems) | Draft complete | Distribution-agnostic C1–C2–C3 likelihood framework. Derives system reliability, cause-of-failure distributions, and likelihood contributions for all four observation types (exact, right-censored, left-censored, interval-censored). Five-family instantiation table. General MLE recipe. |

This is the central paper. It develops three conditions on masking (C1–C3)
under which the masking probability factors out of the likelihood, yielding a
tractable parametric MLE problem. All companion papers and software build on
its theorems and notation.

### Companions (Existing)

| Paper | Location | Status | Scope |
|-------|----------|--------|-------|
| **Statistical Inference for Series Systems from Masked Failure Time Data: The Exponential Case** | [`~/github/papers/expo-masked-fim`](../expo-masked-fim) | Draft complete | Closed-form MLE and Fisher information matrix for exponential components. Proves uniform masking maximizes conditional entropy among C2 models (max-entropy characterization) and that diagnostic informativeness $I(K;C_w)$ decreases monotonically in $w$ via data processing inequality. Sufficient statistics. Identifies exponential lifetimes + uniform masking at $w=m-1$ as the "doubly worst case" — maximum entropy in both the lifetime and masking dimensions. |
| **Reliability Estimation in Series Systems** | [`~/github/papers/reliability-estimation-in-series-systems`](../reliability-estimation-in-series-systems) | Published | Original Master's thesis. Weibull-specific treatment with bootstrap confidence intervals. Historical foundation for the research program. |
| **Model Selection for Masked Series Systems** | [`~/github/papers/masked-series-model-selection`](../masked-series-model-selection) | Paper + simulations; model selection tooling folded into `maskedcauses` vignette | Weibull nesting chain LRT (exponential ⊂ hom-shape Weibull ⊂ het Weibull), power analysis, practical guidelines. 500-rep Monte Carlo across multiple conditions. |
| **Relaxed Candidate Set Models for Masked Data in Series Systems** | [`~/github/rlang/mdrelax/paper`](../../rlang/mdrelax/paper) | Draft | Robustness analysis: what happens when C1, C2, or C3 are violated? Informative masking, parameter-dependent masking, imperfect diagnostics. |

### Companions (Planned)

These live as research briefs in the [`masked-series-companions`](./) repo:

| Directory | Working Title | Novelty |
|-----------|---------------|---------|
| [`weibull-masked-fim/`](weibull-masked-fim/) | Closed-Form FIM for Weibull Series with Masked Failure Causes | Closed-form Fisher information, masking invariance of shape info, rate-block decomposition. |
| [`deterministic-masking/`](deterministic-masking/) | Information Recovery under Deterministic Masking | Injective masking recovers complete-data FIM. Submitted to JSPI. |

---

## R Packages

### Architecture

The packages are organized in layers. Domain-specific reliability packages
build on general-purpose statistical infrastructure:

```
INFRASTRUCTURE                      RELIABILITY
                                    (domain-specific)

algebraic.dist ─────┐
  (distribution      │
   algebra)          │
                     ▼
algebraic.mle ──► likelihood.model ──► flexhaz
  (MLE algebra,      (loglik, score,    (hazard-based
   delta method,      fit generics)      distributions)
   bootstrap)                               │
                                            ▼
compositional.mle                       serieshaz
  (solver                               (series system
   composition)                          composition:
                                         h_sys = Σ h_j)
hypothesize                                 │
  (hypothesis                               ▼
   testing)                             maskedhaz
                                        (masked-cause
                                         likelihood,
                                         arbitrary h_j)
                                            │
                                            ▼
                                        maskedcauses
                                        (closed-form
                                         Exp/Weibull,
                                         high-level API)

                                        mdrelax
                                        (relaxed C1/C2/C3,
                                         robustness studies)

                                        Model selection is a
                                        maskedcauses vignette
                                        (LRT nesting chain)
```

### Reliability Packages (Domain-Specific)

These implement the theory from the foundation paper.

| Package | Location | What It Does | Key Idea |
|---------|----------|-------------|----------|
| **[flexhaz](https://github.com/queelius/flexhaz)** | `~/github/rlang/flexhaz` | Define component lifetime distributions by specifying the hazard function $h_j(t)$; reliability, density, quantiles, and sampling are derived automatically. | "Hazard-first" design: specify $h_j$, get everything else for free. Built-in: Exponential, Weibull, Gompertz, Log-logistic. |
| **[serieshaz](https://github.com/queelius/serieshaz)** | `~/github/rlang/serieshaz` | Compose $m$ flexhaz components into a series system. System hazard = sum of component hazards. | Compositional: series of series are series. Introspection: `component_hazard()`, `ncomponents()`. |
| **[maskedhaz](https://github.com/queelius/maskedhaz)** | `~/github/rlang/maskedhaz` | Likelihood inference for masked series data with **arbitrary** component distributions. Uses numerical integration for censored observations. | Generality: works with any flexhaz distribution under C1–C2–C3. Implements the foundation paper's general framework directly. |
| **[maskedcauses](https://github.com/queelius/maskedcauses)** | `~/github/rlang/maskedcauses` | Likelihood inference for masked series data with **closed-form** Exponential and Weibull models. High-level API with composable observation schemes. | Performance + usability: closed-form log-likelihood, score, and Hessian for exponential and homogeneous Weibull. Composable `observe_*()` functors for censoring. 4 comprehensive vignettes including a self-contained theory guide. |
| **[mdrelax](https://github.com/queelius/mdrelax)** | `~/github/rlang/mdrelax` | What happens when C1, C2, or C3 are violated? Simulation studies under informative masking, parameter-dependent masking, and imperfect diagnostics. | Robustness: quantifies bias from model misspecification. Three relaxation models (relaxed C1, C2, C3) with Monte Carlo infrastructure. |
| *(model selection)* | `maskedcauses` vignette | Model selection via LRT nesting chain (exponential ⊂ hom-shape Weibull ⊂ het Weibull). | Folded into `maskedcauses` — the three models already exist in that package. Paper and simulation results at `~/github/papers/masked-series-model-selection/`. |

**Dependency chain:** `flexhaz` → `serieshaz` → `maskedhaz`; `maskedcauses` depends on `likelihood.model` directly (parallel to maskedhaz, not layered on it).

**maskedhaz vs maskedcauses:**
These are complementary, not redundant. `maskedhaz` is *general* — it works
with any hazard function but relies on numerical integration.
`maskedcauses` is *specialized* — it exploits the structure of Exponential and
Weibull distributions for closed-form solutions, faster fitting, and a
richer API (observation functors, data generation, 5 vignettes).
They are cross-validated against each other.

### Infrastructure Packages (General-Purpose)

These are reusable across domains. The reliability packages depend on them.

| Package | Location | What It Does | Design Philosophy |
|---------|----------|-------------|-------------------|
| **[likelihood.model](https://github.com/queelius/likelihood.model)** | `~/github/rlang/likelihood.model` | Generic interface for likelihood-based inference. Defines `loglik()`, `score()`, `hess_loglik()`, `fit()`, `fim()` S3 generics. Handles heterogeneous observation types. | Fisherian likelihood as a first-class object. Models are closures that return functions. |
| **[algebraic.mle](https://github.com/queelius/algebraic.mle)** | `~/github/rlang/algebraic.mle` | Post-estimation inference for MLEs: `coef()`, `vcov()`, `confint()`, delta method, bootstrap. MLEs form an algebra (compose, transform, combine). | Algebraic closure: operations on MLEs produce MLEs. |
| **[algebraic.dist](https://github.com/queelius/algebraic.dist)** | `~/github/rlang/algebraic.dist` | Algebra over probability distributions. Sum of normals → normal. Compose distributions with automatic simplification. | Distribution objects that know their own algebra. |
| **[compositional.mle](https://github.com/queelius/compositional.mle)** | `~/github/rlang/compositional.mle` | Composable optimization solvers: chain (`%>>%`), race (`%\|>%`), random restart. Gradient ascent, Newton, BFGS, simulated annealing as primitives. | SICP-inspired: primitive solvers + composition operators → robust composite solvers. |
| **[hypothesize](https://github.com/queelius/hypothesize)** | `~/github/rlang/hypothesize` | Unified API for hypothesis tests: z-test, Wald test, likelihood ratio test, Fisher's method. Tests compose to tests. | Closure property: combining test results yields valid test results. |

---

## How Papers Map to Packages

```
PAPER                                  IMPLEMENTS / USES
─────                                  ─────────────────
Foundation paper ──────────────────►   maskedhaz (general framework)
  (C1–C2–C3 likelihood)               maskedcauses (Exp/Weibull specialization)

Exponential companion ─────────────►   maskedcauses::exp_series_md_c1_c2_c3
  (closed-form FIM, max-entropy         algebraic.mle (FIM, confidence intervals)
   characterization of C2)

Original thesis ───────────────────►   maskedcauses::wei_series_*
  (Weibull bootstrap)                  algebraic.mle (bootstrap CIs)

Model selection paper ─────────────►   maskedcauses vignette (LRT nesting chain)
  (Weibull nesting chain,               uses exp/hom-wei/het-wei models
   nested LRT, AIC/BIC)

Weibull companion (planned) ───────►   maskedcauses::wei_series_md_c1_c2_c3
Relaxed conditions paper ──────────►   mdrelax
```

---

## The Weibull Model Hierarchy

The model selection paper exploits a natural nesting of parametric families
within the Weibull class. Because the exponential distribution is Weibull with
shape $k = 1$, all the models below live in a single nested hierarchy connected
by likelihood ratio tests:

```
Heterogeneous Weibull          2m parameters
  (k_j, λ_j) per component    most general; each component has its own shape and scale
        ⊃
Homogeneous-Shape Weibull      m + 1 parameters
  shared k, individual λ_j    the "practical" model: one aging rate, individual scales
        ⊃
Exponential                    m parameters
  k = 1, individual λ_j       memoryless components; constant hazard rates
        ⊃
Homogeneous Exponential        1 parameter
  k = 1, all λ_j = λ          null model: identical, memoryless components
```

Each inclusion is testable via a nested likelihood ratio test (LRT). The model
selection paper focuses on the middle two levels (homogeneous-shape Weibull vs
exponential), but the full chain provides useful bookends:

- **Homogeneous Exponential** (1 parameter) is the **null model** — the
  strongest possible simplification. If masked failure data cannot reject this
  model, then components are statistically indistinguishable and memoryless.
  This is a meaningful finding: it means masking has destroyed all information
  about component heterogeneity *and* aging. It also serves as the baseline for
  quantifying how much complexity the data can support.

- **Heterogeneous Weibull** (2m parameters) is the **saturated model** within
  the Weibull family — each component has its own aging behavior. Overfitting
  risk is highest here, especially with heavy masking.

Two additional models sit at interesting extremes but are largely academic:

- **Homogeneous Weibull** (2 parameters: shared $k$, shared $\lambda$) — all
  components identical but allowed to age. This is the minimum-information
  Weibull model (maximum entropy within the Weibull family subject to a mean
  constraint). If the data support this over homogeneous exponential, aging is
  detectable but component differentiation is not.

- **Heterogeneous Exponential with shared $\lambda$** is not a natural model
  (exponential has only one parameter per component), so the chain has no
  intermediate step between exponential and homogeneous exponential.

The nesting chain gives the model selection paper a clean narrative:
start from the null (homogeneous exponential), add component heterogeneity
(exponential), add aging (homogeneous-shape Weibull), and finally allow
heterogeneous aging (heterogeneous Weibull). At each step, an LRT or
information criterion tells the practitioner whether the added complexity is
warranted by the data.

---

## The C1–C2–C3 Conditions (Shared Foundation)

All papers and packages in this ecosystem rest on three conditions that make
the masked-data likelihood tractable:

- **C1** (Containment): The true failed component is always in the candidate
  set. $P(K \in C) = 1$.
- **C2** (Symmetric masking): The probability of observing a particular
  candidate set is the same for all components in that set.
- **C3** (Parameter independence): The masking probability does not depend on
  the lifetime parameters $\theta$.

Under C1–C2–C3, the masking probability $\beta_i$ factors out of the
likelihood and can be dropped, reducing the problem to standard parametric
MLE over the component hazard parameters.

---

## Ecosystem Coordination (from 2026-02-18 review)

### FIM Derivation Ownership

weibull-masked-fim is the primary source for the Weibull Fisher information
matrix derivation.

### "Statistical Indistinguishability" Territory

Three papers approach the question of when component structure becomes
statistically invisible. Agreed division:

- **Foundation paper** owns: identifiability conditions (graph-theoretic extension in `graph-identifiability.md`)
- **Model selection paper** (+ `maskedcauses` vignette) owns: empirical LRT
  power curves for when statistical tests fail to distinguish component structure

### Submission Sequencing

1. **weibull-masked-fim** (Weibull MLE) should be drafted first — it is already cited in
   the foundation paper and has the most clearly defined content
2. **Foundation paper** should not be submitted until weibull-masked-fim has a circulating
   draft (the `towell2025weibull-series` citation must resolve to something)
3. **Foundation paper** depends on weibull-masked-fim's FIM derivation (citation `towell2025weibull-series`)

### Prior-Art Surveys

All companion papers have `prior_art.last_survey: null`. Surveys needed before
drafting:

- **weibull-masked-fim**: Weibull series MLE in reliability literature, competing risks
  Weibull estimation

---

## Status Summary

| Component | Status | Tests |
|-----------|--------|-------|
| Foundation paper | Draft complete, reviewed | — |
| Exponential companion | Draft complete | — |
| Model selection paper | Complete; tooling in `maskedcauses` vignette | — |
| Relaxed conditions paper | Draft | — |
| Original thesis | Published | — |
| `flexhaz` | r-universe | 267 |
| `serieshaz` | r-universe | 130 |
| `maskedhaz` | r-universe | 148 |
| `maskedcauses` | r-universe | 798 |
| `mdrelax` | r-universe | — |
| `likelihood.model` | r-universe | — |
| `algebraic.mle` | r-universe | — |
| `algebraic.dist` | Development | — |
| `compositional.mle` | Development | — |
| `hypothesize` | Development | — |
| 2 companions (1 submitted, 1 draft) | Active | — |
