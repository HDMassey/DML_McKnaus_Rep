# Replication of Knaus (2022) Table 4

This repository replicates Table 4, "Group average treatment effects," from Michael C. Knaus (2022), "Double machine learning-based programme evaluation under unconfoundedness," published in *The Econometrics Journal*.

The project uses R to clean the Swiss Active Labor Market Policy data, estimate double machine learning scores, and recreate the group average treatment effect table. The paper is written in LaTeX and imports the generated table and figure from the `output/` directory.

## Original paper

Knaus, Michael C. 2022. "Double machine learning-based programme evaluation under unconfoundedness." *The Econometrics Journal* 25(3): 602-627. DOI: 10.1093/ectj/utac015.

## Result replicated

I replicate Table 4 from the paper. The table reports group average treatment effects for four active labor market programs - job search, vocational training, computer training, and language training - relative to no program. The subgroup dimensions are female status, foreigner status, and employability.

## Repository structure

```text
mcknaus_replication_final_project/
|-- input/                 # Raw data instructions; restricted raw data not tracked
|-- code/                  # R scripts for preprocessing and analysis
|-- output/                # Tracked generated tables and figures
|   |-- figures/
|   +-- tables/
|-- temp/                  # Regenerable intermediate files; gitignored
|-- paper/                 # LaTeX paper source and compiled paper target
|-- Makefile               # End-to-end pipeline
|-- run_all.sh             # Convenience wrapper around make
|-- proposal.md            # Original project proposal
+-- README.md
```

## Data

The Swiss ALMP data are restricted-use data from SwissUbase/FORSbase and are not included in this public repository.

To reproduce the project from scratch, place one of the following in `input/`:

```text
input/1203_ALMP_Data_E_v1.0.0.csv
```

or

```text
input/swissubase_1203_1_0.zip
```

See `input/README.md` for details.

## Prerequisites

- R 4.4 or later recommended
- LaTeX distribution with `pdflatex` and `bibtex`
- GNU Make
- R packages:
  - `dplyr`
  - `grf`
  - `causalDML`
  - `lmtest`
  - `sandwich`

The `causalDML` package can be installed from GitHub if needed:

```r
# install.packages("devtools")
devtools::install_github("MCKnaus/causalDML", upgrade = "never")
```

## How to reproduce

Clone the repository, place the restricted data in `input/`, and run:

```bash
make
```

The full first run may take a long time because the DML step uses generalized random forests. The DML object is cached in `temp/DML_forest_500.rds` so reruns are faster unless `make clean` is used.

On Windows without GNU Make, the equivalent manual commands are:

```powershell
Rscript code/preprocess.R
Rscript code/analysis.R
cd paper
pdflatex paper.tex
bibtex paper
pdflatex paper.tex
pdflatex paper.tex
cd ..
```

If `Rscript` is not on your path, use the full path to `Rscript.exe`.

## Outputs

The main outputs are:

```text
output/tables/summary_stats.tex
output/tables/table4_replication.tex
output/tables/table4_replication.csv
output/figures/table4_replication_output.png
paper/paper.pdf
```

## Results summary

The replication closely matches the structure, signs, and broad magnitudes of Knaus Table 4. The replicated sample contains 62,465 observations and 45 covariates, while the paper reports 62,497 observations and 45 covariates. The remaining differences likely come from the pseudo-start assignment for the no-program group and from using fixed 500-tree generalized random forests rather than the fully tuned random forest specification in the paper.

## Notes on reproducibility

- `input/` is read-only.
- `temp/` is regenerable and gitignored.
- `output/` is tracked so readers can inspect the generated results even without rerunning the DML model.
- All table and figure content in `paper/paper.tex` is imported from `output/`.

## Exact DML RDS cache script

The main pipeline creates `temp/DML_forest_500.rds` inside `code/analysis.R` if that cache file does not already exist. For clarity, the exact standalone code that creates the RDS file is also provided in:

```text
code/run_dml_save_rds.R
```

To rerun only the DML step after preprocessing:

```bash
Rscript code/preprocess.R
Rscript code/run_dml_save_rds.R
```

Then run:

```bash
Rscript code/analysis.R
```

The `analysis.R` script will reuse `temp/DML_forest_500.rds` and produce the final output tables and figures.
