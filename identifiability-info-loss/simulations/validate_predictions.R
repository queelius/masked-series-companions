#!/usr/bin/env Rscript
# validate_predictions.R — Test theoretical predictions P1-P6
#
# Reads simulation results and produces validation tables + figures.
# Usage:
#   Rscript validate_predictions.R                    # full results
#   Rscript validate_predictions.R --quick            # quick results

args <- commandArgs(trailingOnly = TRUE)
QUICK <- "--quick" %in% args
suffix <- if (QUICK) "_quick" else ""

this_dir <- tryCatch(
  dirname(sys.frame(1)$ofile),
  error = function(e) getwd()
)

# Load results
resdir <- file.path(this_dir, "results")
resfile <- file.path(resdir, paste0("simulation_results", suffix, ".rds"))
if (!file.exists(resfile)) stop("Results not found: ", resfile, "\nRun run_simulation.R first.")
results <- readRDS(resfile)

figdir <- file.path(this_dir, "figures")
if (!dir.exists(figdir)) dir.create(figdir)


# ── P1: MSE scaling ───────────────────────────────────────────────────────
# Empirical MSE should scale as 1/(n * lambda_min(I_masked))

cat("\n=== P1: MSE Scaling ===\n")

# For uniform structure, equal rates: collect MSE vs n for each (m, w)
p1 <- do.call(rbind, lapply(results, function(r) {
  if (r$structure != "uniform" || r$rate_config != "equal") return(NULL)
  data.frame(m = r$m, w = r$w, n = r$n,
             max_mse = max(r$mse),
             r_theory = r$r_theory,
             predicted_mse_ratio = 1 / r$r_theory)
}))

if (nrow(p1) > 0) {
  # MSE * n should be approximately constant for each (m, w)
  p1$mse_times_n <- p1$max_mse * p1$n
  cat("MSE * n by (m, w) — should be approx constant across n:\n")
  for (m_val in unique(p1$m)) {
    for (w_val in unique(p1$w[p1$m == m_val])) {
      sub <- p1[p1$m == m_val & p1$w == w_val, ]
      cat(sprintf("  m=%d, w=%d: MSE*n = %s\n", m_val, w_val,
                  paste(sprintf("%.4f", sub$mse_times_n), collapse = ", ")))
    }
  }
}


# ── P2: Coverage ──────────────────────────────────────────────────────────
# Wald CI coverage should approach 95% as n increases

cat("\n=== P2: Coverage ===\n")

p2 <- do.call(rbind, lapply(results, function(r) {
  if (r$structure != "uniform") return(NULL)
  data.frame(m = r$m, w = r$w, n = r$n,
             rate_config = r$rate_config,
             min_coverage = min(r$coverage),
             max_coverage = max(r$coverage),
             mean_coverage = mean(r$coverage))
}))

if (nrow(p2) > 0) {
  cat("Coverage by n (uniform structure):\n")
  for (rc in unique(p2$rate_config)) {
    cat(sprintf("\n  Rate config: %s\n", rc))
    sub <- p2[p2$rate_config == rc, ]
    agg <- aggregate(mean_coverage ~ n + w, data = sub, FUN = mean)
    print(agg)
  }
}


# ── P3: Monotonicity ─────────────────────────────────────────────────────
# Information loss should increase monotonically with w

cat("\n=== P3: Monotonicity ===\n")

p3 <- do.call(rbind, lapply(results, function(r) {
  if (r$structure != "uniform" || r$rate_config != "equal") return(NULL)
  data.frame(m = r$m, w = r$w, n = r$n,
             mean_fmi = mean(r$fmi_empirical),
             mean_fmi_theory = mean(r$fmi_theory),
             max_mse = max(r$mse))
}))

if (nrow(p3) > 0) {
  cat("FMI by w (equal rates, uniform, n=1000):\n")
  sub3 <- p3[p3$n == max(p3$n), ]
  for (m_val in unique(sub3$m)) {
    s <- sub3[sub3$m == m_val, ]
    s <- s[order(s$w), ]
    cat(sprintf("  m=%d: w=%s, FMI_emp=%s, FMI_theory=%s\n",
                m_val,
                paste(s$w, collapse=","),
                paste(sprintf("%.3f", s$mean_fmi), collapse=","),
                paste(sprintf("%.3f", s$mean_fmi_theory), collapse=",")))
    # Check monotonicity
    if (all(diff(s$mean_fmi) >= -0.02)) {
      cat("    -> PASS (monotone increasing)\n")
    } else {
      cat("    -> FAIL (not monotone)\n")
    }
  }
}


# ── P4: Effective sample size ────────────────────────────────────────────
# Empirical n_eff should match theory

cat("\n=== P4: Effective Sample Size ===\n")

source(file.path(this_dir, "helpers.R"))

p4 <- do.call(rbind, lapply(results, function(r) {
  if (r$structure != "uniform" || r$rate_config != "equal") return(NULL)
  r_th <- ess_ratio_theory(r$m, r$w)
  data.frame(m = r$m, w = r$w, n = r$n,
             r_theory_formula = r_th,
             r_theory_mc = r$r_theory,
             r_empirical = r$r_empirical)
}))

if (nrow(p4) > 0) {
  cat("ESS ratio r (equal rates, uniform, largest n):\n")
  sub4 <- p4[p4$n == max(p4$n), ]
  for (m_val in unique(sub4$m)) {
    s <- sub4[sub4$m == m_val, ]
    s <- s[order(s$w), ]
    cat(sprintf("  m=%d:\n", m_val))
    for (i in seq_len(nrow(s))) {
      cat(sprintf("    w=%d: r_formula=%.4f, r_mc=%.4f, r_emp=%.4f\n",
                  s$w[i], s$r_theory_formula[i], s$r_theory_mc[i],
                  s$r_empirical[i]))
    }
  }
}


# ── P5: Condition number ────────────────────────────────────────────────
# Eigenvalue ratio should match kappa(I_masked)

cat("\n=== P5: Condition Number ===\n")

p5 <- do.call(rbind, lapply(results, function(r) {
  if (r$structure != "uniform") return(NULL)
  if (length(r$mean_obs_evals) < 2) return(NULL)
  kappa_emp <- max(r$mean_obs_evals) / min(r$mean_obs_evals)
  data.frame(m = r$m, w = r$w, n = r$n,
             rate_config = r$rate_config,
             kappa_theory = r$kappa_theory,
             kappa_empirical = kappa_emp)
}))

if (nrow(p5) > 0) {
  cat("Condition number (uniform, largest n):\n")
  sub5 <- p5[p5$n == max(p5$n), ]
  for (rc in unique(sub5$rate_config)) {
    cat(sprintf("\n  Rate config: %s\n", rc))
    s <- sub5[sub5$rate_config == rc, ]
    s <- s[order(s$m, s$w), ]
    for (i in seq_len(nrow(s))) {
      cat(sprintf("    m=%d, w=%d: kappa_theory=%.2f, kappa_emp=%.2f\n",
                  s$m[i], s$w[i], s$kappa_theory[i], s$kappa_empirical[i]))
    }
  }
}


# ── P6: Non-identifiability rates ───────────────────────────────────────
# Should decrease with n, increase with w and rate asymmetry

cat("\n=== P6: Non-identifiability Rates ===\n")

p6 <- do.call(rbind, lapply(results, function(r) {
  if (r$structure != "uniform") return(NULL)
  data.frame(m = r$m, w = r$w, n = r$n,
             rate_config = r$rate_config,
             nonident_rate = r$nonident_rate)
}))

if (nrow(p6) > 0) {
  cat("Non-identifiability rate by (m, w, n, rate_config):\n")
  for (rc in unique(p6$rate_config)) {
    cat(sprintf("\n  Rate config: %s\n", rc))
    sub <- p6[p6$rate_config == rc & p6$m == 5, ]
    if (nrow(sub) > 0) {
      sub <- sub[order(sub$w, sub$n), ]
      print(sub[, c("w", "n", "nonident_rate")])
    }
  }
}


# ── Generate figures ─────────────────────────────────────────────────────

cat("\n=== Generating figures ===\n")

# Figure 1: ESS ratio vs w for different m (equal rates, uniform)
if (nrow(p4) > 0) {
  pdf(file.path(figdir, "fig_ess_ratio.pdf"), width = 6, height = 4)
  sub <- p4[p4$n == max(p4$n), ]
  cols <- c("3" = "black", "5" = "red", "10" = "blue")
  plot(NULL, xlim = c(1, 9), ylim = c(0, 1),
       xlab = "Masking cardinality w",
       ylab = "ESS ratio r",
       main = "Effective sample size ratio vs masking cardinality")
  for (m_val in unique(sub$m)) {
    s <- sub[sub$m == m_val, ]
    s <- s[order(s$w), ]
    lines(s$w, s$r_theory_formula, col = cols[as.character(m_val)], lwd = 2)
    points(s$w, s$r_empirical, col = cols[as.character(m_val)], pch = 16)
  }
  legend("topright", legend = paste("m =", names(cols)),
         col = cols, lwd = 2, pch = 16)
  dev.off()
  cat("  Saved fig_ess_ratio.pdf\n")
}

# Figure 2: FMI vs w (monotonicity test)
if (nrow(p3) > 0) {
  pdf(file.path(figdir, "fig_fmi_monotone.pdf"), width = 6, height = 4)
  sub <- p3[p3$n == max(p3$n), ]
  cols <- c("3" = "black", "5" = "red", "10" = "blue")
  plot(NULL, xlim = c(1, 9), ylim = c(0, 1),
       xlab = "Masking cardinality w",
       ylab = "Mean fraction of missing information",
       main = "FMI monotonicity (equal rates, uniform masking)")
  for (m_val in unique(sub$m)) {
    s <- sub[sub$m == m_val, ]
    s <- s[order(s$w), ]
    lines(s$w, s$mean_fmi_theory, col = cols[as.character(m_val)],
          lwd = 2, lty = 2)
    points(s$w, s$mean_fmi, col = cols[as.character(m_val)], pch = 16)
  }
  legend("topleft", legend = paste("m =", names(cols)),
         col = cols, lwd = 2, pch = 16)
  legend("bottomright", legend = c("Theory", "Empirical"),
         lty = c(2, NA), pch = c(NA, 16), lwd = c(2, NA))
  dev.off()
  cat("  Saved fig_fmi_monotone.pdf\n")
}

# Figure 3: Coverage vs n (convergence to nominal)
if (nrow(p2) > 0) {
  pdf(file.path(figdir, "fig_coverage.pdf"), width = 7, height = 5)
  sub <- p2[p2$rate_config == "equal" & p2$m == 5, ]
  cols <- c("1" = "black", "3" = "red", "4" = "blue")
  plot(NULL, xlim = range(sub$n), ylim = c(0.7, 1),
       xlab = "Sample size n", ylab = "Coverage",
       main = "95% Wald CI coverage (m=5, equal rates, uniform)",
       log = "x")
  abline(h = 0.95, lty = 3, col = "gray")
  for (w_val in unique(sub$w)) {
    s <- sub[sub$w == w_val, ]
    s <- s[order(s$n), ]
    lines(s$n, s$mean_coverage, col = cols[as.character(w_val)], lwd = 2)
    points(s$n, s$mean_coverage, col = cols[as.character(w_val)], pch = 16)
  }
  legend("bottomright", legend = paste("w =", names(cols)),
         col = cols, lwd = 2, pch = 16)
  dev.off()
  cat("  Saved fig_coverage.pdf\n")
}

# Figure 4: Condition number vs w for different rate configs
if (nrow(p5) > 0) {
  pdf(file.path(figdir, "fig_condition_number.pdf"), width = 6, height = 4)
  sub <- p5[p5$n == max(p5$n) & p5$m == 5, ]
  cols <- c("equal" = "black", "moderate" = "red", "strong" = "blue")
  plot(NULL, xlim = range(sub$w), ylim = c(1, max(sub$kappa_theory) * 1.2),
       xlab = "Masking cardinality w",
       ylab = expression(kappa(I[masked])),
       main = "Condition number (m=5, uniform masking)",
       log = "y")
  for (rc in unique(sub$rate_config)) {
    s <- sub[sub$rate_config == rc, ]
    s <- s[order(s$w), ]
    lines(s$w, s$kappa_theory, col = cols[rc], lwd = 2, lty = 2)
    points(s$w, s$kappa_empirical, col = cols[rc], pch = 16)
  }
  legend("topleft", legend = names(cols), col = cols, lwd = 2, pch = 16)
  dev.off()
  cat("  Saved fig_condition_number.pdf\n")
}

cat("\nValidation complete.\n")
