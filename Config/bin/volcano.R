#!/usr/bin/env Rscript
# 火山图：保留原差异结果，分层展示非显著/上调/下调基因，并平衡两侧标注。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))

args <- commandArgs(TRUE)
if (length(args) != 2) {
  stop("用法：Rscript volcano.R All_genes_exprData.txt 输出目录")
}
data <- read_input(args[1]) |>
  mutate(across(all_of(c("log2FoldChange", "padj")), as.numeric))
outdir <- args[2]
# 参考线和说明沿用差异筛选阈值；Direction 直接读取统计结果，不重新判定。
p_cutoff <- 0.05
lfc_cutoff <- 1
data <- data |>
  filter(is.finite(log2FoldChange), !is.na(padj)) |>
  mutate(
    score = -log10(pmax(padj, 1e-300)),
    Direction = factor(Direction, levels = c("Down", "No", "Up"))
  )
if (!nrow(data)) {
  empty_plot(outdir, "volcano", "No valid differential expression results")
  quit(save = "no", status = 0)
}

# 图例直接记录当前图中的基因数，缺少某一类别时仍显示 0。
counts <- data |> filter(!is.na(Direction)) |> count(Direction, .drop = FALSE)
direction_names <- c(Down = "Down", No = "Not significant", Up = "Up")
legend_labels <- setNames(
  paste0(direction_names[as.character(counts$Direction)], " (",
         scales::comma(counts$n, accuracy = 1), ")"),
  as.character(counts$Direction)
)
colors <- c(Down = direction_colors[["Down"]], No = "#CBD2D9", Up = direction_colors[["Up"]])
# 横轴以零为中心，并保留全部有限 log2FC；额外留白用于基因标签。
x_limit <- max(3, max(abs(data$log2FoldChange))) * 1.12
y_limit <- max(-log10(p_cutoff) * 1.8, max(data$score)) * 1.16
comparison <- basename(dirname(args[1]))
comparison <- if (grepl("_vs_", comparison, fixed = TRUE)) {
  gsub("_vs_", " vs ", comparison, fixed = TRUE)
} else {
  "Differential expression"
}

p <- ggplot(data, aes(log2FoldChange, score, color = Direction)) +
  # 浅灰点先画，显著基因后画，避免大量背景点遮住候选基因。
  geom_point(
    data = filter(data, Direction == "No" | is.na(Direction)),
    size = 0.8, alpha = 0.48
  ) +
  geom_point(
    data = filter(data, Direction %in% c("Down", "Up")),
    size = 1.15, alpha = 0.9
  ) +
  geom_hline(
    yintercept = -log10(p_cutoff), linetype = "dashed",
    linewidth = 0.32, color = "#A0A9B2"
  ) +
  geom_vline(
    xintercept = c(-lfc_cutoff, lfc_cutoff), linetype = "dashed",
    linewidth = 0.32, color = "#A0A9B2"
  ) +
  scale_color_manual(
    values = colors, labels = legend_labels, limits = c("Down", "No", "Up"),
    drop = FALSE, na.value = colors["No"]
  ) +
  scale_x_continuous(
    limits = c(-x_limit, x_limit), breaks = scales::breaks_pretty(n = 7),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(0, y_limit), breaks = scales::breaks_pretty(n = 5),
    expand = expansion(mult = 0)
  ) +
  guides(color = guide_legend(
    nrow = 1, byrow = TRUE, override.aes = list(size = 2.8, alpha = 1)
  )) +
  labs(
    title = comparison,
    subtitle = "Differential gene expression",
    x = expression(log[2](fold~change)),
    y = expression(-log[10](adjusted~P)),
    color = NULL
  ) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 1),
    axis.title = element_text(color = "#344454"),
    plot.title = element_text(face = "bold", size = 13, hjust = 0),
    plot.subtitle = element_text(size = 10, color = "#677785", margin = margin(b = 5)),
    plot.caption = element_text(size = 8.5, color = "#73818C", hjust = 0, margin = margin(t = 9)),
    legend.position = "top", legend.direction = "horizontal",
    legend.justification = "center", legend.box.just = "center",
    legend.background = element_blank(), legend.key = element_blank(),
    legend.text = element_text(size = 9.5, color = "#40515E"),
    legend.key.width = grid::unit(4, "mm"), legend.key.height = grid::unit(4, "mm"),
    legend.spacing.x = grid::unit(3, "mm"), legend.margin = margin(0, 0, 3, 0),
    plot.margin = margin(5, 7, 5, 5)
  )

# 两个方向各标注至多 3 个最显著基因，避免只标到一侧或遮挡散点。
top <- data |>
  filter(Direction %in% c("Down", "Up")) |>
  arrange(padj, desc(abs(log2FoldChange))) |>
  group_by(Direction) |>
  slice_head(n = 3) |>
  ungroup() |>
  mutate(label = wrap_labels(gene_labels(id), 22))
if (nrow(top) && requireNamespace("ggrepel", quietly = TRUE)) {
  p <- p + ggrepel::geom_text_repel(
    data = top, aes(label = label), seed = 1,
    size = 3.0, max.overlaps = Inf, show.legend = FALSE,
    box.padding = 0.45, point.padding = 0.3, force = 1.2,
    min.segment.length = 0, segment.color = "#A9B2BB", segment.size = 0.25,
    max.time = 3, max.iter = 100000
  )
}
save_figure(p, outdir, "volcano", width = 180, height = 145)
