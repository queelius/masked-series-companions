# Closed-Form Fisher Information for Homogeneous Weibull Series Systems

**Date**: 2026-02-26
**Status**: Complete derivation, pending numerical verification

## Setup

Series system with $m$ components, each Weibull with **common shape** $k$ and
**distinct scales** $\beta_1, \ldots, \beta_m$.

### Parametrization

Use **rate parameters** $\lambda_j = \beta_j^{-k}$ for cleaner algebra:

- System rate: $\lambda_{\mathrm{sys}} = \sum_{j=1}^m \lambda_j$
- System scale: $\beta_{\mathrm{sys}} = \lambda_{\mathrm{sys}}^{-1/k} = \bigl(\sum_j \beta_j^{-k}\bigr)^{-1/k}$
- System lifetime: $T \sim \mathrm{Weibull}(k, \beta_{\mathrm{sys}})$
- Cause weights: $w_j = \lambda_j / \lambda_{\mathrm{sys}} = \beta_j^{-k} / \sum_l \beta_l^{-k}$
- Failed component: $K \sim \mathrm{Multinomial}(w_1, \ldots, w_m)$, **independent of** $T$

### Joint density

$$
f(t, K=j \mid k, \boldsymbol{\lambda}) = k \, \lambda_j \, t^{k-1} \exp\bigl(-\lambda_{\mathrm{sys}} \, t^k\bigr)
$$

### Per-observation log-likelihood (exact, unmasked)

$$
\ell_1(k, \boldsymbol{\lambda}) = \log k + \log \lambda_K + (k-1)\log T - \lambda_{\mathrm{sys}} \, T^k
$$

## Score Equations

Define $V = \lambda_{\mathrm{sys}} \, T^k = (T / \beta_{\mathrm{sys}})^k$. Since
$T \sim \mathrm{Weibull}(k, \beta_{\mathrm{sys}})$, we have $V \sim \mathrm{Exp}(1)$.

Also: $\log T = \log \beta_{\mathrm{sys}} + \frac{1}{k} \log V$.

### Score for $k$

$$
s_k = \frac{\partial \ell_1}{\partial k} = \frac{1}{k} + \log T - \lambda_{\mathrm{sys}} \, T^k \log T = \frac{1}{k} + (1 - V)\log T
$$

### Score for $\lambda_j$

$$
s_{\lambda_j} = \frac{\partial \ell_1}{\partial \lambda_j} = \frac{\mathbf{1}(K = j)}{\lambda_j} - T^k
$$

**Verification**: $E[s_{\lambda_j}] = w_j / \lambda_j - E[T^k] = 1/\lambda_{\mathrm{sys}} - 1/\lambda_{\mathrm{sys}} = 0$. ✓

## Hessian

$$
\frac{\partial^2 \ell_1}{\partial k^2} = -\frac{1}{k^2} - V (\log T)^2
$$

$$
\frac{\partial^2 \ell_1}{\partial \lambda_j^2} = -\frac{\mathbf{1}(K=j)}{\lambda_j^2}
$$

$$
\frac{\partial^2 \ell_1}{\partial \lambda_j \partial \lambda_l} = 0 \quad (j \neq l)
$$

$$
\frac{\partial^2 \ell_1}{\partial k \, \partial \lambda_j} = -T^k \log T \quad \text{(same for all } j\text{)}
$$

## Expected Moments

All expectations use $V \sim \mathrm{Exp}(1)$ with pdf $e^{-v}$ on $[0, \infty)$.

| Moment | Value | Source |
|--------|-------|--------|
| $E[V]$ | $1$ | Standard |
| $E[\log V]$ | $-\gamma$ | Euler-Mascheroni constant |
| $E[V \log V]$ | $\psi(2) = 1 - \gamma$ | Digamma at 2 |
| $E[(\log V)^2]$ | $\gamma^2 + \pi^2/6$ | Standard |
| $E[V (\log V)^2]$ | $\psi'(2) + \psi(2)^2 = (\pi^2/6 - 1) + (1-\gamma)^2$ | Trigamma + digamma² |

Where $\gamma \approx 0.5772$ is the Euler-Mascheroni constant.

**Derivation of key moments** via the moment-generating function of $\log V$:

$$
E[V^a (\log V)^n] = \frac{d^n}{da^n} \Gamma(a+1)
$$

At $a = 1$: $\Gamma(2) = 1$, $\psi(2) = 1 - \gamma$, $\psi'(2) = \pi^2/6 - 1$.

## Fisher Information Matrix

Define the **centering constant**:

$$
\mu = \log \beta_{\mathrm{sys}} + \frac{1 - \gamma}{k}
$$

Note: $E[\log T] = \log \beta_{\mathrm{sys}} - \gamma/k$, so $\mu = E[\log T] + 1/k$.

### FIM entries

**Shape-shape**:

$$
I_{kk} = \frac{1}{k^2} + E\bigl[V (\log T)^2\bigr]
$$

Expanding $\log T = \log \beta_{\mathrm{sys}} + \frac{1}{k}\log V$:

$$
I_{kk} = \frac{1}{k^2} + (\log \beta_{\mathrm{sys}})^2 + \frac{2(1-\gamma)}{k}\log \beta_{\mathrm{sys}} + \frac{1}{k^2}\Bigl[\frac{\pi^2}{6} - 1 + (1-\gamma)^2\Bigr]
$$

Completing the square:

$$
\boxed{I_{kk} = \mu^2 + \frac{\pi^2}{6k^2}}
$$

**Rate-rate (diagonal)**:

$$
\boxed{I_{\lambda_j, \lambda_j} = \frac{1}{\lambda_j \, \lambda_{\mathrm{sys}}}}
$$

**Rate-rate (off-diagonal)**:

$$
\boxed{I_{\lambda_j, \lambda_l} = 0 \quad (j \neq l)}
$$

**Shape-rate (cross terms)**:

$$
I_{k, \lambda_j} = E[T^k \log T] = \frac{1}{\lambda_{\mathrm{sys}}} E[V \log T]
= \frac{1}{\lambda_{\mathrm{sys}}} \Bigl[\log \beta_{\mathrm{sys}} + \frac{1-\gamma}{k}\Bigr]
$$

$$
\boxed{I_{k, \lambda_j} = \frac{\mu}{\lambda_{\mathrm{sys}}} \quad \text{(same for all } j\text{)}}
$$

### Matrix form

Let $\mathbf{e} = (1, \ldots, 1)^\top \in \mathbb{R}^m$ and
$D = \mathrm{diag}\bigl(1/(\lambda_1 \lambda_{\mathrm{sys}}), \ldots, 1/(\lambda_m \lambda_{\mathrm{sys}})\bigr)$.

$$
\boxed{
I(k, \boldsymbol{\lambda}) =
\begin{pmatrix}
\mu^2 + \dfrac{\pi^2}{6k^2} & \dfrac{\mu}{\lambda_{\mathrm{sys}}} \, \mathbf{e}^\top \\[8pt]
\dfrac{\mu}{\lambda_{\mathrm{sys}}} \, \mathbf{e} & D
\end{pmatrix}
}
$$

## Key Properties

### 1. Closed-form in elementary constants

The FIM involves only $\gamma$ (Euler-Mascheroni) and $\pi^2/6$ (Basel sum).
No numerical integration required.

### 2. Diagonal rate block

Information about $\lambda_j$ and $\lambda_l$ ($j \neq l$) is zero — each rate
contributes information independently. This is because the only source of
information about $\lambda_j$ is the indicator $\mathbf{1}(K = j)$, which is
independent across components.

### 3. Uniform cross terms

The shape-rate cross terms $I_{k, \lambda_j} = \mu / \lambda_{\mathrm{sys}}$ are
identical for all $j$. This reflects the fact that $k$ couples to all component
rates symmetrically through the system failure time $T$.

### 4. Reduction to standard Weibull FIM (m = 1)

For $m = 1$: $\beta_{\mathrm{sys}} = \beta_1$, $\lambda_{\mathrm{sys}} = \lambda_1$.
Transform to $(k, \beta_1)$ via Jacobian. The $(k, k)$ entry becomes:

$$
I_{kk}^{(k, \beta)} = \frac{(1-\gamma)^2 + \pi^2/6}{k^2}
$$

which is the classical single-Weibull result (scale-invariant).

### 5. Reduction to exponential FIM (k = 1)

For $k = 1$: $\lambda_j = 1/\beta_j$, $\lambda_{\mathrm{sys}} = \sum_j 1/\beta_j$,
and $\mu = \log \beta_{\mathrm{sys}} + 1 - \gamma$. The rate block $D$ becomes the
unmasked exponential FIM from the expo companion paper.

## Extension: Masking Invariance of Shape Information

Under C2 masking with candidate sets of size $w$, the log-likelihood becomes:

$$
\ell_1^{\mathrm{masked}} = \log k + \log\Bigl(\sum_{j \in C} \lambda_j\Bigr) + (k-1)\log T - \lambda_{\mathrm{sys}} \, T^k
$$

**Key observation**: The masking replaces $\log \lambda_K$ with
$\log(\sum_{j \in C} \lambda_j)$, but this substitution **does not depend on** $k$.

Therefore:

$$
\frac{\partial^2 \ell_1^{\mathrm{masked}}}{\partial k^2} = \frac{\partial^2 \ell_1}{\partial k^2}, \qquad
\frac{\partial^2 \ell_1^{\mathrm{masked}}}{\partial k \, \partial \lambda_j} = \frac{\partial^2 \ell_1}{\partial k \, \partial \lambda_j}
$$

**Result**: $I_{kk}$ and $I_{k, \lambda_j}$ are **masking-invariant**. Only the
$\lambda$-$\lambda$ block changes under masking.

The complete masked FIM is:

$$
I^{\mathrm{masked}}(k, \boldsymbol{\lambda} \mid w) =
\begin{pmatrix}
\mu^2 + \dfrac{\pi^2}{6k^2} & \dfrac{\mu}{\lambda_{\mathrm{sys}}} \, \mathbf{e}^\top \\[8pt]
\dfrac{\mu}{\lambda_{\mathrm{sys}}} \, \mathbf{e} & I^{\mathrm{expo}}(\boldsymbol{\lambda} \mid w)
\end{pmatrix}
$$

where $I^{\mathrm{expo}}(\boldsymbol{\lambda} \mid w)$ is the exponential masked FIM
from the expo companion paper (Proposition 3.3), evaluated at rates
$\lambda_j = \beta_j^{-k}$.

### Interpretation

Masking affects information about **which component failed** (the $\lambda$-$\lambda$
block) but not about **when the system failed** (the shape-related entries).

This makes intuitive sense: the common shape $k$ governs the time-to-failure
distribution of the system as a whole, while the individual rates $\lambda_j$
govern the relative failure probabilities of each component. Masking obscures
component identity but preserves the failure time — hence it degrades rate
information but not shape information.

## Information Loss Decomposition

From the masked FIM structure:

$$
I^{\mathrm{complete}} - I^{\mathrm{masked}} =
\begin{pmatrix}
0 & \mathbf{0}^\top \\
\mathbf{0} & D - I^{\mathrm{expo}}(\boldsymbol{\lambda} \mid w)
\end{pmatrix}
$$

The **entire information loss** from masking is confined to the rate block.
This matrix is positive semidefinite (Loewner ordering) by the data processing
inequality.

## Numerical Verification Plan

Compare the analytical FIM against:
1. Monte Carlo: generate $n = 10^6$ observations, compute sample outer product of scores
2. Numerical Hessian: compute $-E[\nabla^2 \ell]$ via `numDeriv::hessian` averaged over samples
3. Package FIM: compare with `maskedcauses` observed FIM at large $n$

See `verify-fim.R` for implementation.
