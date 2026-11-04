#!/usr/bin/env Rscript
# MA 图：无重复比较的 GFOLD 分数与表达水平。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))

args <- commandArgs(TRUE)
if (length(args) != 2) {
  stop("用法：Rscript MA.R All_genes_exprData.txt 输出目录")
}
data <- read_input(args[1]) |>
  mutate(across(all_of(c("GFOLD_score", "baseMean")), as.numeric)) |>
  filter(is.finite(GFOLD_score), is.finite(baseMean)) |>
  mutate(Direction = factor(Direction, levels = c("Down", "No", "Up")))

# GFOLD 分数专列展示，不冒充真实 log2FC，也不绘制无统计依据的 ±1 阈值。
p <- ggplot(data, aes(log10(baseMean + 1), GFOLD_score, color = Direction)) +
  geom_point(size = 0.85, alpha = 0.65) +
  geom_hline(yintercept = 0, linetype = 2, color = "#777777") +
  scale_color_manual(values = direction_colors, drop = FALSE) +
  labs(
    x = "log10(mean count + 1)", y = "GFOLD score", color = NULL,
    subtitle = "Exploratory comparison without biological replication"
  )
# 报告在无重复比较中沿用 volcano 图位，文件名保持一致。
save_figure(p, args[2], "volcano", width = 165, height = 120)
