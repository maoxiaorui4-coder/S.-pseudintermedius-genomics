# Input data

Place the following Excel workbooks in this directory before running `run_all.R`:

| File | Grouping variable |
| --- | --- |
| `country.xlsx` | Country |
| `host.xlsx` | Source or host |
| `ST.xlsx` | Sequence type |
| `time.xlsx` | Collection time |

For every workbook, the first worksheet is read by default. The first column must
contain group labels, and the second column must contain numeric antimicrobial-
resistance gene counts. Additional columns are ignored. Rows with an empty group
or a missing/non-numeric gene count are excluded with a warning.

The source data are not included in this code-only archive. If data are deposited
separately, update this file and the paths in `config/analyses.csv` with the data
repository accession or DOI before submission.

