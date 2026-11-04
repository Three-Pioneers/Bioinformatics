#!/usr/bin/env Rscript
# 差异基因数量：按比较绘制上调/下调基因柱状图。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))

args <- commandArgs(TRUE)
if (length(args) != 2) {
  stop("用法：Rscript diffExprGene_stats.R diffExprGene_stats_input.txt 输出目录")
}
# 显式指定列类型，只展示上调和下调数量，保持图例顺序一致。
data <- read_tsv(
  args[1],
  col_types = cols(
    group = col_character(), direction = col_character(), sum = col_double()
  ),
  name_repair = "minimal"
) |>
  filter(direction %in% c("Up", "Down")) |>
  mutate(direction = factor(direction, levels = c("Up", "Down")))

# 沿用输入表的比较顺序，每页最多展示 6 个比较。
comparisons <- unique(data$group)
plots <- map(page_indices(length(comparisons), 6), \(indices) {
  selected <- data |>
    filter(group %in% comparisons[indices]) |>
    mutate(group = factor(group, levels = comparisons[indices]))
  ggplot(selected, aes(group, sum, fill = direction)) +
    geom_col(position = position_dodge(width = 0.75), width = 0.65) +
    geom_text(
      aes(label = sum), position = position_dodge(width = 0.75),
      vjust = -0.4, size = 3.1
    ) +
    scale_fill_manual(values = direction_colors, breaks = c("Up", "Down")) +
    scale_x_discrete(labels = \(x) wrap_labels(x, 24)) +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.18)), labels = scales::label_comma()
    ) +
    labs(x = NULL, y = "Differentially expressed genes", fill = NULL) +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 1))
})
if (length(plots)) {
  save_plot_pages(plots, args[2], "diffExprGene_stats", width = 175, height = 125)
} else {
  empty_plot(args[2], "diffExprGene_stats", "No comparisons")
}
