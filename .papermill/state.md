# Masked Series Companions — Collection State

**Repo**: `~/github/papers/masked-series-companions/`
**Type**: Multi-paper research planning repo
**Author**: Alexander Towell (lex@metafunctor.com, ORCID: 0000-0001-6443-9897, SIUE)
**Foundation paper**: `~/github/papers/masked-causes-in-series-systems/` (DOI: 10.5281/zenodo.18725577)
**Last refreshed**: 2026-02-26

## Paper Dashboard

| Dir | Title | Phase | Venue | Priority | Key artifacts |
|-----|-------|-------|-------|----------|---------------|
| `deterministic-masking/` | Information Recovery under Deterministic Masking | **submitted** (JSPI, v0.3.0, 6pp) | JSPI | — | `paper/main.tex`, `paper/references.bib` (7 refs) |
| `identifiability-info-loss/` | Identifiability and Information Loss | `drafting` (21pp, 36 refs) | JSPI / Biometrika | High | `paper.tex`, `refs.bib`, `simulations/` |
| `weibull-masked-fim/` | Closed-Form FIM for Weibull Series | `draft` (v0.1.0, 8pp, 13 refs) | Lifetime Data Analysis | **Highest** | `paper.tex`, `refs.bib`, `notes/fim-derivation.md`, `notes/verify-fim.R` |
| `observation-composition/` | Composable Observation Schemes | `idea` | JRSS-B short comm | Low | `brief.md` |
| `nesting-vs-structure/` | Statistical Parsimony vs Physical Structure | `idea` | The American Statistician | Low | `brief.md` |

**Absorbed**: `02-information-loss/` merged into `identifiability-info-loss/` (2026-02-17). Brief archived at `identifiability-info-loss/notes/02-info-loss-brief.md`.

## Submission Sequencing

1. **deterministic-masking** — submitted to JSPI (2026-02-23, transferred from S&PL desk-rejection)
2. **weibull-masked-fim** (Weibull FIM) — **draft complete** (v0.1.0). Internal review, then submit to LDA.
3. **Foundation paper** — do not submit until weibull-masked-fim has circulating draft (**gate now open**)
4. **Paper 01** — first draft complete (21pp). Depends on weibull-masked-fim's Weibull FIM derivation (now resolved). Simulation study pending.
5. **Papers 03, 04** — independent of sequencing above; both at idea stage

## Ecosystem Coordination

See `ECOSYSTEM.md` § "Ecosystem Coordination" for the full coordination framework:
- **FIM ownership**: weibull-masked-fim derives Weibull FIM (Theorem 1); Paper 01 cites it
- **Masking invariance**: weibull-masked-fim proves shape info invariant under masking (Theorem 2); Paper 01 uses this in its info loss decomposition
- **Indistinguishability split**: Paper 01 (formal conditions) / model selection paper (LRT power) / Paper 04 (decision-theoretic)
- **Prior-art surveys**: needed for Papers 03, 04 before drafting; weibull-masked-fim prior art completed (no closed-form FIM found in literature)

## Review Findings (2026-02-18, partially lost in re-init)

A `papermill:review` was conducted on 2026-02-18 with severity-ranked findings for all papers. The review was incorporated into the `.papermill.md` state files but those were subsequently re-initialized (2026-02-18 later), losing some annotations. Key findings that should be tracked:

### Paper 01 — Critical
- **Scope ~2x a single article**: 13 sections, 12 results (8 open). Consider splitting into Paper A (structural → JSPI) and Paper B (Fisher + design → Biometrika). Decision still open.
- **Loewner inequality (Result 5) has no proof route**: candidate via Zamir (1998) Fisher info DPI. Must resolve before committing to general-family scope.
- **No prior-art survey**: 4 high-risk overlap areas (Lindqvist identifiability graphs, Little & Rubin FMI, compressed sensing, effective sample size in MI).
- **Partial identifiability caveat**: restrict to exponential case — heterogeneous Weibull with distinct shapes may restore identifiability.
- **Self-containment**: restatement-plus-sketch suffices; full reproof adds 6-10 pages of redundancy.
- **n_eff**: scalar definition conflates matrix quantities. Specify scalar reduction (det ratio, eigenvalue ratio).
- **Status update (2026-02-26)**: First complete draft addresses 6/12 results fully proved, 2 proof-sketched, 1 design-complete, 3 discussed. Simulation study still pending.

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

### weibull-masked-fim — Draft complete
- ~~**FIM is the central open question**~~: **RESOLVED (2026-02-26)**. Closed-form FIM derived in (k, λ) parametrization. Uses only γ (Euler-Mascheroni) and π²/6 — no numerical integration. Verified by Monte Carlo (n=10⁶, <0.5% error).
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
| `identifiability-info-loss/.papermill.md` | Paper 01 state (merged with 02) |
| `identifiability-info-loss/paper.tex` | Paper 01 manuscript (21pp draft) |
| `identifiability-info-loss/refs.bib` | Paper 01 bibliography (36 entries) |
| `observation-composition/.papermill.md` | Paper 03 state |
| `nesting-vs-structure/.papermill.md` | Paper 04 state |
| `weibull-masked-fim/.papermill.md` | weibull-masked-fim state |
| `weibull-masked-fim/paper.tex` | weibull-masked-fim manuscript (8pp draft) |
| `weibull-masked-fim/refs.bib` | weibull-masked-fim bibliography (13 entries) |
| `weibull-masked-fim/notes/fim-derivation.md` | FIM derivation notes |
| `weibull-masked-fim/notes/verify-fim.R` | Monte Carlo verification (PASS) |
| `deterministic-masking/.papermill.md` | Deterministic masking state (submitted) |
| `deterministic-masking/paper/main.tex` | Deterministic masking manuscript (6pp, submitted) |

## Log

- **2026-02-17**: Individual `.papermill.md` files created for all 5 companion papers.
- **2026-02-17**: Paper 02 merged into Paper 01.
- **2026-02-18**: papermill:review conducted. Findings incorporated into state files.
- **2026-02-18**: State files re-initialized with foundation paper citations and ecosystem cross-references. Some review annotations overwritten.
- **2026-02-22**: deterministic-masking paper completed, submitted to S&PL.
- **2026-02-23**: deterministic-masking desk-rejected by S&PL, transferred to JSPI.
- **2026-02-26**: Root-level `.papermill/state.md` created as collection dashboard.
- **2026-02-26**: weibull-masked-fim FIM gate resolved. Closed-form Fisher information matrix for homogeneous Weibull series derived and numerically verified. Phase advanced from `idea` to `research`.
- **2026-02-26**: weibull-masked-fim draft v0.1.0 written (8pp, 2 theorems, MC verification). Venue: Lifetime Data Analysis.
- **2026-02-26**: Paper 01 first complete draft produced (21pp, 36 refs, 12 key results addressed).
- **2026-02-26**: State file refreshed via papermill:init. Updated dashboard, sequencing (weibull-masked-fim gate now open for foundation paper), and files inventory.
