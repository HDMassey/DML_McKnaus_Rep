# Input data instructions

The raw Swiss Active Labor Market Policy Evaluation dataset is restricted-use data and is not included in this public repository.

To reproduce the project from scratch:

1. Request access to the Swiss ALMP dataset through SwissUbase/FORSbase.
2. Download the archive `swissubase_1203_1_0.zip` or the extracted CSV file.
3. Place either of the following files in this `input/` folder:
   - `input/1203_ALMP_Data_E_v1.0.0.csv`, or
   - `input/swissubase_1203_1_0.zip`
4. From the repository root, run `make`.

The scripts never modify files inside `input/`. All cleaned data are written to `temp/`, and final tables/figures are written to `output/`.
