# Masked Series Companions — Collection State

**Repo**: `~/github/papers/masked-series-companions/`
**Type**: Multi-paper research planning repo
**Author**: Alexander Towell (lex@metafunctor.com, ORCID: 0000-0001-6443-9897, SIUE)
**Foundation paper**: `~/github/papers/masked-causes-in-series-systems/` (DOI: 10.5281/zenodo.18725577)
**Last refreshed**: 2026-02-26

## Paper Dashboard

| Dir | Title | Phase | Venue | Priority | State file |
|-----|-------|-------|-------|----------|------------|
| `deterministic-masking/` | Information Recovery under Deterministic Masking | **submitted** (JSPI, transferred from S&PL) | JSPI | — | `.papermill.md` (v0.3.0) |
| `01-identifiability/` | Identifiability and Information Loss | `research` | JSPI / Biometrika | High | `.papermill.md` |
| `05-weibull-companion/` | MLE for Weibull Series Systems | `idea` | IEEE Trans. Reliability | **Highest** | `.papermill.md` |
| `03-observation-composition/` | Composable Observation Schemes | `idea` | JRSS-B short comm | Low | `.papermill.md` |
| `04-nesting-vs-structure/` | Statistical Parsimony vs Physical Structure | `idea` | The American Statistician | Low | `.papermill.md` |

**Absorbed**: `02-information-loss/` merged into `01-identifiability/` (2026-02-17). Brief archived at `01-identifiability/notes/02-info-loss-brief.md`.

## Submission Sequencing

1. **deterministic-masking** — submitted to JSPI (2026-02-23, transferred from S&PL desk-rejection)
2. **Paper 05** (Weibull MLE) — draft next. Already cited in foundation paper as `towell2025weibull-series`
3. **Foundation paper** — do not submit until Paper 05 has circulating draft
4. **Paper 01** — depends on Paper 05's Weibull FIM derivation
5. **Papers 03, 04** — independent of sequencing above

## Ecosystem Coordination

See `ECOSYSTEM.md` § "Ecosystem Coordination" for the full coordination framework:
- **FIM ownership**: Paper 05 derives Weibull FIM; Paper 01 cites it
- **Indistinguishability split**: Paper 01 (formal conditions) / model selection paper (LRT power) / Paper 04 (decision-theoretic)
- **Prior-art surveys**: needed for all companion papers before drafting

## Review Findings (2026-02-18, partially lost in re-init)

A `papermill:review` was conducted on 2026-02-18 with severity-ranked findings for all papers. The review was incorporated into the `.papermill.md` state files but those were subsequently re-initialized (2026-02-18 later), losing some annotations. Key findings that should be tracked:

### Paper 01 — Critical
- **Scope ~2x a single article**: 13 sections, 12 results (8 open). Consider splitting into Paper A (structural → JSPI) and Paper B (Fisher + design → Biometrika). Decision still open.
- **Loewner inequality (Result 5) has no proof route**: candidate via Zamir (1998) Fisher info DPI. Must resolve before committing to general-family scope.
- **No prior-art survey**: 4 high-risk overlap areas (Lindqvist identifiability graphs, Little & Rubin FMI, compressed sensing, effective sample size in MI).
- **Partial identifiability caveat**: restrict to exponential case — heterogeneous Weibull with distinct shapes may restore identifiability.
- **Self-containment**: restatement-plus-sketch suffices; full reproof adds 6-10 pages of redundancy.
- **n_eff**: scalar definition conflates matrix quantities. Specify scalar reduction (det ratio, eigenvalue ratio).

### Paper 03 — Minor revision of plan
- Two closure theorems too thin for Stat&Comp → revised primary to **JRSS-B short comm**
- Category-theoretic language should be **cut** unless rigorously developed
- C3 condition under censoring composition needs precise measurability condition on tau
- Needs concrete motivating example foundation paper can't handle

### Paper 04 — Major revision of plan
- **Nesting chain error** (corrected in brief.md): single Weibull is misspecification, not parametric nesting
- **Thesis reframe**: decision-theoretic question ("when is a misspecified model better than near-non-identifiable?") is more novel than epistemological framing
- Overlap with model selection paper reduced (maskedselect repo deleted; software in maskedcauses vignette)
- All 4 key results "open" with no sketch — most underspecified of all papers
- Effort revised Low → Medium

### Paper 05 — Ready to draft (highest priority)
- **Score equation honesty**: closed-form for exact/right-censored; numerical gradient for left/interval. Must distinguish clearly.
- **FIM is the central open question**: digamma/trigamma integrals may yield closed form for homogeneous Weibull. Resolve before writing.
- **Thesis differentiation from published thesis**: write 3-point novelty statement
- **Starting-value sensitivity**: promote to substantive section, not Discussion remark
- **Data source**: identify real dataset or commit to synthetic case study

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
| `01-identifiability/.papermill.md` | Paper 01 state (merged with 02) |
| `03-observation-composition/.papermill.md` | Paper 03 state |
| `04-nesting-vs-structure/.papermill.md` | Paper 04 state |
| `05-weibull-companion/.papermill.md` | Paper 05 state |
| `deterministic-masking/.papermill.md` | Deterministic masking state (submitted) |

## Log

- **2026-02-17**: Individual `.papermill.md` files created for all 5 companion papers.
- **2026-02-17**: Paper 02 merged into Paper 01.
- **2026-02-18**: papermill:review conducted. Findings incorporated into state files.
- **2026-02-18**: State files re-initialized with foundation paper citations and ecosystem cross-references. Some review annotations overwritten.
- **2026-02-22**: deterministic-masking paper completed, submitted to S&PL.
- **2026-02-23**: deterministic-masking desk-rejected by S&PL, transferred to JSPI.
- **2026-02-26**: Root-level `.papermill/state.md` created as collection dashboard.
