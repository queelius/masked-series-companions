#!/usr/bin/env Rscript
# run_simulation.R — Main simulation study for the identifiability paper
#
# Tests predictions P1-P6 from Section 12.
# Usage:
#   Rscript run_simulation.R               # full run (slow)
#   Rscript run_simulation.R --quick       # reduced grid for testing
#   Rscript run_simulation.R --config 42   # specific config index

library(maskedcauses)

# Resolve script directory for sourcing helpers
this_dir <- tryCatch(dirname(sys.frame(1)$ofile), error = function(e) NULL)
if (is.null(this_dir) || !file.exists(file.path(this_dir, "helpers.R"))) {
  # Fallback: search for helpers.R nearby
  for (d in c(getwd(), file.path(getwd(), "simulations"))) {
    if (file.exists(file.path(d, "helpers.R"))) { this_dir <- d; break }
  }
}
source(file.path(this_dir, "helpers.R"))

args <- commandArgs(trailingOnly = TRUE)
QUICK <- "--quick" %in% args

# ── Experimental design ────────────────────────────────────────────────────

# Factor 1: Number of components
ms <- if (QUICK) c(3, 5) else c(3, 5, 10)

# Factor 2: Masking cardinality w (depends on m)
# w = 1 (complete data), ceil(m/2) (moderate), m-1 (heavy masking)
make_ws <- function(m) unique(c(1, ceiling(m / 2), m - 1))

# Factor 3: Sample size
ns <- if (QUICK) c(200, 1000) else c(50, 200, 1000, 5000)

# Factor 4: Rate configurations (depends on m)
make_rates <- function(m) {
  list(
    equal    = rep(1, m),
    moderate = seq(1, 2, length.out = m),  # 1:2 spread
    strong   = seq(1, 10, length.out = m)  # 1:10 spread
  )
}

# Factor 5: Candidate-set structure
structures <- if (QUICK) "uniform" else c("uniform", "block", "hierarchical")

# Replicates
R <- if (QUICK) 200 else 10000

# Build the configuration grid
configs <- expand.grid(
  m_idx = seq_along(ms),
  n_idx = seq_along(ns),
  rate_idx = 1:3,
  struct_idx = seq_along(structures),
  stringsAsFactors = FALSE
)

# Expand w values per m
config_list <- list()
for (i in seq_len(nrow(configs))) {
  m <- ms[configs$m_idx[i]]
  ws <- make_ws(m)
  rates <- make_rates(m)
  rate_name <- names(rates)[configs$rate_idx[i]]
  theta <- rates[[configs$rate_idx[i]]]

  for (w in ws) {
    config_list[[length(config_list) + 1]] <- list(
      m = m,
      w = w,
      n = ns[configs$n_idx[i]],
      theta = theta,
      rate_config = rate_name,
      structure = structures[configs$struct_idx[i]]
    )
  }
}

cat(sprintf("Total configurations: %d\n", length(config_list)))
cat(sprintf("Replicates per config: %d\n", R))


# ── Single-configuration simulation ───────────────────────────────────────

run_config <- function(cfg, R, seed_offset = 0) {
  m <- cfg$m
  w <- cfg$w
  n <- cfg$n
  theta <- cfg$theta
  structure <- cfg$structure

  # Pre-compute theoretical quantities
  n_mc_theory <- if (QUICK) 50000 else 200000
  I_comp <- fim_complete(theta)
  I_mask_theory <- fim_masked(theta, w, n_mc = n_mc_theory, structure = structure)
  evals_comp <- eigen(I_comp, symmetric = TRUE)$values
  evals_mask <- eigen(I_mask_theory, symmetric = TRUE)$values

  r_theory <- min(evals_mask) / min(evals_comp)
  kappa_theory <- max(evals_mask) / min(evals_mask)
  fmi_theory <- 1 - diag(I_mask_theory) / diag(I_comp)

  # Storage for replicate results
  mle_mat <- matrix(NA, nrow = R, ncol = m)
  converged <- logical(R)
  n_iters <- numeric(R)
  obs_fim_list <- vector("list", R)

  for (rep in seq_len(R)) {
    set.seed(seed_offset + rep)
    df <- generate_data(theta, n, w, tau = Inf, structure = structure)

    fit <- fit_mle(df, m, par0 = theta, n_starts = if (QUICK) 1 else 3)
    mle_mat[rep, ] <- fit$par
    converged[rep] <- fit$converged
    n_iters[rep] <- fit$n_iter

    if (fit$converged) {
      obs_fim_list[[rep]] <- -fit$hessian
    }
  }

  # ── Compute response variables ──

  # 1. Bias and MSE
  bias <- colMeans(mle_mat[converged, , drop = FALSE]) - theta
  mse  <- colMeans((mle_mat[converged, , drop = FALSE] -
                     matrix(theta, sum(converged), m, byrow = TRUE))^2)

  # 2. Coverage of 95% Wald CI
  coverage <- rep(NA_real_, m)
  for (j in seq_len(m)) {
    se_j <- sqrt(1 / (n * diag(I_mask_theory)[j]))
    lower <- mle_mat[converged, j] - 1.96 * se_j
    upper <- mle_mat[converged, j] + 1.96 * se_j
    coverage[j] <- mean(lower <= theta[j] & theta[j] <= upper)
  }

  # 3. Eigenvalue spectrum of observed FIM (average over converged replicates)
  obs_evals <- matrix(NA, nrow = sum(converged), ncol = m)
  idx <- 0
  for (rep in which(converged)) {
    idx <- idx + 1
    obs_evals[idx, ] <- sort(eigen(obs_fim_list[[rep]],
                                    symmetric = TRUE)$values,
                              decreasing = TRUE)
  }
  mean_obs_evals <- colMeans(obs_evals[seq_len(idx), , drop = FALSE])

  # 4. Effective sample size (empirical)
  # MSE ratio approach: r_emp = MSE_complete / MSE_masked (for w=1 baseline)
  r_empirical <- min(evals_mask) / min(evals_comp)  # from theory; empirical below

  # Empirical ESS from MSE: E[MSE_masked] ≈ tr(I_mask^{-1})/m for balanced case
  # We compute the worst-case direction MSE ratio
  worst_mse_masked <- max(mse)
  # For complete data (w=1), theoretical MSE = 1/(n * I_comp_{jj})
  worst_mse_complete <- 1 / (n * min(diag(I_comp)))
  r_empirical_mse <- worst_mse_complete / worst_mse_masked

  # 5. FMI (empirical vs theoretical)
  fmi_empirical <- rep(NA_real_, m)
  mean_obs_fim <- Reduce("+", obs_fim_list[converged]) / sum(converged)
  fmi_empirical <- 1 - diag(mean_obs_fim) / (n * diag(I_comp))

  # 6. Convergence rate
  mean_iters <- mean(n_iters[converged])

  # 7. Non-identifiability rate
  nonident_rate <- 1 - mean(converged)

  list(
    # Configuration
    m = m, w = w, n = n,
    rate_config = cfg$rate_config,
    structure = structure,
    theta = theta,

    # Theoretical quantities
    r_theory = r_theory,
    kappa_theory = kappa_theory,
    fmi_theory = fmi_theory,
    evals_theory = sort(n * evals_mask, decreasing = TRUE),

    # Response variables
    bias = bias,
    mse = mse,
    coverage = coverage,
    mean_obs_evals = mean_obs_evals,
    r_empirical = r_empirical_mse,
    fmi_empirical = fmi_empirical,
    mean_iters = mean_iters,
    nonident_rate = nonident_rate,
    n_converged = sum(converged)
  )
}


# ── Run all configurations ─────────────────────────────────────────────────

cat("Starting simulation study...\n")
cat(sprintf("Quick mode: %s\n", QUICK))

results <- vector("list", length(config_list))

for (i in seq_along(config_list)) {
  cfg <- config_list[[i]]
  cat(sprintf("[%d/%d] m=%d, w=%d, n=%d, rates=%s, struct=%s ...",
              i, length(config_list), cfg$m, cfg$w, cfg$n,
              cfg$rate_config, cfg$structure))

  t0 <- proc.time()
  results[[i]] <- run_config(cfg, R, seed_offset = i * R)
  elapsed <- (proc.time() - t0)["elapsed"]

  cat(sprintf(" done (%.1fs, nonident=%.1f%%)\n",
              elapsed, 100 * results[[i]]$nonident_rate))
  flush.console()
}


# ── Save results ───────────────────────────────────────────────────────────

outdir <- file.path(this_dir, "results")
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

suffix <- if (QUICK) "_quick" else ""
outfile <- file.path(outdir, paste0("simulation_results", suffix, ".rds"))
saveRDS(results, outfile)
cat(sprintf("\nResults saved to %s\n", outfile))


# ── Summary table ──────────────────────────────────────────────────────────

summary_df <- do.call(rbind, lapply(results, function(r) {
  data.frame(
    m = r$m,
    w = r$w,
    n = r$n,
    rate_config = r$rate_config,
    structure = r$structure,
    max_bias = max(abs(r$bias)),
    max_mse = max(r$mse),
    min_coverage = min(r$coverage),
    max_coverage = max(r$coverage),
    r_theory = r$r_theory,
    r_empirical = r$r_empirical,
    kappa_theory = r$kappa_theory,
    mean_fmi_theory = mean(r$fmi_theory),
    mean_fmi_empirical = mean(r$fmi_empirical),
    mean_iters = r$mean_iters,
    nonident_rate = r$nonident_rate,
    n_converged = r$n_converged,
    stringsAsFactors = FALSE
  )
}))

csvfile <- file.path(outdir, paste0("summary", suffix, ".csv"))
write.csv(summary_df, csvfile, row.names = FALSE)
cat(sprintf("Summary saved to %s\n", csvfile))

cat("\n=== Summary (first 20 rows) ===\n")
print(head(summary_df, 20))
