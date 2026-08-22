## ============================================================
## run_all.R — run the full pipeline from the repository root
## ============================================================
for (s in sprintf("R/%s.R", c("01_descriptive", "02_pca", "03_dedi",
                              "04_assumptions", "05_manova", "06_sensitivity"))) {
  message("== ", s)
  source(s)
}
