# MLE for Weibull Series Systems with Masked Failure Causes

## Status: Planned (referenced as towell2025weibull-series in foundation paper)

## Motivation

The foundation paper develops the general C1-C2-C3 likelihood framework
without specializing to any distribution. This companion paper provides the
complete Weibull treatment: score equations, Fisher information, simulation
studies, and practical guidance.

Note: The exponential case is already handled by `expo-masked-fim`. The
homogeneous vs heterogeneous Weibull model selection question is handled by
`reliability-estimation-in-series-systems-model-selection`. This paper fills
the remaining gap: the core MLE methodology for Weibull components.

## Core Content

### 1. Homogeneous Weibull (m+1 parameters)

- Weibull closure theorem (system is Weibull) — proved in model selection paper
- Time-invariant cause probabilities: P(K=j|T=t) = w_j (constant)
- Closed-form censored likelihood contributions (candidate weight factors out)
- Score equations (analytical for exact+right, hybrid for left+interval)
- Fisher information matrix
- Simulation study: bias, MSE, coverage under varying masking/censoring

### 2. Heterogeneous Weibull (2m parameters)

- System is NOT Weibull; cause probabilities vary with time
- Numerical integration for left/interval censored contributions
- Score equations (analytical for exact+right, numerical for left+interval)
- Hessian via numerical differentiation of score
- Simulation study: convergence, computational cost, comparison to homogeneous
- When does the extra flexibility of heterogeneous shapes matter?

### 3. Comparison: Homogeneous vs Heterogeneous

- Bias-variance tradeoff across the hierarchy
- Computational cost comparison (exact >> homogeneous >> heterogeneous)
- Model selection guidance (LRT, AIC, BIC) — brief, pointing to model
  selection paper for full treatment
- Case studies with DFR, CFR, IFR component mixtures

## What Already Exists

- `likelihood.model.series.md` R package implements all three model levels
- `vignettes/framework.Rmd` (just created) walks through the theory with code
- Model selection paper has extensive LRT simulations for the hom/het comparison
- expo-masked-fim has the exponential Fisher information

## What's Missing (Needs to be Developed)

- Explicit score equations written out in full (not just "use the package")
- Fisher information for Weibull (both homogeneous and heterogeneous)
- Standalone simulation study focused on estimation quality (not model selection)
- Sensitivity to starting values for optimization
- Real data example or realistic synthetic case study

## Open Questions

- Closed-form Fisher information for homogeneous Weibull? (Expo case is closed
  form; does the common-shape constraint enable closed form for Weibull?)
- Profile likelihood for shape parameter — what does the profile look like
  under heavy masking?
- Bootstrap vs asymptotic confidence intervals: when does the asymptotic
  approximation break down?

## Target Venue

- **Primary**: IEEE Transactions on Reliability
- **Alternative**: Reliability Engineering & System Safety

## Dependencies

- Foundation paper (cite for general theory)
- expo-masked-fim (cite for exponential special case)
- Model selection paper (cite for hom/het comparison)

## Estimated Effort

High. Full simulation study, explicit derivations, case study.
