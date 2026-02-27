#!/usr/bin/env Rscript
# ============================================================================
# Numerical verification: Closed-form FIM for homogeneous Weibull series
#
# Compares the analytical FIM (from fim-derivation.md) against:
#   1. Monte Carlo outer-product-of-scores estimator
#   2. Monte Carlo negative-Hessian estimator
#
# Usage: Rscript verify-fim.R
# ============================================================================

# --- Analytical FIM --------------------------------------------------------

#' Closed-form per-observation Fisher information matrix
#' for a homogeneous Weibull series system (no masking, exact observations).
#'
#' @param k     Common shape parameter (> 0)
#' @param betas Scale parameters for each component (length m, all > 0)
#' @return (m+1) x (m+1) FIM in the (k, lambda_1, ..., lambda_m) parametrization
analytical_fim <- function(k, betas) {
  m      <- length(betas)
  lambdas <- betas^(-k)              # rate parameters
  lam_sys <- sum(lambdas)            # system rate
  beta_sys <- lam_sys^(-1 / k)       # system scale
  gamma_em <- -digamma(1)            # Euler-Mascheroni constant

  mu <- log(beta_sys) + (1 - gamma_em) / k   # centering constant

  # Build FIM
  I <- matrix(0, m + 1, m + 1)

  # I_{kk}
  I[1, 1] <- mu^2 + pi^2 / (6 * k^2)

  # I_{k, lambda_j} = mu / lam_sys  (same for all j)
  I[1, 2:(m + 1)] <- mu / lam_sys
  I[2:(m + 1), 1] <- mu / lam_sys

  # I_{lambda_j, lambda_j} = 1 / (lambda_j * lam_sys)
  for (j in seq_len(m)) {
    I[j + 1, j + 1] <- 1 / (lambdas[j] * lam_sys)
  }

  # Name rows/cols
  nms <- c("k", paste0("lam", seq_len(m)))
  rownames(I) <- colnames(I) <- nms
  I
}


# --- Monte Carlo estimation ------------------------------------------------

#' Generate one observation from homogeneous Weibull series system.
#'
#' @return list(t = failure time, k_failed = failed component index)
robs_hom_weibull <- function(k, betas) {
  m <- length(betas)
  # Component lifetimes: T_j ~ Weibull(k, beta_j)
  component_times <- rweibull(m, shape = k, scale = betas)
  j_min <- which.min(component_times)
  list(t = component_times[j_min], k_failed = j_min)
}

#' Score vector for one observation (k, lambda parametrization)
score_one <- function(k, lambdas, t, j_failed) {
  m       <- length(lambdas)
  lam_sys <- sum(lambdas)
  V       <- lam_sys * t^k

  # s_k = 1/k + log(t) - V * log(t)
  s_k <- 1 / k + (1 - V) * log(t)

  # s_{lambda_j} = I(K=j)/lambda_j - t^k
  s_lam <- rep(-t^k, m)
  s_lam[j_failed] <- s_lam[j_failed] + 1 / lambdas[j_failed]

  c(s_k, s_lam)
}

#' Hessian matrix for one observation (k, lambda parametrization)
hessian_one <- function(k, lambdas, t, j_failed) {
  m       <- length(lambdas)
  lam_sys <- sum(lambdas)
  V       <- lam_sys * t^k
  log_t   <- log(t)

  H <- matrix(0, m + 1, m + 1)

  # H_{kk} = -1/k^2 - V * (log t)^2
  H[1, 1] <- -1 / k^2 - V * log_t^2

  # H_{k, lambda_j} = -t^k * log(t)  (same for all j)
  H[1, 2:(m + 1)] <- -t^k * log_t
  H[2:(m + 1), 1] <- -t^k * log_t

  # H_{lambda_j, lambda_j} = -I(K=j) / lambda_j^2
  H[j_failed + 1, j_failed + 1] <- -1 / lambdas[j_failed]^2

  # H_{lambda_j, lambda_l} = 0 for j != l (already zero)

  H
}


# --- Main verification -----------------------------------------------------

set.seed(42)

# Test case: m = 3 components
k     <- 1.5
betas <- c(100, 200, 150)
m     <- length(betas)

cat("=== Closed-form FIM verification for homogeneous Weibull series ===\n\n")
cat(sprintf("Parameters: k = %.1f, betas = (%s)\n",
            k, paste(betas, collapse = ", ")))

lambdas <- betas^(-k)
lam_sys <- sum(lambdas)
beta_sys <- lam_sys^(-1 / k)
gamma_em <- -digamma(1)
mu <- log(beta_sys) + (1 - gamma_em) / k

cat(sprintf("Derived:    lambdas = (%s)\n",
            paste(format(lambdas, digits = 6), collapse = ", ")))
cat(sprintf("            lam_sys = %.6f, beta_sys = %.4f\n", lam_sys, beta_sys))
cat(sprintf("            mu = %.6f, gamma = %.6f\n\n", mu, gamma_em))

# Analytical FIM
I_analytical <- analytical_fim(k, betas)
cat("Analytical FIM:\n")
print(round(I_analytical, 8))
cat("\n")

# Monte Carlo estimation
n_mc <- 1e6
cat(sprintf("Running Monte Carlo with n = %d...\n", n_mc))

score_sum  <- matrix(0, m + 1, m + 1)  # outer product accumulator
hessian_sum <- matrix(0, m + 1, m + 1) # negative hessian accumulator

for (i in seq_len(n_mc)) {
  obs <- robs_hom_weibull(k, betas)
  s   <- score_one(k, lambdas, obs$t, obs$k_failed)
  H   <- hessian_one(k, lambdas, obs$t, obs$k_failed)

  score_sum  <- score_sum + s %o% s     # outer product of score
  hessian_sum <- hessian_sum - H         # negative hessian
}

I_score   <- score_sum / n_mc
I_hessian <- hessian_sum / n_mc

nms <- c("k", paste0("lam", seq_len(m)))
rownames(I_score) <- colnames(I_score) <- nms
rownames(I_hessian) <- colnames(I_hessian) <- nms

cat("\nMonte Carlo FIM (outer product of scores):\n")
print(round(I_score, 8))

cat("\nMonte Carlo FIM (negative expected Hessian):\n")
print(round(I_hessian, 8))

# Relative errors (only for non-zero analytical entries)
nonzero <- abs(I_analytical) > 1e-15

rel_err_score   <- abs(I_score - I_analytical) / abs(I_analytical)
rel_err_hessian <- abs(I_hessian - I_analytical) / abs(I_analytical)

# For zero analytical entries, report absolute error instead
abs_err_score   <- abs(I_score - I_analytical)
abs_err_hessian <- abs(I_hessian - I_analytical)

cat("\nRelative error on non-zero entries (score method):\n")
re_s <- rel_err_score; re_s[!nonzero] <- NA
print(round(re_s, 6))

cat("\nRelative error on non-zero entries (Hessian method):\n")
re_h <- rel_err_hessian; re_h[!nonzero] <- NA
print(round(re_h, 6))

cat("\nAbsolute error on zero entries (score method):\n")
ae_s <- abs_err_score; ae_s[nonzero] <- NA
print(round(ae_s, 2))

max_rel_err <- max(c(rel_err_score[nonzero], rel_err_hessian[nonzero]))
max_abs_err_zero <- max(abs_err_hessian[!nonzero])
cat(sprintf("\nMax relative error (non-zero entries): %.2e\n", max_rel_err))
cat(sprintf("Max absolute error (zero entries, Hessian): %.2e\n", max_abs_err_zero))

if (max_rel_err < 0.01) {
  cat("PASS: Analytical FIM matches Monte Carlo (< 1%% relative error)\n")
} else {
  cat("FAIL: Analytical FIM does NOT match Monte Carlo\n")
}

# --- Special case checks ---------------------------------------------------

cat("\n\n=== Special case: m = 1 (single Weibull) ===\n")
k1 <- 2.0
beta1 <- c(50)
I1 <- analytical_fim(k1, beta1)

# Standard Weibull FIM in (k, beta) parametrization
# I_{kk}^{(k,beta)} = [(1-gamma)^2 + pi^2/6] / k^2
I_kk_standard <- ((1 - gamma_em)^2 + pi^2 / 6) / k1^2

# Transform our (k, lambda) FIM to (k, beta) via Jacobian
lam1 <- beta1^(-k1)
J <- matrix(c(1, 0,
              -lam1 * log(beta1), -k1 * lam1 / beta1), nrow = 2, byrow = TRUE)
I_beta <- t(J) %*% I1 %*% J
I_kk_from_transform <- I_beta[1, 1]

cat(sprintf("Standard Weibull I_{kk}^{(k,beta)}: %.8f\n", I_kk_standard))
cat(sprintf("Jacobian-transformed I_{kk}^{(k,beta)}: %.8f\n", I_kk_from_transform))
cat(sprintf("Match: %s\n", abs(I_kk_standard - I_kk_from_transform) < 1e-12))

cat("\n=== Special case: k = 1 (exponential) ===\n")
k_exp <- 1.0
betas_exp <- c(100, 200, 150)
I_exp <- analytical_fim(k_exp, betas_exp)

# For exponential, lambda_j = 1/beta_j
lambdas_exp <- 1 / betas_exp
lam_sys_exp <- sum(lambdas_exp)

# Unmasked exponential FIM: I_{lambda_j, lambda_j} = 1/(lambda_j * lam_sys)
# This matches our general formula at k=1
cat(sprintf("Exponential FIM diagonal (analytical):   %s\n",
            paste(format(diag(I_exp)[2:4], digits = 8), collapse = ", ")))
cat(sprintf("Exponential FIM diagonal (1/(lam_j*L)): %s\n",
            paste(format(1 / (lambdas_exp * lam_sys_exp), digits = 8), collapse = ", ")))
cat(sprintf("Match: %s\n",
            all(abs(diag(I_exp)[2:4] - 1 / (lambdas_exp * lam_sys_exp)) < 1e-12)))

cat("\nDone.\n")
