#!/usr/bin/env Rscript

get_script_dir <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) != 1L) {
    stop("This script must be run with Rscript.", call. = FALSE)
  }
  dirname(normalizePath(sub("^--file=", "", file_arg), winslash = "/"))
}

project_dir <- get_script_dir()
source(file.path(project_dir, "R", "group_comparison.R"))

config_file <- file.path(project_dir, "config", "analyses.csv")
config <- utils::read.csv(config_file, stringsAsFactors = FALSE, check.names = FALSE)
required_columns <- c("analysis_name", "input_file", "group_description")
if (!all(required_columns %in% names(config))) {
  stop(
    "Configuration file must contain: ", paste(required_columns, collapse = ", "),
    call. = FALSE
  )
}

statuses <- lapply(seq_len(nrow(config)), function(index) {
  analysis_name <- config$analysis_name[[index]]
  input_file <- file.path(project_dir, config$input_file[[index]])
  output_dir <- file.path(project_dir, "results", analysis_name)

  tryCatch(
    {
      run_group_comparison(
        input_file = input_file,
        output_dir = output_dir,
        analysis_name = analysis_name,
        adjustment_method = "bonferroni"
      )
      data.frame(analysis = analysis_name, status = "completed", message = "")
    },
    error = function(error) {
      message("Failed analysis `", analysis_name, "`: ", conditionMessage(error))
      data.frame(
        analysis = analysis_name,
        status = "failed",
        message = conditionMessage(error),
        stringsAsFactors = FALSE
      )
    }
  )
})

status_table <- do.call(rbind, statuses)
results_dir <- file.path(project_dir, "results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
utils::write.csv(
  status_table,
  file.path(results_dir, "run_status.csv"),
  row.names = FALSE
)

if (any(status_table$status == "failed")) {
  stop("One or more analyses failed. See results/run_status.csv.", call. = FALSE)
}

message("All configured analyses completed successfully.")

