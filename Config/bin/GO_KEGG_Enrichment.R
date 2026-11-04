#!/usr/bin/env Rscript
# GO/KEGG 富集：BP/CC/MF 分别检验，输出结果表、条形图和点图。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))
suppressMessages(library(clusterProfiler))

args <- commandArgs(TRUE)
if (length(args) < 5) {
  stop("用法：Rscript GO_KEGG_Enrichment.R Sig_genes_exprData.txt GO_annotation KEGG_annotation 输出目录 All_genes_exprData.txt [--plot-only]")
}
sig <- read_input(args[1]) |>
  mutate(across(any_of(c("padj", "log2FoldChange")), as.numeric))
all_genes <- read_input(args[5]) |>
  mutate(across(any_of(c("pvalue", "baseMean")), as.numeric))
outdir <- args[4]
plot_only <- "--plot-only" %in% args
# 与差异分析使用相同筛选阈值，不再从命令行传入。
diff_cutoff <- 0.05
lfc_cutoff <- 1

if ("padj" %in% names(sig) && !"GFOLD_score" %in% names(sig)) {
  sig <- sig |>
    filter(
      is.finite(padj), padj < diff_cutoff,
      is.finite(log2FoldChange), abs(log2FoldChange) >= lfc_cutoff
    )
}
clean_id <- \(ids) str_remove(ids, "\\(.*$")
genes <- unique(clean_id(sig$id))
# 背景为实际接受检验的基因；无重复 GFOLD 使用非零表达的有效基因。
valid <- if ("pvalue" %in% names(all_genes)) {
  is.finite(all_genes$pvalue)
} else {
  all_genes$baseMean > 0
}
background <- unique(clean_id(all_genes$id[valid]))
if (!plot_only) {
  tibble(
    parameter = c(
      "candidate_genes", "tested_background", "diff_padj_cutoff",
      "diff_abs_log2fc_cutoff", "enrichment_adjustment"
    ),
    value = c(length(genes), length(background), diff_cutoff, lfc_cutoff, "BH")
  ) |>
    write_tsv(file.path(outdir, "enrichment_parameters.tsv"))
}

# 空结果也输出标准列，报告读取时不需要特殊分支。
empty <- tibble(
  ID = character(), Description = character(), GeneRatio = character(),
  BgRatio = character(), pvalue = numeric(), p.adjust = numeric(),
  qvalue = numeric(), geneID = character(), Count = integer()
)

# 每次仅检验当前本体/通路，候选基因与背景由上方统一确定。
run_enrichment <- function(anno, term, description, minimum = 10) {
  anno <- anno |>
    mutate(ID = clean_id(ID)) |>
    filter(!is.na(ID), !is.na(.data[[term]]), !.data[[term]] %in% c("", "--"))
  # 同一基因-条目关系只保留一条，避免重复注释影响集合大小。
  mapping <- anno |>
    select(all_of(c(term, "ID"))) |>
    distinct()
  term_names <- anno |>
    select(all_of(c(term, description))) |>
    distinct() |>
    distinct(.data[[term]], .keep_all = TRUE)
  if (!length(genes) || !nrow(mapping) || !length(intersect(genes, mapping[[2]]))) {
    return(empty)
  }
  # 先保留全部可检验结果，显著性统一在输出阶段按 BH 校正值筛选。
  result <- enricher(
    genes,
    universe = background, TERM2GENE = as.data.frame(mapping),
    TERM2NAME = as.data.frame(term_names), minGSSize = minimum,
    maxGSSize = 10000, pvalueCutoff = 1, qvalueCutoff = 1
  )
  if (is.null(result)) empty else as_tibble(result@result)
}

if (plot_only) {
  # 只重画已有统计结果，调整排版时无需重复富集检验。
  go_result <- read_input(file.path(outdir, "All_GO_Enrichment.txt")) |>
    mutate(across(all_of(c("pvalue", "p.adjust", "qvalue", "Count")), as.numeric))
  kegg_result <- read_input(file.path(outdir, "All_KEGG_Enrichment.txt")) |>
    mutate(across(all_of(c("pvalue", "p.adjust", "qvalue", "Count")), as.numeric))
} else {
  go <- read_input(args[2])
  classes <- c(
    biological_process = "BP", cellular_component = "CC", molecular_function = "MF"
  )
  go_result <- map2(names(classes), unname(classes), \(ontology, code) {
    go |>
      filter(class %in% c(ontology, code)) |>
      run_enrichment("go", "name") |>
      mutate(class = code)
  }) |> list_rbind()
  kegg <- read_input(args[3])
  kegg_result <- run_enrichment(kegg, "Pathway_id", "Pathway_name", minimum = 3)
}

# 绘图仅截取展示条目，完整检验结果和显著结果表始终保留全部行。
plot_results <- function(results, label) {
  results <- as_tibble(results) |> arrange(p.adjust, pvalue)
  significant <- results |> filter(is.finite(p.adjust), p.adjust < 0.05)
  if (!plot_only) {
    write_tsv(results, file.path(outdir, paste0("All_", label, "_Enrichment.txt")))
    write_tsv(significant, file.path(outdir, paste0("Sig_", label, "_Enrichment.txt")))
  }
  # 初版图按原始 P 值选取展示条目；统计显著性仍由结果表中的 p.adjust 判断。
  ranked <- results |> filter(is.finite(pvalue)) |> arrange(pvalue)
  if (!nrow(ranked)) {
    for (kind in c("barplot", "dotplot")) {
      empty_plot(
        outdir, paste0(label, "_", kind), paste("No", label, "enrichment results")
      )
    }
    return(invisible(NULL))
  }
  preferred <- ranked |> filter(pvalue < 0.05)
  if (!nrow(preferred)) {
    preferred <- ranked
  }
  # 恢复 2026-10-20 初版的条目数量、排列、默认图例及 theme_light 外观。
  display <- if (label == "GO") {
    preferred |> group_by(class) |> slice_head(n = 15) |> ungroup() |> arrange(class, Count)
  } else {
    preferred |> slice_head(n = 20)
  }
  width <- 15
  height <- 10
  if (label == "KEGG" && any(ranked$pvalue < 0.05) && sum(ranked$pvalue < 0.05) < 10) {
    width <- 8
    height <- 4
  }

  bar <- ggplot(display, aes(y = Count, x = Description))
  if (label == "GO") {
    label_names <- unique(display$class)
    bar <- bar + geom_bar(stat = "identity", aes(fill = class), alpha = 1) +
      facet_grid(class ~ ., scales = "free", space = "free", margins = FALSE) +
      coord_flip() + scale_fill_discrete(name = "Ontology", labels = label_names)
  } else {
    bar <- bar + geom_bar(stat = "identity", alpha = 1, fill = "#9ACD32") + coord_flip()
  }
  bar <- bar + theme_light() +
    theme(axis.text = element_text(size = 10), legend.text = element_text(size = 10)) +
    labs(y = "Number of Genes", x = "Term") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    labs(title = paste0(" ", label, " barplot")) +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_y_continuous(breaks = scales::pretty_breaks())

  dots <- display |> mutate(richfactor = Count / as.numeric(str_remove(BgRatio, "/.*$")))
  dot <- ggplot(dots, aes(x = richfactor, y = Description)) +
    geom_point(aes(size = Count, color = pvalue)) +
    scale_size("Count") + scale_color_continuous(low = "red", high = "green") +
    theme_light() +
    theme(axis.text = element_text(size = 10), legend.text = element_text(size = 10)) +
    labs(x = "Rich factor", y = "Term", title = paste0(" ", label, " dotplot")) +
    theme(plot.title = element_text(hjust = 0.5))

  for (kind in c("barplot", "dotplot")) {
    plot <- if (kind == "barplot") bar else dot
    stem <- paste0(label, "_", kind)
    unlink(Sys.glob(file.path(outdir, paste0(stem, "_page*.png"))))
    unlink(file.path(outdir, paste0(stem, "_pages.txt")))
    ggsave(file.path(outdir, paste0(stem, ".pdf")), plot, width = width, height = height, units = "in")
    ggsave(file.path(outdir, paste0(stem, ".png")), plot, width = width, height = height, units = "in")
  }
}

plot_results(go_result, "GO")
plot_results(kegg_result, "KEGG")
