# Reproducible R analysis code

This directory contains the R code used to compare antimicrobial-resistance gene
counts among country, source/host, sequence-type, and collection-time groups. It
also contains a separate reproducible row-sampling utility.

## Directory structure

```text
.
|-- R/
|   `-- group_comparison.R          # Validated analysis functions
|-- config/
|   `-- analyses.csv                # Input and analysis mapping
|-- data/
|   `-- README.md                   # Required input-file specification
|-- scripts/
|   |-- run_group_comparison.R      # Run one group comparison
|   `-- sample_excel_rows.R         # Reproducible random sampling
|-- install_dependencies.R
|-- run_all.R                       # Run all configured comparisons
`-- README.md
```

## Software requirements

- R (version 4.1 or later recommended)
- R packages: `readxl`, `FSA`, and `writexl`

Packages are never installed automatically during an analysis. Install missing
dependencies explicitly from the project directory:

```sh
Rscript install_dependencies.R
```

## Input data

See `data/README.md`. For each comparison, the first Excel column contains the
group label and the second contains the numeric gene count. Input locations and
analysis names are defined in `config/analyses.csv`; paths are relative to this
directory, so no user-specific absolute path is required.

## Run all group comparisons

From this directory, run:

```sh
Rscript run_all.R
```

Each analysis is written to its own subdirectory under `results/`. The following
files are created:

- `group_summary.csv`: sample size, median, and first/third quartiles by group.
- `kruskal_wallis.csv`: Kruskal-Wallis statistic, degrees of freedom, and P value.
- `dunn_all_comparisons.csv`: all Dunn pairwise tests with raw and adjusted P values.
- `dunn_significant_comparisons.csv`: comparisons with adjusted P < 0.05.
- `analysis_report.txt`: concise human-readable analysis summary.
- `session_info.txt`: R, platform, and package-version information.

Dunn-test P values are adjusted using the Bonferroni method. Statistical decisions
use the unrounded numeric values at alpha = 0.05. CSV files retain the underlying
numeric precision rather than presentation-only rounded values.

## Run one group comparison

```sh
Rscript scripts/run_group_comparison.R --input=data/country.xlsx --output=results/country --name=country
```

Optional arguments are `--sheet=1`, `--alpha=0.05`, and
`--adjustment=bonferroni`. Named Excel worksheets can also be supplied to
`--sheet`.

## Reproduce the row-sampling step

The original sampling analysis selected 491 rows without replacement from a
headerless workbook using random seed 12345. Reproduce it with:

```sh
Rscript scripts/sample_excel_rows.R --input=data/dog_4489.xlsx --output=results/dog_sample_491.xlsx --n=491 --seed=12345 --col-names=false
```

The script validates the requested sample size and writes a companion metadata
CSV recording the input row count, sample size, random seed, and header setting.

## Reproducibility notes

- All paths are relative or supplied at the command line.
- Analyses fail with an informative message when inputs or dependencies are absent.
- Invalid/missing observations are reported and removed before testing.
- A complete `sessionInfo()` record is saved for each group comparison.
- Generated results and input workbooks are excluded by `.gitignore`; revise this
  choice if the journal requires data and results in the same repository.

