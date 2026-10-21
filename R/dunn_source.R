required_packages <- c("readxl", "FSA")
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
input_file <- if (length(args) >= 1L) args[[1L]] else file.path("data", "source.xlsx")

raw_data <- readxl::read_excel(input_file, sheet = 1)
if (ncol(raw_data) < 2L) {
  stop("The input file must contain at least two columns.", call. = FALSE)
}

group <- trimws(as.character(raw_data[[1L]]))
gene_count <- suppressWarnings(as.numeric(raw_data[[2L]]))
keep <- !is.na(group) & nzchar(group) & !is.na(gene_count)
data <- data.frame(Group = factor(group[keep]), GeneCount = gene_count[keep])

if (nlevels(data$Group) < 2L) {
  stop("At least two non-empty groups are required.", call. = FALSE)
}

values_by_group <- split(data$GeneCount, data$Group)
summary_table <- do.call(rbind, lapply(names(values_by_group), function(group_name) {
  values <- values_by_group[[group_name]]
  data.frame(
    Group = group_name,
    N = length(values),
    Median = median(values),
    Q1 = unname(quantile(values, 0.25)),
    Q3 = unname(quantile(values, 0.75))
  )
}))
summary_table <- summary_table[order(-summary_table$Median, summary_table$Group), ]
row.names(summary_table) <- NULL

kruskal_result <- kruskal.test(GeneCount ~ Group, data = data)
invisible(capture.output(
  dunn_result <- FSA::dunnTest(
    GeneCount ~ Group,
    data = data,
    method = "bonferroni"
  )
))
dunn_table <- dunn_result$res
dunn_table$Significant <- ifelse(dunn_table$P.adj < 0.05, "Yes", "No")
dunn_table$P.unadj <- format(dunn_table$P.unadj, scientific = TRUE, digits = 10)
dunn_table$P.adj <- format(dunn_table$P.adj, scientific = TRUE, digits = 10)

cat("Source-group descriptive statistics\n")
print(summary_table, row.names = FALSE)
cat("\nKruskal-Wallis test\n")
cat(sprintf("H = %.6f; df = %d; P = %.10e\n",
            as.numeric(kruskal_result$statistic),
            as.integer(kruskal_result$parameter),
            kruskal_result$p.value))
cat("\nDunn test with Bonferroni correction\n")
print(dunn_table[, c("Comparison", "Z", "P.unadj", "P.adj", "Significant")],
      row.names = FALSE)
