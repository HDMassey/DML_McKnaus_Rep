.PHONY: all clean

all: paper/paper.pdf

# Preprocessing: raw restricted data to analysis-ready RData
temp/clean_data.RData: input/1203_ALMP_Data_E_v1.0.0.csv code/preprocess.R
	Rscript code/preprocess.R

# Analysis: DML estimation and output artifacts consumed by the paper
output/tables/table4_replication.tex output/tables/summary_stats.tex output/figures/table4_replication_output.png: temp/clean_data.RData code/analysis.R
	Rscript code/analysis.R

# Paper compilation
paper/paper.pdf: paper/paper.tex output/tables/table4_replication.tex output/tables/summary_stats.tex output/figures/table4_replication_output.png
	cd paper && pdflatex paper.tex && pdflatex paper.tex

clean:
	rm -f temp/*.RData temp/*.rds temp/*.RData output/tables/*.tex output/tables/*.csv output/figures/*.png \
		paper/paper.pdf paper/*.aux paper/*.log paper/*.out paper/*.toc paper/*.bbl paper/*.blg

# Optional target: explicitly create only the DML RDS cache.
temp/DML_forest_500.rds: temp/clean_data.RData code/run_dml_save_rds.R
	Rscript code/run_dml_save_rds.R
