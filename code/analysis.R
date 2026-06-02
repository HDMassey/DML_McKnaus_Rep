# analysis.R
# Loads temp/clean_data.RData, runs DML, recreates Table 4, and writes outputs.

suppressPackageStartupMessages({
  library(causalDML)
  library(grf)
  library(lmtest)
  library(sandwich)
})

if (!file.exists("temp/clean_data.RData")) {
  stop("temp/clean_data.RData not found. Run code/preprocess.R first.")
}

if (!dir.exists("output/figures")) dir.create("output/figures", recursive = TRUE)
if (!dir.exists("output/tables")) dir.create("output/tables", recursive = TRUE)
if (!dir.exists("temp")) dir.create("temp", recursive = TRUE)

load("temp/clean_data.RData")

# Main DML run. The RDS cache avoids rerunning the expensive forest if inputs have not changed.
dml_path <- "temp/DML_forest_500.rds"

if (file.exists(dml_path)) {
  DML <- readRDS(dml_path)
} else {
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

  saveRDS(DML, dml_path)
}

ate_cols <- c(
  "job search - no program",
  "vocational - no program",
  "computer - no program",
  "language - no program"
)

if (!all(ate_cols %in% colnames(DML$ATE$delta))) {
  cat("Available ATE columns:\n")
  print(colnames(DML$ATE$delta))
  stop("ATE column names do not match expected treatment comparisons.")
}

delta <- DML$ATE$delta[, ate_cols, drop = FALSE]
colnames(delta) <- c("Job search", "Vocational", "Computer", "Language")

female <- as.numeric(x[, "female"])
foreigner <- as.numeric(x[, "foreigner_b"] + x[, "foreigner_c"] > 0)
emp_raw <- x[, "employability"]
emp_levels <- sort(unique(emp_raw))
emp_medium <- as.numeric(emp_raw == emp_levels[2])
emp_high <- as.numeric(emp_raw == emp_levels[3])

stars <- function(p) {
  ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
}

fmt_coef <- function(b, p) paste0(sprintf("%.2f", b), stars(p))
fmt_se <- function(se) paste0("(", sprintf("%.2f", se), ")")

fit_gate <- function(yvar, dat, rhs, coef_names) {
  dat$yvar <- yvar
  mod <- lm(as.formula(paste("yvar ~", rhs)), data = dat)
  ct <- coeftest(mod, vcov = vcovHC(mod, type = "HC1"))

  out <- list()
  for (v in coef_names) {
    out[[paste0(v, "_coef")]] <- fmt_coef(ct[v, "Estimate"], ct[v, "Pr(>|t|)"])
    out[[paste0(v, "_se")]] <- fmt_se(ct[v, "Std. Error"])
  }
  out
}

robust_f_test <- function(yvar) {
  dat <- data.frame(yvar = yvar, emp_medium = emp_medium, emp_high = emp_high)
  mod <- lm(yvar ~ emp_medium + emp_high, data = dat)
  V <- vcovHC(mod, type = "HC1")

  b <- coef(mod)[c("emp_medium", "emp_high")]
  V_sub <- V[c("emp_medium", "emp_high"), c("emp_medium", "emp_high")]

  q <- length(b)
  F_stat <- as.numeric(t(b) %*% solve(V_sub) %*% b / q)
  p_val <- pf(F_stat, df1 = q, df2 = mod$df.residual, lower.tail = FALSE)

  paste0(sprintf("%.2f", F_stat), stars(p_val))
}

row_names <- c(
  "Panel A: Female",
  "Constant", "",
  "Female", "",
  "Panel B: Foreigner",
  "Constant", "",
  "Foreigner", "",
  "Panel C: Employability",
  "Constant", "",
  "Medium employability", "",
  "High employability", "",
  "F-statistic"
)

table4 <- data.frame(
  Row = row_names,
  `Job search` = "",
  Vocational = "",
  Computer = "",
  Language = "",
  check.names = FALSE
)

for (j in seq_len(ncol(delta))) {
  yj <- delta[, j]
  cj <- colnames(delta)[j]

  a <- fit_gate(
    yvar = yj,
    dat = data.frame(female = female),
    rhs = "female",
    coef_names = c("(Intercept)", "female")
  )
  table4[2, cj] <- a[["(Intercept)_coef"]]
  table4[3, cj] <- a[["(Intercept)_se"]]
  table4[4, cj] <- a[["female_coef"]]
  table4[5, cj] <- a[["female_se"]]

  b <- fit_gate(
    yvar = yj,
    dat = data.frame(foreigner = foreigner),
    rhs = "foreigner",
    coef_names = c("(Intercept)", "foreigner")
  )
  table4[7, cj] <- b[["(Intercept)_coef"]]
  table4[8, cj] <- b[["(Intercept)_se"]]
  table4[9, cj] <- b[["foreigner_coef"]]
  table4[10, cj] <- b[["foreigner_se"]]

  c <- fit_gate(
    yvar = yj,
    dat = data.frame(emp_medium = emp_medium, emp_high = emp_high),
    rhs = "emp_medium + emp_high",
    coef_names = c("(Intercept)", "emp_medium", "emp_high")
  )
  table4[12, cj] <- c[["(Intercept)_coef"]]
  table4[13, cj] <- c[["(Intercept)_se"]]
  table4[14, cj] <- c[["emp_medium_coef"]]
  table4[15, cj] <- c[["emp_medium_se"]]
  table4[16, cj] <- c[["emp_high_coef"]]
  table4[17, cj] <- c[["emp_high_se"]]
  table4[18, cj] <- robust_f_test(yj)
}

# Save machine-readable table.
write.csv(table4, "output/tables/table4_replication.csv", row.names = FALSE)

# Create LaTeX table fragment consumed by paper/paper.tex.
esc <- function(z) {
  z <- gsub("\\*", "\\\\sym{*}", z)
  z
}

latex <- paste0(
"\\begin{table}[h]\n",
"\\centering\n",
"\\caption{Replication of Table 4: Group average treatment effects}\n",
"\\small\n",
"\\begin{tabular}{lcccc}\n",
"\\toprule\n",
" & Job search & Vocational & Computer & Language \\\\\n",
" & (1) & (2) & (3) & (4) \\\\\n",
"\\midrule\n",
"\\multicolumn{5}{l}{\\textit{Panel A: Female}} \\\\\n",
"Constant & ", esc(table4[2,2]), " & ", esc(table4[2,3]), " & ", esc(table4[2,4]), " & ", esc(table4[2,5]), " \\\\\n",
" & ", esc(table4[3,2]), " & ", esc(table4[3,3]), " & ", esc(table4[3,4]), " & ", esc(table4[3,5]), " \\\\\n",
"Female & ", esc(table4[4,2]), " & ", esc(table4[4,3]), " & ", esc(table4[4,4]), " & ", esc(table4[4,5]), " \\\\\n",
" & ", esc(table4[5,2]), " & ", esc(table4[5,3]), " & ", esc(table4[5,4]), " & ", esc(table4[5,5]), " \\\\\n",
"\\addlinespace\n",
"\\multicolumn{5}{l}{\\textit{Panel B: Foreigner}} \\\\\n",
"Constant & ", esc(table4[7,2]), " & ", esc(table4[7,3]), " & ", esc(table4[7,4]), " & ", esc(table4[7,5]), " \\\\\n",
" & ", esc(table4[8,2]), " & ", esc(table4[8,3]), " & ", esc(table4[8,4]), " & ", esc(table4[8,5]), " \\\\\n",
"Foreigner & ", esc(table4[9,2]), " & ", esc(table4[9,3]), " & ", esc(table4[9,4]), " & ", esc(table4[9,5]), " \\\\\n",
" & ", esc(table4[10,2]), " & ", esc(table4[10,3]), " & ", esc(table4[10,4]), " & ", esc(table4[10,5]), " \\\\\n",
"\\addlinespace\n",
"\\multicolumn{5}{l}{\\textit{Panel C: Employability}} \\\\\n",
"Constant & ", esc(table4[12,2]), " & ", esc(table4[12,3]), " & ", esc(table4[12,4]), " & ", esc(table4[12,5]), " \\\\\n",
" & ", esc(table4[13,2]), " & ", esc(table4[13,3]), " & ", esc(table4[13,4]), " & ", esc(table4[13,5]), " \\\\\n",
"Medium employability & ", esc(table4[14,2]), " & ", esc(table4[14,3]), " & ", esc(table4[14,4]), " & ", esc(table4[14,5]), " \\\\\n",
" & ", esc(table4[15,2]), " & ", esc(table4[15,3]), " & ", esc(table4[15,4]), " & ", esc(table4[15,5]), " \\\\\n",
"High employability & ", esc(table4[16,2]), " & ", esc(table4[16,3]), " & ", esc(table4[16,4]), " & ", esc(table4[16,5]), " \\\\\n",
" & ", esc(table4[17,2]), " & ", esc(table4[17,3]), " & ", esc(table4[17,4]), " & ", esc(table4[17,5]), " \\\\\n",
"F-statistic & ", esc(table4[18,2]), " & ", esc(table4[18,3]), " & ", esc(table4[18,4]), " & ", esc(table4[18,5]), " \\\\\n",
"\\bottomrule\n",
"\\multicolumn{5}{p{0.90\\textwidth}}{\\footnotesize Notes: OLS coefficients and heteroscedasticity robust standard errors in parentheses. Regressions use the DML pseudo-outcome. \\sym{*} p$<$0.1; \\sym{**} p$<$0.05; \\sym{***} p$<$0.01.} \\\\\n",
"\\end{tabular}\n",
"\\label{tab:table4}\n",
"\\end{table}\n"
)

writeLines(latex, "output/tables/table4_replication.tex")

# Create PNG table, useful for quick viewing and robust inclusion in reports.
table_png <- "output/figures/table4_replication_output.png"
png(filename = table_png, width = 1800, height = 1400, res = 200)
par(mar = c(1, 1, 3, 1))
plot.new()
plot.window(xlim = c(0, 1), ylim = c(0, 1))
text(0.5, 0.98, "Group average treatment effects", font = 2, cex = 1.2)
x_pos <- c(0.08, 0.43, 0.60, 0.76, 0.91)
y_start <- 0.92
row_step <- 0.043
headers <- c("", "Job search\n(1)", "Vocational\n(2)", "Computer\n(3)", "Language\n(4)")
text(x_pos[1], y_start, headers[1], font = 2, adj = 0, cex = 0.75)
for (k in 2:5) text(x_pos[k], y_start, headers[k], font = 2, cex = 0.75)
segments(0.05, y_start - 0.025, 0.95, y_start - 0.025, lwd = 1)
for (i in seq_len(nrow(table4))) {
  y_i <- y_start - 0.04 - (i - 1) * row_step
  if (i %in% c(1, 6, 11)) {
    text(x_pos[1], y_i, table4[i, 1], font = 3, adj = 0, cex = 0.75)
  } else {
    text(x_pos[1], y_i, table4[i, 1], adj = 0, cex = 0.72)
    for (k in 2:5) text(x_pos[k], y_i, table4[i, k], cex = 0.72)
  }
}
segments(0.05, 0.105, 0.95, 0.105, lwd = 1)
note_text <- paste(
  "Notes: OLS coefficients and heteroscedasticity robust standard errors in parentheses.",
  "Regressions use the DML pseudo-outcome. * p < 0.1; ** p < 0.05; *** p < 0.01."
)
text(0.05, 0.065, note_text, adj = 0, cex = 0.58)
dev.off()


# Save summary statistics table consumed by the paper.
summary_latex <- paste0(
"\\begin{table}[h]\n",
"\\centering\n",
"\\caption{Cleaned replication sample summary}\n",
"\\begin{tabular}{lc}\n",
"\\toprule\n",
"Statistic & Value \\\\\n",
"\\midrule\n",
"Observations & ", format(N_obs, big.mark = ",", scientific = FALSE), " \\\\\n",
"Covariates & ", N_covariates, " \\\\\n",
"Mean outcome & ", sprintf("%.3f", mean_Y), " \\\\\n",
"Standard deviation of outcome & ", sprintf("%.3f", std_Y), " \\\\\n",
"\\bottomrule\n",
"\\end{tabular}\n",
"\\label{tab:summary}\n",
"\\end{table}\n"
)
writeLines(summary_latex, "output/tables/summary_stats.tex")

cat("Replication Result\n")
cat("==================\n")
cat("Target: Knaus Table 4, group average treatment effects.\n")
cat("Paper reports final sample size: 62,497 observations.\n")
cat("This replication sample size:", N_obs, "observations.\n")
cat("Paper reports covariates: 45.\n")
cat("This replication covariates:", N_covariates, ".\n", sep = "")
cat("Output figure:", table_png, "\n")
cat("Output LaTeX table: output/tables/table4_replication.tex\n")
