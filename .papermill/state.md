# Masked Series Companions — Collection State

**Repo**: `~/github/papers/masked-series-companions/`
**Type**: Multi-paper research planning repo
**Author**: Alexander Towell (lex@metafunctor.com, ORCID: 0000-0001-6443-9897, SIUE)
**Foundation paper**: `~/github/papers/masked-causes-in-series-systems/` (DOI: 10.5281/zenodo.18725577)
**Last refreshed**: 2026-03-13

## Paper Dashboard

| Dir | Title | Phase | Venue | Priority | Key artifacts |
|-----|-------|-------|-------|----------|---------------|
| `deterministic-masking/` | Information Recovery under Deterministic Masking | **submitted** (JSPI, v0.3.0, 6pp) | JSPI | — | `paper/main.tex`, `paper/references.bib` (7 refs) |
| `weibull-masked-fim/` | Closed-Form FIM for Weibull Series | `draft` (v0.1.0, 8pp, 13 refs) | Lifetime Data Analysis | **Highest** | `paper.tex`, `refs.bib`, `notes/fim-derivation.md`, `notes/verify-fim.R` |

**Dropped**:
- `observation-composition/` (2026-02-27) — insufficient novelty
- `nesting-vs-structure/` (2026-02-27) — insufficient novelty
- `identifiability-info-loss/` (2026-03-13) — bloated scope, headline result (Louis 1982) not novel. Graph-theoretic identifiability result integrated into foundation paper (`paper.tex`).

## Submission Sequencing

1. **deterministic-masking** — submitted to JSPI (2026-02-23, transferred from S&PL desk-rejection)
2. **weibull-masked-fim** (Weibull FIM) — **draft complete** (v0.1.0). Internal review, then submit to LDA.
3. **Foundation paper** — do not submit until weibull-masked-fim has circulating draft (**gate now open**)

## Review Findings

### weibull-masked-fim — Draft complete (2026-02-26)
- ~~**FIM is the central open question**~~: **RESOLVED**. Closed-form FIM derived in (k, λ) parametrization. Uses only γ and π²/6 — no numerical integration. Verified by Monte Carlo (n=10⁶, <0.5% error).
- **Masking invariance proved**: shape info (I_{kk}) and cross-info (I_{k,λ_j}) unchanged under any C2 masking. Info loss confined to rate block.
- **Draft v0.1.0**: 8-page surgical paper with 2 theorems, MC verification table, 2 special case checks. Targets Lifetime Data Analysis.
- **Remaining review items**: thesis differentiation from published thesis (3-point novelty statement), starting-value sensitivity (deferred to future work), data source (deferred — theory paper)

## DOIs and Citations

| Paper | DOI | Citation Key |
|-------|-----|-------------|
| Foundation (C1-C2-C3 framework) | 10.5281/zenodo.18725577 | `towell2025masked` |
| Expo companion (FIM, max-entropy) | 10.5281/zenodo.18344335 | `towell2025expo` |
| Master's project | 10.5281/zenodo.18615871 | `towell2023reliability` |
| Deterministic masking | pending Zenodo deposit | `towell2026deterministic` |

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project conventions |
| `README.md` | Repo overview with ecosystem map |
| `ECOSYSTEM.md` | Full paper/package ecosystem with coordination section |
| `weibull-masked-fim/.papermill.md` | Weibull FIM state |
| `weibull-masked-fim/paper.tex` | Weibull FIM manuscript (8pp draft) |
| `weibull-masked-fim/refs.bib` | Weibull FIM bibliography (13 entries) |
| `weibull-masked-fim/notes/fim-derivation.md` | FIM derivation notes |
| `weibull-masked-fim/notes/verify-fim.R` | Monte Carlo verification (PASS) |
| `deterministic-masking/.papermill.md` | Deterministic masking state (submitted) |
| `deterministic-masking/paper/main.tex` | Deterministic masking manuscript (6pp, submitted) |

## Log

- **2026-02-17**: Individual `.papermill.md` files created for all 5 companion papers.
- **2026-02-17**: Paper 02 merged into Paper 01.
- **2026-02-18**: papermill:review conducted. Findings incorporated into state files.
- **2026-02-18**: State files re-initialized with foundation paper citations and ecosystem cross-references.
- **2026-02-22**: deterministic-masking paper completed, submitted to S&PL.
- **2026-02-23**: deterministic-masking desk-rejected by S&PL, transferred to JSPI.
- **2026-02-26**: weibull-masked-fim FIM gate resolved. Closed-form FIM derived and verified. Phase → `draft`.
- **2026-02-26**: weibull-masked-fim draft v0.1.0 written (8pp, 2 theorems, MC verification). Venue: LDA.
- **2026-02-27**: Directories renamed (numeric prefixes removed).
- **2026-02-27**: Dropped observation-composition and nesting-vs-structure — insufficient novelty.
- **2026-03-13**: Dropped identifiability-info-loss — bloated scope, headline result not novel. Graph-theoretic identifiability result integrated into foundation paper.
- **2026-03-13**: State file refreshed.
