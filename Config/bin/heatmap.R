#!/usr/bin/env Rscript
# 候选基因热图：CPM/log2、Z 分数、行列聚类后分页绘制。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))
suppressMessages(library(pheatmap))

args <- commandArgs(TRUE)
if (length(args) != 3) {
  stop("用法：Rscript heatmap.R heatmap_input.txt sample_info.txt 输出目录")
}
# 固定输入为 id + 样本计数列；COUNT.txt 与候选表位于同一比较目录。
data <- read_expression(args[1])
groups <- read_groups(args[2], colnames(data))
outdir <- args[3]

# CPM 分母必须来自完整 COUNT，不能来自选出的 50 个基因。
if (nrow(data)) {
  full <- read_expression(file.path(outdir, "COUNT.txt"))
  data <- log2(sweep(data, 2, pmax(colSums(full)[colnames(data)], 1) / 1e6, "/") + 1)
  variable <- tibble(id = rownames(data), variance = apply(data, 1, var)) |>
    filter(is.finite(variance), variance > 0) |>
    pull(id)
  data <- data[variable, , drop = FALSE]
}
if (!nrow(data)) {
  empty_plot(outdir, "heatmap", "No variable significant genes")
  quit(save = "no", status = 0)
}

# 每个基因按全部样本标准化为行 Z 分数，仅用于比较相对表达模式。
# 导出未经色阶截断的数值，热图色阶限制不影响该表。
z <- t(scale(t(data)))
as.data.frame(z, check.names = FALSE) |>
  rownames_to_column("id") |>
  write_tsv(file.path(outdir, "heatmap_row_zscores.txt"))

palette <- group_colors(groups$group)
# 全体样本共同计算 Z 分数/列聚类，再按同一顺序分页，防止不同页数值尺度改变。
if (ncol(z) > 1) {
  z <- z[, hclust(dist(t(z)))$order, drop = FALSE]
}
if (nrow(z) > 1) {
  z <- z[hclust(dist(z))$order, , drop = FALSE]
}
labels <- wrap_labels(gene_labels(rownames(z)), 24)
row_pages <- page_indices(nrow(z), 25)
column_pages <- page_indices(ncol(z), 15)
pages <- expand_grid(row = seq_along(row_pages), column = seq_along(column_pages))
comparison <- basename(normalizePath(outdir))
comparison <- if (grepl("_vs_", comparison, fixed = TRUE)) {
  gsub("_vs_", " vs ", comparison, fixed = TRUE)
} else {
  "Differential expression"
}
# 色彩沿用火山图；热图的正负表示同一基因在各样本中的相对表达，不代表差异方向。
expression_colors <- colorRampPalette(c(direction_colors[["Down"]], "#F7F8FA", direction_colors[["Up"]]))(100)
group_counts <- table(factor(groups$group, levels = names(palette)))
group_labels <- paste0(names(palette), " (n = ", as.integer(group_counts), ")")
# 顶部保留组别图例，主图右侧为竖向连续色标预留窄区；多组时换行。
legend_rows <- split(seq_along(group_labels), ceiling(seq_along(group_labels) / 3))
header_mm <- 18 + 6 * length(legend_rows)
footer_mm <- 10
draws <- map2(pages$row, pages$column, \(row, column) {
  rows <- row_pages[[row]]
  columns <- column_pages[[column]]
  selected <- colnames(z)[columns]
  annotation <- tibble(sample_id = selected) |>
    left_join(select(as_tibble(groups), sample_id, Group = group), by = "sample_id") |>
    column_to_rownames("sample_id")
  annotation_colors <- list(Group = palette[unique(annotation$Group)])
  function() {
    display <- z[rows, columns, drop = FALSE]
    # 仅截断显示色阶，保留矩阵维度与原始 Z 分数表。
    display[] <- pmax(-3, pmin(3, display))
    # pheatmap 的 print 不会自动翻页，必须显式新建页面，避免 PDF 多页相互覆盖。
    grid::grid.newpage()
    # 组别保持顶部；数值色条在主图右上方，均不加背景框。
    grid::grid.text(comparison, x = grid::unit(5, "mm"),
      y = grid::unit(1, "npc") - grid::unit(4, "mm"), just = c("left", "top"),
      gp = grid::gpar(fontsize = 13, fontface = "bold", col = "#263445"))
    grid::grid.text("Differential gene expression", x = grid::unit(5, "mm"),
      y = grid::unit(1, "npc") - grid::unit(11, "mm"), just = c("left", "top"),
      gp = grid::gpar(fontsize = 10, col = "#677785"))
    page <- which(pages$row == row & pages$column == column)
    grid::grid.text(paste0("Page ", page, " / ", nrow(pages)),
      x = grid::unit(1, "npc") - grid::unit(5, "mm"),
      y = grid::unit(1, "npc") - grid::unit(5, "mm"), just = c("right", "top"),
      gp = grid::gpar(fontsize = 8.5, col = "#73818C"))
    for (line in seq_along(legend_rows)) {
      entries <- legend_rows[[line]]
      widths <- vapply(entries, function(i) {
        grid::convertWidth(grid::grobWidth(grid::textGrob(group_labels[i],
          gp = grid::gpar(fontsize = 9.5))), "mm", valueOnly = TRUE) + 10
      }, numeric(1))
      legend_region <- grid::convertWidth(grid::unit(1, "npc"), "mm", valueOnly = TRUE) - 60
      start <- max(5, (legend_region - sum(widths)) / 2)
      for (j in seq_along(entries)) {
        i <- entries[j]
        x <- start + sum(widths[seq_len(j - 1)])
        y <- grid::unit(1, "npc") - grid::unit(18 + 6 * (line - 1), "mm")
        grid::grid.roundrect(x = grid::unit(x, "mm"), y = y,
          width = grid::unit(3.5, "mm"), height = grid::unit(3.5, "mm"),
          r = grid::unit(0.6, "mm"), just = c("left", "center"),
          gp = grid::gpar(fill = unname(palette[i]), col = NA))
        grid::grid.text(group_labels[i], x = grid::unit(x + 5, "mm"), y = y,
          just = c("left", "center"), gp = grid::gpar(fontsize = 9.5, col = "#40515E"))
      }
    }
    body_height <- grid::unit(1, "npc") - grid::unit(header_mm + footer_mm, "mm")
    body_width <- grid::unit(1, "npc") - grid::unit(34, "mm")
    grid::pushViewport(grid::viewport(
      x = grid::unit(4, "mm") + body_width / 2,
      y = grid::unit(footer_mm, "mm") + body_height / 2,
      width = body_width, height = body_height))
    heatmap <- pheatmap(
      display,
      color = expression_colors,
      breaks = seq(-3, 3, length.out = 101), border_color = NA,
      cluster_rows = FALSE, cluster_cols = FALSE, annotation_col = annotation,
      annotation_colors = annotation_colors, annotation_legend = FALSE,
      annotation_names_col = FALSE, legend = FALSE,
      labels_row = labels[rows],
      labels_col = wrap_labels(selected, if (length(selected) > 8) 10 else 18),
      fontsize = 9.5, fontsize_row = 9, fontsize_col = 9, angle_col = "0",
      silent = TRUE
    )
    table <- heatmap$gtable
    for (name in c("row_names", "col_names")) {
      index <- which(table$layout$name == name)
      if (length(index)) table$grobs[[index]]$gp$col <- "#40515E"
    }
    grid::grid.draw(table)
    # 读取矩阵在 gtable 中的真实上边界，让色条与矩阵顶部对齐。
    matrix_row <- table$layout$t[table$layout$name == "matrix"][1]
    matrix_top_offset <- if (matrix_row > 1) {
      grid::convertHeight(sum(table$heights[seq_len(matrix_row - 1)]), "mm", valueOnly = TRUE)
    } else 0
    grid::popViewport()
    # 竖向 Z 分数色条固定在右上方，所有分页保持 -3 至 3 的相同尺度。
    bar_height <- 32
    bar_center <- grid::unit(1, "npc") - grid::unit(16, "mm")
    bar_top <- grid::unit(1, "npc") - grid::unit(header_mm + matrix_top_offset, "mm")
    bar_bottom <- bar_top - grid::unit(bar_height, "mm")
    grid::grid.text("Row Z-score", x = bar_center,
      y = bar_top + grid::unit(4, "mm"), just = c("center", "center"),
      gp = grid::gpar(fontsize = 9, fontface = "bold", col = "#40515E"))
    grid::grid.raster(as.raster(matrix(rev(expression_colors), ncol = 1)),
      x = bar_center, y = bar_top - grid::unit(bar_height / 2, "mm"),
      width = grid::unit(3.5, "mm"), height = grid::unit(bar_height, "mm"),
      interpolate = FALSE)
    for (value in c(-3, 0, 3)) {
      grid::grid.text(as.character(value), x = bar_center + grid::unit(3.5, "mm"),
        y = bar_bottom + grid::unit((value + 3) / 6 * bar_height, "mm"),
        just = c("left", "center"),
        gp = grid::gpar(fontsize = 8, col = "#677785"))
    }
    grid::grid.text("Colors show expression relative to each gene's mean: log2(CPM + 1).",
      x = grid::unit(5, "mm"), y = grid::unit(3, "mm"), just = c("left", "bottom"),
      gp = grid::gpar(fontsize = 8, col = "#73818C"))
  }
})
line_counts <- map_int(strsplit(labels, "\n", fixed = TRUE), length)
row_lines <- max(map_int(row_pages, \(indices) sum(line_counts[indices])))
save_base_pages(
  draws, outdir, "heatmap", width = max(180, 70 + min(ncol(z), 15) * 12),
  height = max(145, header_mm + footer_mm + 25 + row_lines * 3.8)
)
