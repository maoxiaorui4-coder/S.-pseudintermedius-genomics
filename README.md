# R scripts for *Staphylococcus pseudintermedius* genomic analyses

## Contents

- [Overview](#overview)
- [Repository contents](#repository-contents)
- [System requirements](#system-requirements)
- [Installation guide](#installation-guide)
- [Demo](#demo)
- [Results](#results)
- [License](#license)
- [Citation](#citation)

## Overview

This repository contains the R scripts and input data used for the statistical comparisons shown in Fig. 3C–F and for random sampling of dog-source isolates used in the phylogenetic analysis shown in Fig. 5 and Supplementary Table 6.

## Repository contents

```text
.
|-- R/
|   |-- dunn_country.R
|   |-- dunn_sequence_type.R
|   |-- dunn_source.R
|   |-- dunn_time.R
|   `-- sample_dog_isolates.R
|-- data/
|   |-- country.xlsx
|   |-- dog_source_isolates_n4489.xlsx
|   |-- source.xlsx
|   |-- ST.xlsx
|   `-- time.xlsx
|-- .gitignore
|-- LICENSE
`-- README.md
```

The first two columns of each input file for the Dunn analyses contain the group label and resistance-gene count, respectively. `dog_source_isolates_n4489.xlsx` contains 4,489 dog-source isolates without a header row.

## System requirements

The scripts were tested on Windows 11 with:

- R 4.2.1
- `readxl` 1.5.0
- `FSA` 0.9.6
- `writexl` 1.5.4

No non-standard hardware is required. The scripts are intended to run on Windows, macOS, or Linux.

## Installation guide

Install the required packages from CRAN:

```r
install.packages(c("readxl", "FSA", "writexl"))
```

Installing the required packages took approximately 40 seconds on the tested Windows 11 desktop, with R already installed. Internet access to CRAN is required.

## Demo

Run the following commands from the repository root:

```sh
Rscript R/dunn_time.R
Rscript R/dunn_country.R
Rscript R/dunn_sequence_type.R
Rscript R/dunn_source.R
Rscript R/sample_dog_isolates.R
```

Each script uses the corresponding file in `data/` by default. A different input file can be supplied as the first command-line argument. The sampling script also accepts the output path, sample size, and random seed:

```sh
Rscript R/sample_dog_isolates.R data/dog_source_isolates_n4489.xlsx results/dog_source_sample_n491.xlsx 491 12345
```

Typical runtimes on the tested Windows 11 desktop were:

| Script | Runtime (seconds) |
| --- | ---: |
| `dunn_time.R` | 0.36 |
| `dunn_country.R` | 0.34 |
| `dunn_sequence_type.R` | 0.27 |
| `dunn_source.R` | 0.37 |
| `sample_dog_isolates.R` | 0.82 |

The complete demo took approximately 4 seconds, including R startup time.

## Results

- `dunn_time.R`: Fig. 3C
- `dunn_country.R`: Fig. 3D
- `dunn_sequence_type.R`: Fig. 3E
- `dunn_source.R`: Fig. 3F
- `sample_dog_isolates.R`: dog-source isolate sampling for the phylogenetic analysis in Fig. 5 and Supplementary Table 6

The four comparison scripts print group-level descriptive statistics, the Kruskal–Wallis test, and Dunn pairwise comparisons with Bonferroni-adjusted P values. The sampling script uses a default random seed of 12345 and writes 491 sampled rows to `results/dog_source_sample_n491.xlsx`.

Expected key output is:

| Script | Expected result |
| --- | --- |
| `dunn_time.R` | Kruskal–Wallis H = 54.404090, df = 3, P = 9.2009201237e-12 |
| `dunn_country.R` | Kruskal–Wallis H = 357.930890, df = 4, P = 3.4000388818e-76 |
| `dunn_sequence_type.R` | Kruskal–Wallis H = 147.277867, df = 4, P = 7.7979957491e-31 |
| `dunn_source.R` | Kruskal–Wallis H = 109.449110, df = 4, P = 9.5383716851e-23 |
| `sample_dog_isolates.R` | 491 rows sampled from 4,489 rows using random seed 12345 |

## License

The R scripts are licensed under the GNU General Public License v3.0. See `LICENSE`.

## Citation

Please cite the associated manuscript and the archived repository release.
