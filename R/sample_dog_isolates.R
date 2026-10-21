required_packages <- c("readxl", "writexl")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0L) {
  stop(
    "Install required packages before running this script: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

args <- commandArgs(trailingOnly = TRUE)
input_file <- if (length(args) >= 1L) {
  args[[1L]]
} else {
  file.path("data", "dog_source_isolates_n4489.xlsx")
}
output_file <- if (length(args) >= 2L) {
  args[[2L]]
} else {
  file.path("results", "dog_source_sample_n491.xlsx")
}
sample_size <- if (length(args) >= 3L) as.integer(args[[3L]]) else 491L
random_seed <- if (length(args) >= 4L) as.integer(args[[4L]]) else 12345L

if (is.na(sample_size) || sample_size < 1L) {
  stop("Sample size must be a positive integer.", call. = FALSE)
}
if (is.na(random_seed)) {
  stop("Random seed must be an integer.", call. = FALSE)
}

data <- readxl::read_excel(input_file, col_names = FALSE)
if (sample_size > nrow(data)) {
  stop("Sample size cannot exceed the number of input rows.", call. = FALSE)
}

set.seed(random_seed)
sampled_rows <- sample(seq_len(nrow(data)), size = sample_size, replace = FALSE)
sampled_data <- data[sampled_rows, , drop = FALSE]

output_directory <- dirname(output_file)
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}
writexl::write_xlsx(sampled_data, output_file, col_names = FALSE)

cat("Input rows:", nrow(data), "\n")
cat("Sampled rows:", nrow(sampled_data), "\n")
cat("Random seed:", random_seed, "\n")
cat("Output file:", normalizePath(output_file, winslash = "/", mustWork = FALSE), "\n")
