#!/usr/bin/env Rscript
# 样本相关性：CPM/log2 转换，分别输出 Pearson、Spearman 矩阵及 PNG/PDF 热图。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))

# 1. 读取参数和表达矩阵；COUNT、FPKM、TPM 使用同一套流程。
args <- commandArgs(TRUE)

if (length(args) != 2) {
  stop("用法：Rscript cor.R {COUNT, FPKM/RPKM, TPM}.txt <output_dir>")
}

label <- matrix_label(args[1])
expression_matrix <- read_expression(args[1])
outdir <- args[2]
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# Pearson 沿用原文件名；Spearman 单独加后缀，避免覆盖。
methods <- list(pearson = "Pearson r", spearman = expression(Spearman~rho))
output_labels <- c(pearson = label, spearman = paste0(label, "_spearman"))

# 2. 去除共同全零的基因；COUNT 转 CPM，再统一取 log2(x + 1)。
expression_matrix <- expression_matrix[rowSums(expression_matrix) > 0, , drop = FALSE]
if (label == "COUNT") {
  library_sizes <- pmax(colSums(expression_matrix), 1)
  expression_matrix <- sweep(expression_matrix, 2, library_sizes / 1e6, "/")
}
expression_matrix <- log2(expression_matrix + 1)
sample_count <- ncol(expression_matrix)
if (nrow(expression_matrix) < 2 || sample_count < 2 ||
    any(apply(expression_matrix, 2, sd) == 0)) {
  notice <- ggplot() +
    annotate("text", x = 0, y = 0,
      label = "Insufficient variation for sample correlation", size = 3.5, color = "#666666") +
    theme_void()
  for (output_label in output_labels) {
    save_figure(notice, outdir, paste0(output_label, "_cor"), width = 160, height = 150)
  }
  quit(save = "no", status = 0)
}

# 两种方法固定使用 160 × 150 mm 画布；超过 8 个样本时横轴倾斜 45 度。
slant_labels <- sample_count > 8

for (method in names(methods)) {
  output_label <- output_labels[[method]]

  # 3. 基因是观测项、样本是变量；完整相关矩阵按原始样本顺序导出。
  correlation <- cor(expression_matrix, method = method)
  as.data.frame(correlation, check.names = FALSE) |>
    rownames_to_column("sample_id") |>
    write_tsv(file.path(outdir, paste0(output_label, "_correlation.txt")))

  # 4. 保留输入矩阵的样本顺序，两种方法不再聚类重排。
  sample_names <- colnames(correlation)

  # 每对样本只画一次；保留自相关对角线，确保两轴都有全部样本。
  cells <- which(lower.tri(correlation, diag = TRUE), arr.ind = TRUE)
  tiles <- tibble(
    sample_x = factor(sample_names[cells[, "row"]], levels = sample_names),
    sample_y = factor(sample_names[cells[, "col"]], levels = sample_names),
    r = correlation[cells]
  )

  # 5. 两种方法使用相同的灰底白网格和蓝—白—橙色阶。
  plot <- ggplot(tiles, aes(sample_x, sample_y, fill = r)) +
    geom_tile(color = "white", linewidth = 0.3) +
    scale_fill_gradient2(
      low = "#6D9EC1", mid = "white", high = "#E46726",
      midpoint = 0, limits = c(-1, 1),
      breaks = c(-1, -0.5, 0, 0.5, 1), name = methods[[method]]
    ) +
    # 横轴从左到右、纵轴从下到上，均严格使用输入顺序。
    scale_x_discrete(
      limits = sample_names, drop = FALSE,
      labels = \(x) wrap_labels(x, if (slant_labels) 32 else 18)
    ) +
    scale_y_discrete(
      limits = sample_names, drop = FALSE,
      labels = \(x) wrap_labels(x, 18)
    ) +
    guides(fill = upper_colorbar()) +
    coord_equal() +
    labs(x = NULL, y = NULL) +
    theme_gray(base_size = 11, base_family = "sans") +
    theme(
      axis.text = element_text(color = "#555555"),
      axis.text.x = element_text(
        angle = if (slant_labels) 45 else 0,
        hjust = if (slant_labels) 1 else 0.5, vjust = 1, lineheight = 0.95
      ),
      panel.grid.major = element_line(color = "white", linewidth = 0.35),
      panel.grid.minor = element_blank(),
      legend.position = "right",
      plot.margin = margin(6, 8, 6, 6)
    )

  # 小矩阵显示四位小数，避免接近 1 的相关系数在色阶上难以区分。
  if (sample_count <= 8) {
    plot <- plot + geom_text(aes(label = sprintf("%.4f", r)), size = 2.5, color = "#222222")
  }

  # 完整热图保存在一页，固定画布大小；每种方法输出 PNG 和 PDF。
  save_figure(
    plot, outdir, paste0(output_label, "_cor"),
    width = 160, height = 150
  )
}
