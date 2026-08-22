# Measuring Regional Disparities in China's Digital Economy Development, 2013–2022

**A Multivariate Analysis Using PCA and Factorial MANOVA**

**Airui Meng** · Teachers College, Columbia University

This repository contains the R analysis pipeline, panel data, intermediate outputs, and
typeset report for a study that constructs a Digital Economy Development Index
(DEDI) for 31 mainland Chinese provinces, 2013–2022, and tests for regional and temporal
differences via a 4 × 2 factorial MANOVA on retained principal-component scores.

The DEDI series built here (`outputs/panel_dedi.csv`) is the key regressor in the companion
panel study [`airuimeng1/digital-economy-employment-upgrading`](https://github.com/airuimeng1/digital-economy-employment-upgrading),
which asks how digital development relates to the structure of employment. The two series
agree to 1e-13.

<img src="outputs/figures/03_region_trend.png" width="640" alt="Regional Digital Economy Development Index, 2013-2022">

---

## Headline results

- **PCA**: 4 components retained (Kaiser + Cumulative ≥ 80% rule), explaining 85.8% of
  variance after log-transforming heavy-skew indicators. Varimax rotation is applied to the
  retained loadings for interpretation only; all inference uses the unrotated, mutually
  orthogonal component scores. KMO = 0.904 ("meritorious"); Bartlett χ²(231) = 11553.82, *p* < .001.
- **Factorial MANOVA** (DVs = PC1–PC4, *n* = 310 province-years):
  - Region main effect: Pillai *V* = 0.754, *F*(12, 903) = 25.25, *p* < .001, partial η² = 0.25.
  - Period main effect: Pillai *V* = 0.719, *F*(4, 299) = 191.12, *p* < .001, partial η² = 0.72.
  - Region × Period interaction: **non-significant** (*V* = 0.021, *p* = .892, partial η² = 0.007).
- **Substantive interpretation**: every region advanced markedly between 2013–2017 and
  2018–2022, but the relative rank-ordering of regions on a four-dimensional digital-economy
  construct has not changed — dispersion widens in absolute terms (SD of DEDI 15.4 → 18.0)
  while narrowing in relative terms (CV 0.43 → 0.32).
- Sensitivity analyses (single-year MANOVA on 2018/2019/2020, year-by-year PCA
  loading stability, and outlier-removed refit) corroborate the main conclusions;
  the one caveat is PC3 (infrastructure), whose year-specific loadings track the
  full-panel solution only weakly (*r* = 0.33–0.42, versus 0.80–0.97 for PC1, PC2, PC4),
  reflecting the changing composition of "infrastructure" over the decade.

---

## Interpretation and limitations

The 4 × 2 factorial design treats 310 province-years as independent replicates, but the same 31
provinces populate every cell and both period cells. Period is therefore a within-subject factor
fitted with a between-subjects error term, so the reported *F* statistics are anti-conservative
and the region contrasts rest on 3–12 provinces per group rather than 15–60 observations.

Re-fitting the same model on province × period means (*n* = 62, which removes the year-level
replication) leaves every qualitative conclusion intact — region Pillai *V* = 0.927,
*F*(12, 159) = 5.93, *p* < .001; period *V* = 0.895, *F*(4, 51) = 109.10, *p* < .001;
interaction *V* = 0.056, *F*(12, 159) = 0.25, *p* = .995 — while the *F* statistics fall
substantially (region by a factor of 4.3, period by 1.8). The Games–Howell contrasts pool
across periods and share the same assumption, so their *p*-values are descriptive.

Full limitations are in `report/final_report.pdf`, Section 6.

## Repository structure

```
detailed-pca-manova-anl/
├── README.md                       This file.
├── LICENSE                         MIT licence for the code.
├── data/
│   ├── panel_data.xlsx              Cleaned province × year panel, 22 indicators.
│   ├── original_data.xlsx           Raw indicators before interpolation.
│   ├── interpolation_processing.xlsx
│   └── indicator_system.xlsx        3-tier indicator hierarchy.
├── R/
│   ├── 00_setup.R                   Loaders, region map, indicator labels.
│   ├── 01_descriptive.R             Descriptive statistics + missing-value audit.
│   ├── 02_pca.R                     log1p + z-score + KMO/Bartlett + PCA + Varimax.
│   ├── 03_dedi.R                    Variance-weighted DEDI composite (0–100 scale).
│   ├── 04_assumptions.R             Mardia, Box's M, Levene, Mahalanobis diagnostics.
│   ├── 05_manova.R                  Factorial MANOVA + univariate ANOVAs + Games–Howell.
│   ├── 06_sensitivity.R             Single-year MANOVA, PCA stability, outlier-drop refit.
│   └── run_all.R                    Runs stages 01–06 in order.
├── outputs/
│   ├── figures/                     8 PNG figures at 300 dpi.
│   ├── tables/                      16 CSV tables.
│   ├── pc_scores.csv                PC1–PC4 per province-year.
│   ├── panel_dedi.csv               PC1–PC4 + DEDI per province-year.
│   ├── pca_objects.rds              prcomp(), Varimax rotation, cached objects.
│   ├── manova_results.rds           lm() fit, Manova(), Games-Howell tables.
│   └── assumption_checks.rds        Mardia, Box's M, Levene, Mahalanobis.
└── report/
    ├── final_report.pdf             Typeset write-up (17 pages).
    └── final_report.tex             LaTeX source for the write-up.
```

---

## How to reproduce

The pipeline is staged so that each step writes intermediate artefacts that the next
step reads back. Run from the repository root:

```r
setwd("path/to/detailed-pca-manova-anl")

## Stage 0: shared setup (loaded automatically by each downstream script)
source("R/00_setup.R")

## Stage 1: descriptive statistics + imputation audit
source("R/01_descriptive.R")

## Stage 2: PCA — writes pc_scores.csv, pca_objects.rds, scree/cumvar/loadings figures
source("R/02_pca.R")

## Stage 3: DEDI composite + regional/temporal heatmap and trend figures
source("R/03_dedi.R")

## Stage 4: MANOVA assumption diagnostics
source("R/04_assumptions.R")

## Stage 5: factorial MANOVA + Games–Howell post hoc + interaction plot
source("R/05_manova.R")

## Stage 6: sensitivity analyses
source("R/06_sensitivity.R")
```

### Dependencies

R ≥ 4.3 with the following CRAN packages:

```r
install.packages(c(
  "readxl", "dplyr", "tidyr", "ggplot2",
  "psych",       # KMO, Bartlett, skewness
  "car",         # Manova, leveneTest, Anova
  "MVN",         # Mardia tests
  "rstatix",     # games_howell_test
  "heplots",     # boxM, etasq
  "knitr", "scales"
))
```

The committed outputs were last regenerated under R 4.5.2 with MVN 6.3 (MVN ≥ 6.0 is
required — the 5.x API used different argument and result names and stage 04 will fail on it),
car 3.1.5, psych 2.6.1, heplots 1.8.1, rstatix 0.7.3.

To run the whole pipeline in one command from the repo root:

```bash
Rscript R/run_all.R          # all six stages
```

Equivalently, stage by stage:

```bash
for s in 01_descriptive 02_pca 03_dedi 04_assumptions 05_manova 06_sensitivity; do
  Rscript R/$s.R
done
```

In an R session (e.g. RStudio), `source("R/run_all.R")` from the repo root does the same.
The stage scripts resolve `R/00_setup.R` relative to the repository root, so run them from
there — `cd R && Rscript 02_pca.R` fails with `cannot open file 'R/00_setup.R'`.

To re-typeset the report, `cd report/` and run `pdflatex final_report.tex` twice (any
TeX Live installation providing `amsmath`, `booktabs`, `tabularx`, `multirow`,
`ragged2e`, `subcaption`, `natbib`, and `hyperref` will do; figures are pulled from
`outputs/figures/`).

---

## Method at a glance

The 22 third-level indicators are nested under three first-level dimensions (digital
infrastructure, digital industry, digital environment), following the framework of
He et al.\ (2023). Indicators with |skew| > 1.5 are log-transformed before *z*-score
standardization. Four PCs are retained by the conservative
*k* = max(*k*\_Kaiser, *k*\_80%) rule and Varimax-rotated for interpretability;
the four PCs are labelled **Industry/Innovation Scale**, **Per-capita Penetration**,
**Infrastructure Connectivity**, and **Enterprise Digitalization**.

A composite DEDI index is constructed as the variance-share-weighted, sign-aligned sum
of the retained scores, rescaled to [0, 100], purely for descriptive ranking.
**Inferential** analysis operates directly on the four orthogonal PC scores — the
multicollinearity assumption of MANOVA is therefore automatically satisfied.

The factorial MANOVA fits

$$
\mathbf{Y}_{ij\ell} = \boldsymbol\mu + \boldsymbol\alpha_i + \boldsymbol\beta_j +
(\boldsymbol{\alpha\beta})_{ij} + \boldsymbol\varepsilon_{ij\ell}
$$

with *i* ∈ {East, Central, West, Northeast}, *j* ∈ {Early 2013–17, Late 2018–22},
and *ℓ* indexing province-years within each cell. Because Box's *M* rejects covariance
homogeneity, **Pillai's trace** is reported as the primary multivariate criterion;
Wilks' Λ, Hotelling–Lawley *T*², and Roy's largest root are reported for transparency.
Univariate Type-II ANOVAs decompose the multivariate effect onto each PC, and pairwise
region contrasts use the **Games–Howell** procedure (which does not assume equal
variances or equal cell sizes).

---

## Data sources

- *China Statistical Yearbook* (National Bureau of Statistics)
- *Statistical Yearbook of China's Tertiary Industry*
- *China Science and Technology Statistical Yearbook*
- *Digital Inclusive Finance Index* (Digital Finance Research Center, Peking University)

All for fiscal years 2013–2022; 31 mainland provinces (HK / Macao / Taiwan excluded).
Missing cells were filled by linear interpolation in the time dimension; the imputation
footprint is small (only `x5` IPv4 addresses at 20.3% of cells, `x13` mobile internet
users at 8.4%, and `x21` R&D institutions at 0.3% required any interpolation).

---

## License and data

Code in this repository is released under the MIT License (see `LICENSE`).

The underlying indicators are public statistical releases of the Chinese government;
the Digital Inclusive Finance Index is produced by the Digital Finance Research
Center, Peking University. They are redistributed here only so that the analysis can
be reproduced, and remain subject to the terms of their original publishers.
