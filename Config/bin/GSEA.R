#!/usr/bin/env Rscript
# GSEA：按全基因 log2FC 排序，评估 GO/KEGG 基因集的整体变化趋势。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))
suppressMessages(library(clusterProfiler))
suppressMessages(library(enrichplot))

args <- commandArgs(TRUE)
if (length(args) < 4) {
  stop("用法：Rscript GSEA.R All_genes_exprData.txt GO_annotation KEGG_annotation 输出目录")
}
plot_only <- "--plot-only" %in% args
data <- read_input(args[1]) |>
  mutate(log2FoldChange = as.numeric(log2FoldChange))
dir.create(args[4], recursive = TRUE, showWarnings = FALSE)
outdir <- normalizePath(args[4], mustWork = TRUE)
# 沿用原分析的真实 log2FC 排名；不随机打散相同值，不预筛差异基因。
metric <- "log2FoldChange"
data <- data |>
  mutate(id = str_remove(id, "\\(.*$")) |>
  filter(is.finite(.data[[metric]]), !duplicated(id)) |>
  arrange(desc(.data[[metric]]))
genelist <- data |>
  select(id, all_of(metric)) |>
  deframe()
tied <- if (length(genelist)) mean(duplicated(genelist)) else 0
# 排名值只有单一符号时采用对应单侧分数，混合符号时采用标准分数。
score_type <- if (length(genelist) && all(genelist >= 0)) {
  "pos"
} else if (length(genelist) && all(genelist <= 0)) {
  "neg"
} else {
  "std"
}
parameters <- tibble(
  parameter = c(
    "rank_metric", "valid_genes", "tied_fraction", "score_type",
    "minGSSize", "maxGSSize", "statistics_source"
  ),
  value = c(
    metric, length(genelist), tied, score_type, 10, 500,
    if (plot_only) "existing_result_tables" else "current_run"
  )
)
if (!plot_only) {
  write_tsv(parameters, file.path(outdir, "GSEA_parameters.tsv"))
}

# 原生三联图：保留运行富集分数、命中位置、完整排名指标，采用紧凑无外框版式。
draw_curve <- function(result, ids, title, folder, stem, overview = FALSE) {
  message("Drawing ", stem)
  panels <- map(1:3, \(i) {
    p <- gseaplot2(result, ids, subplots = i, base_size = 10.5)
    # ES 在相邻命中之间是直线：只删共线节点，曲线和峰值保持完全一致。
    if (i == 1) {
      p$data <- map(split(p$data, p$data$Description), \(d) {
        hit <- which(d$position == 1)
        d |> slice(sort(unique(c(1, nrow(d), hit, pmax(1, hit - 1)))))
      }) |> list_rbind()
    }
    if (i == 2) {
      p$data <- filter(p$data, position == 1)
    }
    # 排名指标各通路相同，画一次灰色面积，避免重复绘制数十万条重叠竖线。
    if (i == 3) {
      d <- p$layers[[1]]$data
      d <- distinct(d, x, .keep_all = TRUE)
      # 排名指标单调，按输出分辨率取 1500 个描绘节点；全部基因仍用于 ES 计算。
      d <- slice(d, unique(round(seq(1, n(), length.out = min(1500, n())))))
      p$layers <- list(geom_area(
        data = d, aes(x = x, y = y),
        inherit.aes = FALSE, fill = "grey70"
      ))
    }
    p <- p + paper_theme(10.5) + theme(
      plot.margin = margin(3, 5, 3, 4), legend.position = "none",
      axis.text.x = element_text(angle = 0, hjust = 0.5),
      axis.title.y = element_text(size = 10.5, margin = margin(r = 6)),
      plot.title = element_text(size = 11.5),
      plot.subtitle = element_text(size = 9.5)
    )
    if (i < 3) {
      p <- p + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
    }
    if (i == 2) {
      p <- p + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
    }
    p
  })
  title_parts <- strsplit(title, "\n", fixed = TRUE)[[1]]
  title_width <- if (overview) 38 else 68
  panels[[1]] <- panels[[1]] + labs(
    title = wrap_labels(title_parts[1], title_width),
    subtitle = if (length(title_parts) > 1) title_parts[2] else NULL,
    y = "Running enrichment\nscore"
  )
  panels[[3]] <- panels[[3]] + labs(y = "Ranked list\nmetric")
  combined <- cowplot::plot_grid(
    plotlist = panels, ncol = 1,
    rel_heights = c(1.5, 0.55, 1), align = "v", axis = "lr"
  )
  legend_height <- 0
  if (overview) {
    # 完整通路名在顶部两列展示；换行和增高画布，不挤占曲线宽度。
    legend_plot <- panels[[1]] +
      scale_color_discrete(labels = \(x) wrap_labels(x, 38)) +
      theme(
        legend.position = "top",
        legend.direction = "horizontal", legend.box = "horizontal",
        legend.text = element_text(size = 8.7, lineheight = 1.05, color = "#475569"),
        legend.title = element_text(size = 10, face = "bold", color = "#263445"),
        legend.background = element_blank(),
        legend.box.background = element_blank(),
        legend.key = element_blank(),
        legend.key.width = grid::unit(7, "mm"),
        legend.key.height = grid::unit(4.5, "mm"),
        legend.margin = margin(2, 2, 2, 2),
        legend.box.margin = margin(0, 0, 3, 0)
      ) +
      labs(color = "Gene set") +
      guides(color = guide_legend(
        ncol = 2, byrow = TRUE, title.position = "top",
        override.aes = list(linewidth = 0.9, alpha = 1)
      ))
    legend <- cowplot::get_legend(legend_plot)
    legend_height <- grid::convertHeight(sum(legend$heights), "mm", valueOnly = TRUE) + 4
    combined <- cowplot::plot_grid(legend, combined, ncol = 1,
      rel_heights = c(legend_height, 140))
  }
  message("Exporting ", stem)
  title_lines <- length(strsplit(wrap_labels(title_parts[1], title_width), "\n", fixed = TRUE)[[1]])
  # 顶部图例与三联图各有独立高度，通路名称再长也不会覆盖曲线。
  height <- if (overview) {
    140 + legend_height
  } else {
    max(130, 122 + title_lines * 4)
  }
  save_figure(
    combined, folder, stem,
    width = if (overview) 180 else 175, height = height
  )
  message("Written ", stem)
}

# 按当前排序和基因集重算 ES，用于 --plot-only 时校验旧结果表未被改动。
gsea_es <- function(values, set, exponent = 1, score_type = "std") {
  hits <- names(values) %in% set
  n_hit <- sum(hits)
  if (!n_hit) {
    return(NA_real_)
  }
  n_miss <- length(values) - n_hit
  # 命中基因按排名值绝对值加权，未命中基因均分向下步长。
  weights <- abs(values[hits])^exponent
  if (!is.finite(sum(weights)) || sum(weights) == 0) {
    return(NA_real_)
  }
  delta <- if (n_miss > 0) {
    rep(-1 / n_miss, length(values))
  } else {
    numeric(length(values))
  }
  delta[hits] <- weights / sum(weights)
  running <- cumsum(delta)
  switch(score_type,
    pos = max(running),
    neg = min(running),
    running[which.max(abs(running))]
  )
}

# 为 GO 和 KEGG 共用同一套注释清洗、统计与输出流程。
run_gsea <- function(annotation, term, label) {
  anno <- read_input(annotation) |>
    mutate(ID = str_remove(ID, "\\(.*$"))
  gene <- anno |>
    filter(!is.na(.data[[term]]), !.data[[term]] %in% c("", "--")) |>
    select(all_of(c(term, "ID"))) |>
    distinct()
  name <- anno |>
    select(all_of(c(term, if (label == "GO") "name" else "Pathway_name"))) |>
    distinct() |>
    distinct(.data[[term]], .keep_all = TRUE)
  folder <- file.path(outdir, label)
  dir.create(folder, showWarnings = FALSE)
  # 无结果也保留标准列，方便报告与后续读取。
  empty <- tibble(
    ID = character(), Description = character(), setSize = integer(),
    enrichmentScore = numeric(), NES = numeric(), pvalue = numeric(),
    p.adjust = numeric(), qvalue = numeric(), rank = integer(),
    leading_edge = character(), core_enrichment = character()
  )
  result <- NULL
  if (!plot_only && length(genelist) >= 10 && length(unique(genelist)) > 1 &&
    length(intersect(names(genelist), gene[[2]])) >= 10) {
    set.seed(1)
    result <- GSEA(
      genelist,
      TERM2GENE = as.data.frame(gene),
      TERM2NAME = as.data.frame(name), pvalueCutoff = 1,
      scoreType = score_type, eps = 0, seed = TRUE, verbose = FALSE
    )
  }
  table <- if (plot_only) {
    read_input(file.path(outdir, paste0(label, "_GSEA_all.txt"))) |>
      mutate(across(all_of(c(
        "setSize", "enrichmentScore", "NES", "pvalue", "p.adjust", "qvalue", "rank"
      )), as.numeric))
  } else if (is.null(result)) {
    empty
  } else {
    as_tibble(result@result)
  }
  if (!plot_only) {
    table <- table |> arrange(p.adjust, pvalue)
  }
  if (!plot_only) {
    write_tsv(table, file.path(outdir, paste0(label, "_GSEA_all.txt")))
  }
  # enrichplot 按行名查找通路描述，读回 TSV 后必须恢复 ID 行名。
  table <- as.data.frame(table)
  rownames(table) <- table$ID
  if (!nrow(table)) {
    unlink(list.files(folder, pattern = "\\.(png|pdf)$", full.names = TRUE))
    empty_plot(
      outdir, paste0(label, "_GSEA_top10"),
      "No GSEA results: check gene-set overlap and rank variation"
    )
    return(invisible(NULL))
  }
  overview <- table |>
    filter(is.finite(NES)) |>
    slice_head(n = 10)
  if (plot_only) {
    # 从原表恢复绘图对象；校验 ES 与原表一致后才重画，绝不重算或覆盖原 P 值/NES。
    sets <- map(split(gene[[2]], gene[[1]]), unique)
    scores <- map_dbl(overview$ID, \(id) {
      gsea_es(genelist, sets[[id]], score_type = score_type)
    })
    error <- max(abs(scores - overview$enrichmentScore))
    message(label, ": ES reconstruction difference = ", format(error, digits = 4))
    if (!is.finite(error) || error > 1e-6) {
      stop(label, ": original ES does not match current rank/annotation; original figures preserved")
    }
    message(label, ": original ES verified; maximum difference = ", format(error, digits = 3))
    result <- new(
      "gseaResult",
      result = table, geneList = genelist, geneSets = sets,
      params = list(exponent = 1), organism = "UNKNOWN",
      setType = label, keytype = "UNKNOWN", readable = FALSE
    )
  }
  # 所有校验成功后清理旧曲线，保持前 10 项与报告一致。
  unlink(list.files(folder, pattern = "(\\.(png|pdf)$|_pages\\.txt$)", full.names = TRUE))
  draw_curve(
    result, overview$ID, paste(label, "GSEA top 10"), outdir,
    paste0(label, "_GSEA_top10"), TRUE
  )
  for (id in overview$ID) {
    row <- table |>
      filter(ID == id) |>
      slice_head(n = 1)
    title <- paste0(
      id, " ", row$Description, "\nNES = ", signif(row$NES, 3),
      "; BH adjusted P = ", signif(row$p.adjust, 3)
    )
    draw_curve(result, id, title, folder, str_replace_all(id, ":", "_"))
  }
}

run_gsea(args[2], "go", "GO")
run_gsea(args[3], "Pathway_id", "KEGG")
