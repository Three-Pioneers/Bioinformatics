suppressMessages(library(DESeq2))
suppressMessages(library(ggplot2))
suppressMessages(library(ggrepel))

bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))

args <- commandArgs(TRUE)
if (length(args) != 3) {
  stop("用法：Rscript PCA.R COUNT.txt sample_info.txt outdir")
}

count <- as.matrix(read.table(args[1], header = TRUE, sep = "\t", row.names = 1, check.names = FALSE, comment.char = ""))
samples <- read.table(args[2], header = TRUE, sep = "\t", colClasses = "character", check.names = FALSE, comment.char = "")


if (!is.numeric(count) || any(!is.finite(count)) || any(count < 0)) {
  stop("COUNT 必须是非负数值，且不能包含缺失值或无穷值")
}
if (!all(c("sample_id", "group") %in% names(samples))) {
  stop("分组表必须包含 sample_id 和 group 两列")
}

index <- match(colnames(count), samples$sample_id)	# 将 COUNT 的列和样本表的行对应于 index
if (anyDuplicated(samples$sample_id) || anyNA(index)) {
  stop("分组表的样本名不能重复，且必须包含 COUNT 表中的所有样本")
}
samples <- samples[index, , drop = FALSE]	# 将样本表根据 index 重新排列

if (anyNA(samples$group) || any(!nzchar(trimws(samples$group)))) {
  stop("样本分组不能为空")
}
samples$group <- factor(samples$group)	# 转化为因子

# 过滤总计数不超过 1 的基因
count <- count[rowSums(count) > 1, , drop = FALSE]	# 过滤低表达基因

if (ncol(count) < 3 || nrow(count) < 2) {
  stop("需要至少 3 个样本，且过滤后至少保留 2 个基因")
}
if (any(colSums(count) == 0)) {
  stop("过滤后存在全零样本，无法进行归一化")
}


# DESeq2 归一化和 VST 转换；不参考预设分组进行 VST 变异估计，先做样本质控、观察样本整体关系
coldata <- data.frame(group = samples$group, row.names = colnames(count))
dds <- DESeqDataSetFromMatrix(round(count), coldata, ~ 1)	# ~1 消除分组效应的影响
dds <- estimateSizeFactors(dds, type = "poscounts")	# 估计每个样本的测序深度，只考虑正计数的稳健估计法
count <- assay(varianceStabilizingTransformation(dds, blind = TRUE))	# 方差转换

# 选择 VST 转换后方差最大的至多 500 个基因
variance <- apply(count, 1, var)	# 计算方差
genes <- which(is.finite(variance) & variance > 0)	# 挑选有方差也就是样本值不同的基因，同时不要 NA 等
if (length(genes) < 2) {
  stop("需要至少 2 个有变异的基因")
}
genes <- head(genes[order(variance[genes], decreasing = TRUE)], 500)	# 取方差从大到小的前 500 个基因


dir.create(args[3], recursive = TRUE, showWarnings = FALSE)
scores_file <- file.path(args[3], "COUNT_PCA_scores.txt")
pdf_file <- file.path(args[3], "COUNT_PCA.pdf")
png_file <- file.path(args[3], "COUNT_PCA.png")

# 所有样本共同计算 PCA，并导出全部主成分坐标
pca <- prcomp(t(count[genes, , drop = FALSE]))	# 方差计算公式
percent <- 100 * pca$sdev^2 / sum(pca$sdev^2)
scores <- data.frame(
  sample_id = colnames(count),
  group = samples$group,
  pca$x,
  check.names = FALSE
)
write.table(scores, scores_file, sep = "\t", quote = FALSE, row.names = FALSE)

# 所有样本及其名称放在同一张图上
p <- ggplot(scores, aes(PC1, PC2, color = group, label = sample_id)) +
  geom_point(size = 2.4, alpha = 0.9) +
  geom_text_repel(
    size = 3.2, max.overlaps = Inf, seed = 1,
    box.padding = 0.4, point.padding = 0.25,
    max.time = 30, max.iter = 1000000,
    min.segment.length = 0, show.legend = FALSE
  ) +
  scale_color_manual(
	values = group_colors(samples$group),
	labels = function(x) wrap_labels(x)
  ) +
  guides(color = group_guide(samples$group)) +
  labs(
    x = sprintf("PC1 (%.2f%%)", percent[1]),
    y = sprintf("PC2 (%.2f%%)", percent[2]),
    color = "Group"
  ) +
  paper_theme() +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5)) +
  scale_x_continuous(expand = expansion(mult = 0.16)) +
  scale_y_continuous(expand = expansion(mult = 0.16))

ggsave(png_file, p, width = 175, height = 125, bg = "white", units = "mm", dpi = 600)
ggsave(pdf_file, p, width = 175, height = 125, bg = "white", units = "mm")
