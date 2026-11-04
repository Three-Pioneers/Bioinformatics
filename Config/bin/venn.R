#!/usr/bin/env Rscript
# 差异基因交集：2–5 个比较画 Venn 图，更多比较画 UpSet 图。
args <- commandArgs(TRUE)
if (length(args) < 2) {
  stop("用法：Rscript venn.R venn_input.txt 输出目录 [比较1,比较2,...]")
}
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))

data <- read_input(args[1])
outdir <- args[2]
comparisons <- if (length(args) >= 3) {
  strsplit(args[3], ",", fixed = TRUE)[[1]]
} else {
  unique(data$group)
}
sets <- map(comparisons, \(name) unique(data$id[data$group == name])) |>
  set_names(comparisons)
ids <- unique(as.character(unlist(sets)))

# 总是保留完整成员表；超过 5 个比较改画常用的 UpSet 交集图。
membership <- tibble(id = ids)
for (name in comparisons) {
  membership[[name]] <- ids %in% sets[[name]]
}
write_tsv(membership, file.path(outdir, "venn_membership.txt"))
if (!length(ids) || length(sets) < 2) {
  empty_plot(
    outdir, "venn", if (!length(ids)) "No significant genes" else
      "Use venn_membership.txt for this number of comparisons"
  )
  quit(save = "no", status = 0)
}

if (length(sets) > 5) {
  suppressMessages(library(ComplexHeatmap))
  combinations <- make_comb_mat(sets)
  counts <- comb_size(combinations)
  write_tsv(
    tibble(combination = names(counts), genes = as.integer(counts)),
    file.path(outdir, "venn_output.txt")
  )
  # 完整交集数量写入表格，图中仅显示成员最多的 30 个交集。
  selected <- head(order(counts, decreasing = TRUE), 30)
  combinations <- combinations[, selected, drop = FALSE]
  save_base_plot(function() {
    draw(UpSet(
      combinations, comb_order = seq_along(selected),
      row_names_gp = grid::gpar(fontsize = 9, col = "#334155"),
      column_names_rot = 0,
      top_annotation = upset_top_annotation(
        combinations, annotation_name_gp = grid::gpar(fontsize = 10)
      ),
      right_annotation = upset_right_annotation(
        combinations, annotation_name_gp = grid::gpar(fontsize = 10)
      )
    ))
  }, outdir, "venn", width = 180, height = max(125, 65 + length(sets) * 5))
  quit(save = "no", status = 0)
}

suppressMessages(library(VennDiagram))
venn_plot <- venn.diagram(
  x = sets, category.names = wrap_labels(names(sets), 24), filename = NULL,
  fill = unname(group_colors(names(sets))[names(sets)]), alpha = 0.5, scaled = FALSE,
  cex = 1, cat.cex = 0.9, cat.fontface = "bold",
  fontfamily = "sans", cat.fontfamily = "sans",
  disable.logging = TRUE
)
save_base_plot(
  function() grid::grid.draw(venn_plot), outdir, "venn", width = 170, height = 145
)

partitions <- get.venn.partitions(sets) |>
  mutate(values = map_chr(.data[["..values.."]], \(x) paste(x, collapse = ", "))) |>
  select(-all_of("..values.."))
write_tsv(partitions, file.path(outdir, "venn_output.txt"))
