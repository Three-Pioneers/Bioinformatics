suppressMessages(library(tidyverse))
suppressMessages(library(DESeq2))

args <- commandArgs(TRUE)
if (length(args) != 3) {
  stop("用法：Rscript diffExprGene.R COUNT.txt sample_info.txt 输出目录")
}
outdir <- args[3]

p_column <- "padj"
p_cutoff <- 0.05
lfc_cutoff <- 1

# 1. 读取固定格式；样本表由 gene_order.py 按处理组、对照组依次输出。
# COUNT 的 id 列为基因，其余列为样本原始整数计数。
count <- as.matrix(read.table(args[1], header=TRUE, sep="\t", row.names=1, check.names=FALSE, comment.char="", quote=""))
samples <- read.table(args[2], header = TRUE, sep = "\t", colClasses = "character", check.names = FALSE, comment.char = "", quote = "")

control <- as.character(last(samples$group))
samples <- tibble(sample_id = colnames(count)) %>%
  left_join(samples, by = "sample_id") %>%
  column_to_rownames("sample_id")
if (any(colSums(count) == 0)) {
  stop("DESeq2 不能估计零计数样本的归一化因子")
}
if (n_distinct(samples$group) != 2 || ncol(count) <= 2) {
  stop("DESeq2 需要两个组且存在生物学重复；1:1 使用 GFOLD")
}
samples$group <- relevel(factor(samples$group), ref = control)
treat <- setdiff(levels(samples$group), control)

# 低表达过滤：至少 minimum 个样本的计数达到 10；minimum 为较小组样本数。
# 此处只按表达量筛选，不先看差异检验结果。
minimum <- min(table(samples$group))
keep <- rowSums(count >= 10) >= minimum
if (!any(keep)) {
  stop("表达过滤后没有可检验基因，请检查计数与建库")
}

# 2. 单因素模型只估计组别差异，归一化和离散度由 DESeq2 估计。
# contrast 明确指定处理组相对对照组，保证 log2FC 的方向一致。
dds <- DESeqDataSetFromMatrix(count[keep, , drop = FALSE], samples, ~group)
fit <- DESeq(dds, quiet = TRUE)
result <- results(fit, contrast = c("group", treat, control), alpha = p_cutoff) %>%
  as.data.frame() %>%
  rownames_to_column("id")
significant <- is.finite(result$padj) & is.finite(result$log2FoldChange) &
  result$padj < p_cutoff & abs(result$log2FoldChange) >= lfc_cutoff
# 3. 完整表供 GSEA 排名，显著表供功能注释与富集，统一保留原始 id。
# 保留 Wald 统计量供复核；无有效检验的 NA 不作为显著基因。
result <- result %>%
  mutate(Direction = if_else(significant,
    if_else(log2FoldChange >= 0, "Up", "Down"), "No"
  )) %>%
  select(id, baseMean, log2FoldChange, lfcSE, stat, pvalue, padj, Direction)
write_tsv(result, file.path(outdir, "All_genes_exprData.txt"))
write_tsv(
  filter(result, Direction != "No"),
  file.path(outdir, "Sig_genes_exprData.txt")
)

# 将阈值、输入校验值和软件版本随结果保存，便于复核与复现。
parameters <- tibble(
  parameter = c(
    "method", "p_column", "p_cutoff", "log2fc_cutoff", "contrast",
    "count_md5", "DESeq2_version", "expression_filter", "tested_genes"
  ),
  value = c(
    "DESeq2", p_column, p_cutoff, lfc_cutoff, paste(treat, "vs", control),
    unname(tools::md5sum(args[1])), as.character(packageVersion("DESeq2")),
    paste0("count>=10 in at least ", minimum, " samples"), nrow(result)
  )
)
write_tsv(parameters, file.path(outdir, "analysis_parameters.tsv"))
writeLines(capture.output(sessionInfo()), file.path(outdir, "sessionInfo.txt"))
