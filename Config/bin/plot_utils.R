# 共用绘图与输入函数：尺寸用 mm，PDF 为矢量，PNG 为 600 dpi。
suppressMessages(library(tidyverse))

# 横轴文字统一水平；长名称通过换行和画布留白保持可读。
# 样本、组别等分类图例置顶且不加底框；连续色标单独靠右上。
paper_theme <- function(base_size = 11) {
  theme_classic(base_size = base_size, base_family = "sans") +
    theme(
      axis.text = element_text(size = base_size - 1, color = "#39485A"),
      axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 1, lineheight = 0.95),
      axis.title.x = element_text(angle = 0, margin = margin(t = 8)),
      axis.title.y = element_text(margin = margin(r = 8)),
      axis.line = element_line(linewidth = 0.35, color = "#536274"),
      axis.ticks = element_line(linewidth = 0.3, color = "#748294"),
      legend.position = "top", legend.direction = "horizontal",
      legend.box = "horizontal", legend.justification = "center",
      legend.justification.right = "top",
      legend.title = element_text(size = base_size - 0.5, face = "bold", color = "#263445"),
      legend.text = element_text(size = base_size - 1, color = "#46566A", lineheight = 1.05),
      legend.key = element_blank(),
      legend.key.height = grid::unit(4.4, "mm"),
      legend.key.width = grid::unit(5, "mm"),
      legend.spacing.x = grid::unit(3, "mm"),
      legend.spacing.y = grid::unit(2, "mm"),
      legend.background = element_blank(), legend.box.background = element_blank(),
      legend.margin = margin(4, 6, 4, 6),
      legend.box.margin = margin(5, 0, 0, 0),
      plot.title = element_text(size = base_size + 1, face = "bold", color = "#263445", hjust = 0),
      plot.subtitle = element_text(size = base_size - 0.5, color = "#65758A"),
      strip.background = element_blank(),
      strip.text = element_text(face = "bold", color = "#39485A"),
      plot.margin = margin(5, 7, 6, 5)
    )
}

theme_set(paper_theme())

direction_colors <- c(Up = "#D55E00", Down = "#0072B2", No = "#B9BEC6")

# 组别按名称排序配色；组数增加时自动扩展。
group_colors <- function(groups) {
  levels <- sort(unique(as.character(groups)))
  base <- c(
    "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00",
    "#56B4E9", "#6A51A3", "#666666"
  )
  colors <- if (length(levels) <= length(base)) {
    base[seq_along(levels)]
  } else {
    grDevices::hcl.colors(length(levels), "Dark 3")
  }
  setNames(colors, levels)
}

# 固定使用 COUNT.txt、FPKM.txt、TPM.txt，文件名直接作为图表标签。
matrix_label <- function(path) {
  tools::file_path_sans_ext(basename(path))
}

read_input <- function(path) {
  # 仅将 NA 文本视为缺失值；空字符串和字段内引号原样保留。
  read_tsv(path,
    col_types = cols(.default = col_character()),
    name_repair = "minimal", quote = "", na = "NA"
  )
}

# 表达表固定为 id + 样本列；id 可以是原始 ID 或 id(name)。
read_expression <- function(path) {
  read_tsv(path,
    col_types = cols(id = col_character(), .default = col_double()),
    name_repair = "minimal", quote = ""
  ) |>
    column_to_rownames("id") |>
    as.matrix()
}

# 按表达矩阵中的样本顺序匹配分组，避免表格行顺序影响结果。
read_groups <- function(path, ids) {
  groups <- read_tsv(path,
    col_types = cols(sample_id = col_character()),
    name_repair = "minimal"
  )
  groups <- as.data.frame(groups[match(ids, groups$sample_id), , drop = FALSE])
  rownames(groups) <- groups$sample_id
  groups
}

gene_labels <- function(ids) {
  # 优先显示括号内名称；重名时回退到完整 ID，保证可区分。
  labels <- str_replace(ids, ".*\\(([^()]*)\\)$", "\\1")
  repeated <- duplicated(labels) | duplicated(labels, fromLast = TRUE)
  labels[repeated] <- ids[repeated]
  labels
}

# 名称完整保留，长名称按字符换行；分页优先于把字体缩得很小。
wrap_labels <- function(values, width = 22) {
  map_chr(as.character(values), \(value) {
    if (is.na(value)) {
      return("NA")
    }
    if (nchar(value) <= width) {
      return(value)
    }
    if (str_detect(value, "\\s")) {
      return(str_wrap(value, width))
    }
    starts <- seq(1, nchar(value), by = width)
    paste(str_sub(value, starts, starts + width - 1), collapse = "\n")
  })
}

# 可均衡各页条目，避免最后一页只有一两个模块而被拉得过大。
page_indices <- function(n, size = 20, balanced = FALSE) {
  if (!n) {
    return(list())
  }
  pages <- ceiling(n / size)
  split(seq_len(n), if (balanced) {
    ceiling(seq_len(n) * pages / n)
  } else {
    ceiling(seq_len(n) / size)
  })
}

# 分类图例每行至多 4 项，色键使用实色，避免透明度降低辨识度。
group_guide <- function(groups) {
  guide_legend(
    title.position = "left", direction = "horizontal",
    nrow = max(1, ceiling(length(unique(groups)) / 4)),
    byrow = TRUE, override.aes = list(alpha = 1, size = 3)
  )
}

# 连续数值与分类图例分开放置，色标固定在绘图区右侧并向上对齐。
upper_colorbar <- function(height = 32) {
  guide_colorbar(
    position = "right", direction = "vertical", title.position = "top", title.hjust = 0.5,
    barwidth = grid::unit(3.5, "mm"), barheight = grid::unit(height, "mm"),
    ticks.colour = "white", frame.colour = NA
  )
}

# 显式指定设备和白底；保留可编辑的 PDF 文本与线条。
save_figure <- function(plot, outdir, stem, width = 180, height = 120) {
  save_plot_pages(list(plot), outdir, stem, width, height)
}

save_base_plot <- function(draw, outdir, stem, width = 180, height = 120) {
  save_base_pages(list(draw), outdir, stem, width, height)
}

save_plot_pages <- function(plots, outdir, stem, width = 180, height = 125) {
  draws <- map(plots, \(plot) {
    # 固定每次迭代的图对象，供稍后生成 PDF 和 PNG 时调用。
    force(plot)
    function() print(plot)
  })
  save_base_pages(draws, outdir, stem, width, height)
}

save_base_pages <- function(draws, outdir, stem, width = 180, height = 125) {
  dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
  # 清理本脚本上次多出来的分页图片，不能把旧页误认为当前输出。
  unlink(Sys.glob(file.path(outdir, paste0(stem, "_page*.png"))))
  target <- file.path(outdir, paste0(stem, ".pdf"))
  if (capabilities("cairo")) {
    cairo_pdf(target,
      width = width / 25.4, height = height / 25.4,
      family = "sans", pointsize = 11
    )
  } else {
    pdf(target,
      width = width / 25.4, height = height / 25.4,
      family = "Helvetica", pointsize = 11
    )
  }
  # 即使绘图报错也关闭设备，避免后续图形写入错误的文件。
  tryCatch(for (draw in draws) draw(), finally = dev.off())
  for (i in seq_along(draws)) {
    suffix <- if (i == 1) "" else sprintf("_page%03d", i)
    png(file.path(outdir, paste0(stem, suffix, ".png")),
      width = width, height = height, units = "mm", res = 600, pointsize = 11,
      type = if (capabilities("cairo")) "cairo" else "Xlib"
    )
    tryCatch(draws[[i]](), finally = dev.off())
  }
  unlink(file.path(outdir, paste0(stem, "_pages.txt")))
}

empty_plot <- function(outdir, stem, label = "No results available") {
  plot <- ggplot() +
    annotate("text",
      x = 0, y = 0, label = str_wrap(label, 55),
      size = 3.5, color = "#666666"
    ) +
    theme_void()
  save_figure(plot, outdir, stem, height = 90)
}
