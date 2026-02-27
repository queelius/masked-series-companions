# Writing Plan: Identifiability and Information Loss in Masked Series Systems

## Date: 2026-02-26

## Thesis

The foundation paper's identifiability theorem is binary (yes/no). This paper develops the full quantitative story: graph-theoretic conditions for partial identifiability, matrix-rank conditions for the exponential case, Fisher information decomposition into complete-data and masking-loss components, effective sample size for practitioners, and optimal diagnostic design.

## Section Assignment Table

| Section | Writer | Dependencies | Key Content |
|---------|--------|-------------|-------------|
| Abstract | Orchestrator | Full draft | Self-contained summary |
| 1. Introduction | Orchestrator | Full draft | Motivation, contribution list, paper roadmap |
| 2. Preliminaries | Formal | None | Notation, C1-C2-C3, likelihood recap, identifiability theorem |
| 3. Graph-Theoretic Characterization | Formal | Sec 2 | Confounding graph, super-components, partial identifiability |
| 4. Candidate-Set Matrix Rank | Formal | Sec 2 | Exponential rank condition (self-contained) |
| 5. Fisher Information Decomposition | Formal + Method | Sec 2 | I_masked = I_complete - Delta, general proof |
| 6. Exponential Case (Closed Form) | Formal | Sec 5 | Explicit FIM, explicit Delta, Loewner ordering |
| 7. Monotone Information Loss | Formal | Sec 6 | DPI proof, mutual info monotonicity, max-entropy |
| 8. Effective Sample Size | Method + Results | Sec 6-7 | n_eff definition, exponential formulas |
| 9. Near-Non-Identifiability Diagnostics | Method | Sec 5-6 | Profile likelihood, curvature ratio, thresholds |
| 10. Optimal Diagnostic Design | Method | Sec 5, 8 | D-optimality, cost tradeoffs |
| 11. Missing Data Connection | Literature | Sec 5 | FMI, EM convergence, MAR/ignorability |
| 12. Simulation Study | Results | All theory | Experimental design, predictions |
| 13. Discussion | Orchestrator | Full draft | MI vs FI, open problems, limitations |
| Conclusion | Orchestrator | Full draft | Summary, practical implications |

## Approach

Due to the highly mathematical nature of this paper and the need for notational consistency across all sections, the paper was written as a unified document by the orchestrator rather than delegated to separate agents. The content draws from:

1. **Foundation paper** (`masked-causes-in-series-systems/paper.tex`): C1-C2-C3 framework, identifiability theorem, notation
2. **Expo companion** (`expo-masked-fim/paper/main.tex`): FIM derivations, mutual information, uniform masking
3. **Brief 01** (`identifiability-info-loss/brief.md`): Graph-theoretic sketch, simulation design
4. **State file** (`.papermill.md`): Merged outline, 12 key results

## Key Results Status

| # | Result | Status in Draft |
|---|--------|----------------|
| 1 | Confounding graph equivalence | Theorem 3, complete proof |
| 2 | Exponential matrix rank condition | Theorem 4, complete proof |
| 3 | Fisher info decomposition | Theorem 5, complete proof |
| 4 | Closed-form Delta for exponential | Theorem 7, complete proof |
| 5 | Loewner order I_masked <= I_complete | Corollary 4, proved via data processing |
| 6 | Monotone info loss in w | Theorem 8, complete proof via DPI |
| 7 | Effective sample size | Proposition 8, computed for exponential |
| 8 | Profile likelihood diagnostic | Theorem 9, proof sketch |
| 9 | Optimal diagnostic design | Proposition 10, proof sketch |
| 10 | Simulation study | Design complete, results to be computed |
| 11 | General parametric extension | Discussed in limitations |
| 12 | MI vs FI connection | Discussed in Section 13 |

## Self-Containment

All exponential FIM results from expo-masked-fim are re-derived within this paper (Propositions 5-6, Theorems 7-8). The paper cites expo-masked-fim for priority but does not require the reader to consult it.
