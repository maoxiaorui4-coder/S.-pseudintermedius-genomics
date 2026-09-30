#!/usr/bin/env Rscript

check_package <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(
      "Missing required package: ", package,
      ". Run `Rscript install_dependencies.R` first.",
      call. = FALSE
    )
  }
}

parse_arguments <- function(arguments) {
  result <- list()
  for (argument in arguments) {
    if (!grepl("^--[^=]+=.+$", argument)) {
      stop("Arguments must use the form --name=value: ", argument, call. = FALSE)
    }
    parts <- strsplit(sub("^--", "", argument), "=", fixed = TRUE)[[1L]]
    result[[parts[[1L]]]] <- paste(parts[-1L], collapse = "=")
  }
  result
}

parse_boolean <- function(value) {
  normalized <- tolower(value)
  if (!normalized %in% c("true", "false")) {
    stop("Boolean values must be `true` or `false`.", call. = FALSE)
  }
  identical(normalized, "true")
}

check_package("readxl")
check_package("writexl")

args <- parse_arguments(commandArgs(trailingOnly = TRUE))
required_args <- c("input", "output", "n")
missing_args <- required_args[!required_args %in% names(args)]
if (length(missing_args) > 0L) {
  stop(
    "Missing argument(s): ", paste(paste0("--", missing_args), collapse = ", "),
    "\nExample: Rscript scripts/sample_excel_rows.R ",
    "--input=data/dog_4489.xlsx --output=results/dog_sample_491.xlsx --n=491",
    call. = FALSE
  )
}

input_file <- args$input
output_file <- args$output
n_sample <- as.integer(args$n)
seed <- if (is.null(args$seed)) 12345L else as.integer(args$seed)
sheet <- if (is.null(args$sheet)) 1 else args$sheet
col_names <- if (is.null(args[["col-names"]])) {
  FALSE
} else {
  parse_boolean(args[["col-names"]])
}

if (!file.exists(input_file)) {
  stop("Input file does not exist: ", input_file, call. = FALSE)
}
if (is.na(n_sample) || n_sample <= 0L) {
  stop("`n` must be a positive integer.", call. = FALSE)
}
if (is.na(seed)) {
  stop("`seed` must be an integer.", call. = FALSE)
}

data <- readxl::read_excel(input_file, sheet = sheet, col_names = col_names)
if (n_sample > nrow(data)) {
  stop(
    "Requested ", n_sample, " rows, but the input contains only ", nrow(data), ".",
    call. = FALSE
  )
}

set.seed(seed)
sampled_indices <- sample(seq_len(nrow(data)), size = n_sample, replace = FALSE)
sampled_data <- data[sampled_indices, , drop = FALSE]

output_parent <- dirname(output_file)
dir.create(output_parent, recursive = TRUE, showWarnings = FALSE)
writexl::write_xlsx(sampled_data, output_file, col_names = col_names)

metadata <- data.frame(
  input_file = normalizePath(input_file, winslash = "/"),
  input_rows = nrow(data),
  sampled_rows = n_sample,
  seed = seed,
  column_names_present = col_names,
  stringsAsFactors = FALSE
)
utils::write.csv(
  metadata,
  paste0(tools::file_path_sans_ext(output_file), "_metadata.csv"),
  row.names = FALSE
)

message("Sampled ", n_sample, " of ", nrow(data), " rows with seed ", seed, ".")
message("Output written to: ", normalizePath(output_file, winslash = "/"))

