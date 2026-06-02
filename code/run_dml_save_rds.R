# run_dml_save_rds.R
# Standalone script showing the exact code used to create temp/DML_forest_500.rds.
# Run code/preprocess.R first so temp/clean_data.RData exists.

suppressPackageStartupMessages({
  library(causalDML)
  library(grf)
})

if (!file.exists("temp/clean_data.RData")) {
  stop("temp/clean_data.RData not found. Run code/preprocess.R first.")
}

if (!dir.exists("temp")) dir.create("temp", recursive = TRUE)

load("temp/clean_data.RData")

set.seed(1234)

forest_500 <- create_method(
  "forest_grf",
  args = list(
    num.trees = 500,
    min.node.size = 10,
    seed = 1234
  )
)

DML <- DML_aipw(
  y = y,
  w = w,
  x = x,
  ml_w = list(forest_500),
  ml_y = list(forest_500),
  quiet = TRUE
)

saveRDS(DML, "temp/DML_forest_500.rds")

cat("DML object saved to temp/DML_forest_500.rds\n")
cat("Available ATE columns:\n")
print(colnames(DML$ATE$delta))
