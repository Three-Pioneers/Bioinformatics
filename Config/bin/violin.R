#!/usr/bin/env Rscript
# 按样本绘制表达量分布：小提琴显示分布形状，内嵌箱线图显示中位数和四分位数。
script_dir <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(script_dir, "plot_utils.R"))

# 1. 读取输入。矩阵格式为 id + 样本表达列，支持 COUNT、FPKM、TPM。
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
  stop("用法：Rscript violin.R 定量矩阵.txt sample_info.txt 输出目录", call. = FALSE)
}
expression_file <- args[1]
sample_info_file <- args[2]
outdir <- args[3]
label <- matrix_label(expression_file)
expression_matrix <- read_expression(expression_file)
sample_info <- read_groups(sample_info_file, colnames(expression_matrix))

# 2. 去掉所有样本均未表达的基因；单个样本中的零值仍保留。
expression_matrix <- expression_matrix[rowSums(expression_matrix) > 0, , drop = FALSE]
if (!nrow(expression_matrix)) {
  empty_plot(outdir, paste0(label, "_violin"), "No expressed genes")
  quit(save = "no", status = 0)
}
log_expression <- log2(expression_matrix + 1)

# 3. 集中设置分页、标签和配色。总样本数超过 8 个时，各页标签统一倾斜 45°。
sample_count <- ncol(expression_matrix)
samples_per_page <- 12
tilt_labels <- sample_count > 8
x_label_angle <- if (tilt_labels) 45 else 0
x_label_hjust <- if (tilt_labels) 1 else 0.5
# 水平标签较密时缩短每行；倾斜标签在左侧多留空，避免首个名称被裁切。
x_label_width <- if (!tilt_labels && sample_count > 6) 8 else 18
x_axis_padding <- c(if (tilt_labels) 1 else 0.6, 0.6)
fill_colors <- group_colors(sample_info$group)
sample_groups <- as_tibble(sample_info) |>
  select(sample_id, group)

# 4. 逐页绘图，保留输入矩阵中的样本顺序；长名称自动换行。
plot_sample_page <- function(indices) {
  page_samples <- colnames(expression_matrix)[indices]
  plot_data <- as_tibble(log_expression[, indices, drop = FALSE], .name_repair = "minimal") |>
    pivot_longer(everything(), names_to = "sample_id", values_to = "value") |>
    left_join(sample_groups, by = "sample_id") |>
    mutate(sample_id = factor(sample_id, levels = page_samples))

  ggplot(plot_data, aes(x = sample_id, y = value, fill = group)) +
    geom_violin(scale = "width", linewidth = 0.35, alpha = 0.8) +
    geom_boxplot(width = 0.16, outlier.shape = NA, fill = "white", linewidth = 0.35) +
    scale_fill_manual(values = fill_colors, labels = \(x) wrap_labels(x)) +
    scale_x_discrete(
      labels = \(x) wrap_labels(x, width = x_label_width),
      expand = expansion(add = x_axis_padding)
    ) +
    guides(fill = group_guide(sample_info$group)) +
    labs(x = NULL, y = paste0("log2(", label, " + 1)"), fill = "Group") +
    theme(axis.text.x = element_text(
      angle = x_label_angle, hjust = x_label_hjust, vjust = 1, lineheight = 0.95
    ))
}
plots <- map(page_indices(sample_count, samples_per_page), plot_sample_page)
save_plot_pages(
  plots, outdir, paste0(label, "_violin"),
  width = max(175, 30 + min(sample_count, samples_per_page) * 16), height = 140
)

# 5. 输出统计：中位数基于图中相同的 log2 表达量，表达基因数基于原始非零值。
distribution <- tibble(
  sample_id = colnames(expression_matrix),
  group = sample_info$group,
  median = map_dbl(as_tibble(log_expression, .name_repair = "minimal"), median),
  expressed_genes = colSums(expression_matrix > 0)
)
write_tsv(distribution, file.path(outdir, paste0(label, "_distribution_summary.txt")))
