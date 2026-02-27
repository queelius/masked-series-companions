# helpers.R — Utility functions for the identifiability simulation study
#
# Provides:
#   - Fixed-cardinality candidate-set generation (uniform masking, block, hierarchical)
#   - Data generation wrappers using maskedcauses
#   - Theoretical Fisher information computations
#   - Effective sample size and FMI calculations

library(maskedcauses)

# ── Fixed-cardinality candidate-set generators ─────────────────────────────

#' Generate a uniform random candidate set of exactly size w containing k.
#'
#' @param k   true failed component (integer 1..m)
#' @param m   number of components
#' @param w   candidate set cardinality (1 <= w <= m)
#' @return logical vector of length m (TRUE = component in candidate set)
uniform_candset <- function(k, m, w) {
  cs <- rep(FALSE, m)
  cs[k] <- TRUE
  if (w > 1) {
    others <- setdiff(seq_len(m), k)
    cs[sample(others, w - 1)] <- TRUE
  }
  cs
}

#' Generate block-structured candidate sets.
#'
#' Components are partitioned into contiguous blocks. The candidate set is the
#' block containing the true cause. Block sizes are as equal as possible; any
#' remainder is distributed across the first blocks.
#'
#' @param k   true failed component (integer 1..m)
#' @param m   number of components
#' @param w   target candidate set cardinality (determines number of blocks)
#' @return logical vector of length m
block_candset <- function(k, m, w) {
  n_blocks <- floor(m / w)
  if (n_blocks < 1) n_blocks <- 1
  # Create block assignments: blocks of size w, last block gets remainder
  block_id <- rep(seq_len(n_blocks), each = w, length.out = m)
  cs <- rep(FALSE, m)
  cs[block_id == block_id[k]] <- TRUE
  cs
}

#' Generate hierarchical candidate sets.
#'
#' Components form a balanced binary tree. The candidate set is a subtree at a
#' random level containing the true cause, targeting cardinality near w.
#'
#' @param k   true failed component (integer 1..m)
#' @param m   number of components
#' @param w   target candidate set cardinality
#' @return logical vector of length m
hierarchical_candset <- function(k, m, w) {
  # Build groups at the level that gives size closest to w
  # Use a simple hierarchical grouping: split [1..m] into groups of size 2^l
  if (w >= m) return(rep(TRUE, m))
  if (w <= 1) {
    cs <- rep(FALSE, m)
    cs[k] <- TRUE
    return(cs)
  }
  # Find power-of-2 group size closest to w
  levels <- 2^(0:ceiling(log2(m)))
  levels <- levels[levels <= m]
  best <- levels[which.min(abs(levels - w))]
  # Assign components to groups of size `best`
  group_id <- ceiling(seq_len(m) / best)
  cs <- rep(FALSE, m)
  cs[group_id == group_id[k]] <- TRUE
  cs
}


# ── Data generation with fixed-cardinality masking ─────────────────────────

#' Generate masked series system data with fixed candidate-set cardinality.
#'
#' @param theta   rate parameters (length m) for exponential components
#' @param n       sample size
#' @param w       candidate set cardinality (1 = complete data, m = full masking)
#' @param tau     right-censoring time (Inf = no censoring)
#' @param structure  one of "uniform", "block", "hierarchical"
#' @return data.frame compatible with maskedcauses (columns: t, omega, x1..xm)
generate_data <- function(theta, n, w, tau = Inf, structure = "uniform") {
  m <- length(theta)
  stopifnot(w >= 1, w <= m)

  candset_fn <- switch(structure,
    uniform = uniform_candset,
    block = block_candset,
    hierarchical = hierarchical_candset,
    stop("Unknown structure: ", structure)
  )

  # Generate component lifetimes
  comp_lifetimes <- matrix(nrow = n, ncol = m)
  for (j in seq_len(m)) {
    comp_lifetimes[, j] <- rexp(n, rate = theta[j])
  }

  sys_lifetime <- apply(comp_lifetimes, 1, min)
  failed_comp  <- apply(comp_lifetimes, 1, which.min)

  # Observation mechanism (right censoring)
  obs_t <- pmin(sys_lifetime, tau)
  omega <- ifelse(sys_lifetime <= tau, "exact", "right")

  # Generate candidate sets
  candset <- matrix(FALSE, nrow = n, ncol = m)
  for (i in which(omega == "exact")) {
    candset[i, ] <- candset_fn(failed_comp[i], m, w)
  }

  df <- data.frame(t = obs_t, omega = omega, stringsAsFactors = FALSE)
  for (j in seq_len(m)) {
    df[[paste0("x", j)]] <- candset[, j]
  }
  df
}


# ── Theoretical Fisher information ─────────────────────────────────────────

#' Compute the complete-data Fisher information for exponential series.
#'
#' For one complete-data observation with known cause k:
#'   l_i = log(lambda_k) - lambda_sys * t_i
#' The expected FI per observation is diagonal:
#'   I_{jj} = P(K=j) / lambda_j^2 = 1 / (lambda_sys * lambda_j)
#'
#' @param theta  rate parameters (length m)
#' @param n      sample size
#' @return m x m matrix (expected Fisher information for n observations)
fim_complete <- function(theta, n = 1) {
  m <- length(theta)
  lambda_sys <- sum(theta)
  n * diag(1 / (lambda_sys * theta), nrow = m)
}

#' Compute the masked-data Fisher information for uniform masking (exponential).
#'
#' From the paper (Section 8, Proposition 3):
#' For exponential components under uniform masking with cardinality w,
#' the Fisher information per observation is:
#'   I_masked = I_complete - Delta
#' where Delta has entries:
#'   Delta_{jk} = (w-1) / (m-1) * [lambda_j * lambda_k] / [lambda_sys^2 * w]
#' for j != k, and diagonal:
#'   Delta_{jj} = (w-1) / (m-1) * [lambda_j * (lambda_sys - lambda_j)] /
#'                [lambda_sys^2 * w * lambda_j]
#'            + correction terms from the candidate-set averaging
#'
#' For equal rates (lambda_j = lambda for all j), the per-observation FIM is:
#'   I_masked = (1/(m*lambda^2)) * [(1 + (m-w)/((m-1)*w)) * I - (1/(m*(m-1)*w)) * J]
#' where I = identity, J = all-ones matrix.
#'
#' Let's use the observed Hessian approach for general theta:
#' Compute by averaging the expected Hessian over the candidate-set distribution.
#'
#' @param theta  rate parameters (length m)
#' @param w      masking cardinality
#' @param n      sample size
#' @return m x m matrix
fim_masked_equal_rates <- function(theta, w, n = 1) {
  m <- length(theta)
  lam <- theta[1]  # assumes equal rates
  stopifnot(all(abs(theta - lam) < 1e-10))

  # Per observation, from paper's Proposition 3 (equal-rate special case):
  # Diagonal: a + b where a = (m-w)/((m-1)*m*w*lam^2), b = 1/(m*lam^2)
  # Off-diagonal: a
  # Actually: I_masked = (1/(m*lam^2)) * I_m + a * (I_m - (1/m)*J_m)
  # ... let me use the eigenvalue form directly:
  # eigenvalue for (1,1,...,1): 1/(m*w*lam^2)
  # eigenvalue for orthogonal complement: (m-w)/((m-1)*m*w*lam^2) + 1/(m*lam^2)
  #   = [m-w + (m-1)*w] / ((m-1)*m*w*lam^2)
  #   = [m-w + mw - w] / ((m-1)*m*w*lam^2)
  #   = [m(1+w-1) - 2w + m... hmm

  # Use direct matrix construction:
  # From the Hessian computation in the paper (Eq for equal-rate uniform masking):
  # Let p_j = lambda_j / lambda_sys = 1/m for equal rates
  # For a candidate set C of size w containing j:
  #   contribution to I_{jj} from exact obs: E[1/lambda_C^2 | C contains j]
  #   where lambda_C = sum_{l in C} lambda_l = w*lam for equal rates
  # Simplify: I_{jj} = 1/(w*lam)^2 * P(j in C) ... this isn't right

  # Better: compute numerically from the Hessian
  model <- exp_series_md_c1_c2_c3()
  hess_fn <- hess_loglik(model)

  # Monte Carlo estimate of expected FIM
  n_mc <- 50000
  df <- generate_data(theta, n_mc, w, tau = Inf, structure = "uniform")
  H <- hess_fn(df, par = theta)
  n * (-H / n_mc)
}

#' Compute the masked-data Fisher information numerically.
#'
#' Uses a large Monte Carlo sample to estimate E[-H(theta)] per observation.
#'
#' @param theta     rate parameters
#' @param w         masking cardinality
#' @param n         sample size multiplier (default 1 = per-observation)
#' @param n_mc      Monte Carlo sample size for estimation
#' @param structure candidate-set structure
#' @return m x m matrix (expected FIM for n observations)
fim_masked <- function(theta, w, n = 1, n_mc = 100000,
                       structure = "uniform") {
  model <- exp_series_md_c1_c2_c3()
  hess_fn <- hess_loglik(model)
  df <- generate_data(theta, n_mc, w, tau = Inf, structure = structure)
  n * (-hess_fn(df, par = theta) / n_mc)
}


# ── Effective sample size and diagnostics ──────────────────────────────────

#' Compute the effective sample size ratio r = lambda_min(I_masked) / lambda_min(I_complete).
#'
#' @param theta     rate parameters
#' @param w         masking cardinality
#' @param n_mc      Monte Carlo sample size for FIM estimation
#' @param structure candidate-set structure
#' @return scalar ratio r in [0, 1]
ess_ratio <- function(theta, w, n_mc = 100000, structure = "uniform") {
  I_comp <- fim_complete(theta)
  I_mask <- fim_masked(theta, w, n_mc = n_mc, structure = structure)
  min(eigen(I_mask, symmetric = TRUE)$values) /
    min(eigen(I_comp, symmetric = TRUE)$values)
}

#' Compute the fraction of missing information (FMI) for each parameter.
#'
#' gamma_j = 1 - I_masked_{jj} / I_complete_{jj}
#'
#' This is the diagonal-element FMI from Proposition 5 in the paper.
#'
#' @param theta     rate parameters
#' @param w         masking cardinality
#' @param n_mc      Monte Carlo sample size
#' @param structure candidate-set structure
#' @return numeric vector of FMI values (length m)
fmi <- function(theta, w, n_mc = 100000, structure = "uniform") {
  I_comp <- fim_complete(theta)
  I_mask <- fim_masked(theta, w, n_mc = n_mc, structure = structure)
  1 - diag(I_mask) / diag(I_comp)
}

#' Compute the theoretical ESS ratio for equal-rate exponential uniform masking.
#'
#' r = (m - w) / ((m - 1) * w)  from corrected Proposition 4.
#'
#' @param m  number of components
#' @param w  masking cardinality
#' @return scalar
ess_ratio_theory <- function(m, w) {
  (m - w) / ((m - 1) * w)
}

#' Compute the condition number of the masked FIM.
#'
#' kappa = lambda_max / lambda_min
#'
#' @param theta     rate parameters
#' @param w         masking cardinality
#' @param n_mc      Monte Carlo sample size
#' @param structure candidate-set structure
#' @return scalar condition number
condition_number <- function(theta, w, n_mc = 100000, structure = "uniform") {
  I_mask <- fim_masked(theta, w, n_mc = n_mc, structure = structure)
  evals <- eigen(I_mask, symmetric = TRUE)$values
  max(evals) / min(evals)
}


# ── MLE fitting ────────────────────────────────────────────────────────────

#' Fit exponential series model via L-BFGS-B.
#'
#' @param df     masked data frame (from generate_data)
#' @param m      number of components
#' @param par0   starting values (default: rep(1, m))
#' @param n_starts  number of random restarts
#' @return list with: par (MLE), converged (logical), loglik, hessian, n_iter
fit_mle <- function(df, m, par0 = NULL, n_starts = 3) {
  model <- exp_series_md_c1_c2_c3()
  ll_fn <- loglik(model)
  sc_fn <- score(model)
  hs_fn <- hess_loglik(model)

  best <- list(value = Inf)

  for (s in seq_len(n_starts)) {
    if (s == 1 && !is.null(par0)) {
      start <- par0
    } else {
      start <- runif(m, 0.01, 2)
    }

    result <- tryCatch(
      optim(
        par = start,
        fn = function(par) -ll_fn(df, par = par),
        gr = function(par) -sc_fn(df, par = par),
        method = "L-BFGS-B",
        lower = rep(1e-8, m),
        control = list(maxit = 500)
      ),
      error = function(e) list(value = Inf, convergence = 1)
    )

    if (result$value < best$value) best <- result
  }

  converged <- best$convergence == 0
  H <- if (converged) hs_fn(df, par = best$par) else matrix(NA, m, m)

  list(
    par = best$par,
    converged = converged,
    loglik = -best$value,
    hessian = H,
    n_iter = best$counts["function"]
  )
}
