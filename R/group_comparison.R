# Functions for comparing antimicrobial-resistance gene counts among groups.

check_packages <- function(packages) {
  missing_packages <- packages[
    !vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  ]

  if (length(missing_packages) > 0L) {
    stop(
      "Missing required package(s): ",
      paste(missing_packages, collapse = ", "),
      ". Run `Rscript install_dependencies.R` first.",
      call. = FALSE
    )
  }
}

read_group_data <- function(input_file, sheet = 1) {
  check_packages("readxl")

  if (!file.exists(input_file)) {
    stop("Input file does not exist: ", input_file, call. = FALSE)
  }

  raw_data <- readxl::read_excel(input_file, sheet = sheet)
  if (ncol(raw_data) < 2L) {
    stop("The input file must contain at least two columns.", call. = FALSE)
  }

  group <- trimws(as.character(raw_data[[1L]]))
  gene_count <- suppressWarnings(as.numeric(raw_data[[2L]]))
  valid <- !is.na(group) & nzchar(group) & !is.na(gene_count)

  if (any(!valid)) {
    warning(sum(!valid), " row(s) with missing or invalid values were removed.")
  }

  data <- data.frame(
    Group = factor(group[valid]),
    GeneCount = gene_count[valid],
    stringsAsFactors = TRUE
  )

  if (nrow(data) == 0L) {
    stop("No valid observations remain after data cleaning.", call. = FALSE)
  }
  if (nlevels(data$Group) < 2L) {
    stop("At least two non-empty groups are required.", call. = FALSE)
  }

  data
}

summarise_groups <- function(data) {
  values_by_group <- split(data$GeneCount, data$Group, drop = TRUE)

  summary_rows <- lapply(names(values_by_group), function(group_name) {
    values <- values_by_group[[group_name]]
    data.frame(
      group = group_name,
      n = length(values),
      median = stats::median(values),
      q1 = unname(stats::quantile(values, probs = 0.25, names = FALSE)),
      q3 = unname(stats::quantile(values, probs = 0.75, names = FALSE)),
      stringsAsFactors = FALSE
    )
  })

  summary_table <- do.call(rbind, summary_rows)
  summary_table[order(-summary_table$median, summary_table$group), , drop = FALSE]
}

run_group_comparison <- function(
    input_file,
    output_dir,
    analysis_name,
    sheet = 1,
    alpha = 0.05,
    adjustment_method = "bonferroni") {
  check_packages(c("readxl", "FSA"))

  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      alpha <= 0 || alpha >= 1) {
    stop("`alpha` must be a single number between 0 and 1.", call. = FALSE)
  }

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  data <- read_group_data(input_file, sheet = sheet)
  group_summary <- summarise_groups(data)

  kruskal_result <- stats::kruskal.test(GeneCount ~ Group, data = data)
  kruskal_table <- data.frame(
    analysis = analysis_name,
    statistic_h = unname(kruskal_result$statistic),
    degrees_of_freedom = unname(kruskal_result$parameter),
    p_value = kruskal_result$p.value,
    significant = kruskal_result$p.value < alpha,
    alpha = alpha,
    stringsAsFactors = FALSE
  )

  dunn_raw <- FSA::dunnTest(
    GeneCount ~ Group,
    data = data,
    method = adjustment_method
  )$res

  dunn_table <- data.frame(
    comparison = dunn_raw$Comparison,
    z = dunn_raw$Z,
    p_unadjusted = dunn_raw$P.unadj,
    p_adjusted = dunn_raw$P.adj,
    significant = dunn_raw$P.adj < alpha,
    stringsAsFactors = FALSE
  )
  significant_dunn <- dunn_table[dunn_table$significant, , drop = FALSE]

  utils::write.csv(
    group_summary,
    file.path(output_dir, "group_summary.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    kruskal_table,
    file.path(output_dir, "kruskal_wallis.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    dunn_table,
    file.path(output_dir, "dunn_all_comparisons.csv"),
    row.names = FALSE,
    na = ""
  )
  utils::write.csv(
    significant_dunn,
    file.path(output_dir, "dunn_significant_comparisons.csv"),
    row.names = FALSE,
    na = ""
  )

  report <- c(
    paste0("Analysis: ", analysis_name),
    paste0("Input file: ", normalizePath(input_file, winslash = "/")),
    paste0("Valid observations: ", nrow(data)),
    paste0("Groups: ", nlevels(data$Group)),
    "",
    "Kruskal-Wallis rank-sum test",
    sprintf("H = %.6f", unname(kruskal_result$statistic)),
    sprintf("df = %d", as.integer(kruskal_result$parameter)),
    sprintf("P = %.10e", kruskal_result$p.value),
    "",
    paste0("Dunn test adjustment method: ", adjustment_method),
    paste0("Significance threshold: ", alpha),
    paste0("Significant pairwise comparisons: ", nrow(significant_dunn))
  )
  writeLines(report, file.path(output_dir, "analysis_report.txt"), useBytes = TRUE)
  writeLines(
    capture.output(utils::sessionInfo()),
    file.path(output_dir, "session_info.txt"),
    useBytes = TRUE
  )

  message("Completed analysis: ", analysis_name)
  message("Results written to: ", normalizePath(output_dir, winslash = "/"))

  invisible(list(
    data = data,
    group_summary = group_summary,
    kruskal_wallis = kruskal_table,
    dunn = dunn_table
  ))
}

