#!/usr/bin/env Rscript

get_script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) != 1L) {
    stop("This script must be run with Rscript.", call. = FALSE)
  }
  dirname(normalizePath(sub("^--file=", "", file_arg), winslash = "/"))
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

script_dir <- get_script_dir()
project_dir <- dirname(script_dir)
source(file.path(project_dir, "R", "group_comparison.R"))

args <- parse_arguments(commandArgs(trailingOnly = TRUE))
required_args <- c("input", "output", "name")
missing_args <- required_args[!required_args %in% names(args)]

if (length(missing_args) > 0L) {
  stop(
    "Missing argument(s): ", paste(paste0("--", missing_args), collapse = ", "),
    "\nExample: Rscript scripts/run_group_comparison.R ",
    "--input=data/country.xlsx --output=results/country --name=country",
    call. = FALSE
  )
}

run_group_comparison(
  input_file = args$input,
  output_dir = args$output,
  analysis_name = args$name,
  sheet = if (is.null(args$sheet)) 1 else args$sheet,
  alpha = if (is.null(args$alpha)) 0.05 else as.numeric(args$alpha),
  adjustment_method = if (is.null(args$adjustment)) "bonferroni" else args$adjustment
)

