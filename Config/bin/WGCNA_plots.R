# WGCNA 绘图：复用已有网络和结果表调整版式。
# 由 WGCNA.R 在 plot_utils.R 后加载，统一使用共享主题与分页输出。

# 将 hclust 转成 ggplot2 线段；叶序与树一致。
dendrogram_segments <- function(tree) {
  recurse <- function(node, y) {
    if (is.leaf(node)) {
      return(list(y = y + 1, center = y + 1, segments = NULL))
    }
    left <- node[[1]]
    right <- node[[2]]
    l <- recurse(left, y)
    r <- recurse(right, l$y)
    height <- attr(node, "height")
    segments <- rbind(
      l$segments, r$segments,
      data.frame(x = height, y = l$center, xend = height, yend = r$center),
      data.frame(
        x = attr(left, "height"), y = l$center, xend = height, yend = l$center
      ),
      data.frame(
        x = attr(right, "height"), y = r$center, xend = height, yend = r$center
      )
    )
    list(y = r$y, center = (l$center + r$center) / 2, segments = segments)
  }
  recurse(as.dendrogram(tree), 0)$segments
}

# 样本树按叶序分页，保留所有样本名和同一棵树的分枝。
plot_wgcna_samples <- function(datExpr, outdir) {
  tree <- hclust(dist(datExpr), method = "average")
  segments <- dendrogram_segments(tree) |>
    mutate(y = -y, yend = -yend)
  labels <- wrap_labels(rownames(datExpr)[tree$order], 30)
  label_lines <- max(lengths(strsplit(labels, "\n", fixed = TRUE)))
  pages <- page_indices(nrow(datExpr), max(12, floor(36 / label_lines)))
  plots <- map(seq_along(pages), \(i) {
    rows <- pages[[i]]
    ggplot() +
      geom_segment(
        data = segments, aes(x, y, xend = xend, yend = yend), linewidth = 0.3
      ) +
      geom_text(
        data = tibble(y = -rows, label = labels[rows]),
        aes(x = 0, y = y, label = label), hjust = 1, size = 3.2, lineheight = 0.9
      ) +
      coord_cartesian(ylim = c(-max(rows) - 0.5, -min(rows) + 0.5)) +
      scale_x_continuous(
        expand = expansion(mult = c(0.45, 0.02)),
        breaks = scales::pretty_breaks()(c(0, max(segments$x)))
      ) +
      labs(
        x = "Expression distance", y = NULL,
        title = if (length(pages) == 1) {
          "Sample clustering"
        } else {
          sprintf("Sample clustering (%d/%d)", i, length(pages))
        }
      ) +
      theme(
        axis.text.y = element_blank(), axis.ticks.y = element_blank(),
        axis.line.y = element_blank()
      )
  })
  save_plot_pages(
    plots, outdir, "sample_clustering",
    width = 180,
    height = max(85, 30 + min(nrow(datExpr), length(pages[[1]])) * 3.5 * label_lines)
  )
}

# 左侧显示实际拟合，右侧显示平均连通度。
plot_wgcna_power <- function(fit, power, outdir) {
  fit <- fit |> mutate(signed_fit = -sign(slope) * SFT.R.sq)
  p1 <- ggplot(fit, aes(Power, signed_fit)) +
    geom_line(color = "#0072B2") +
    geom_point(color = "#0072B2", size = 1.8) +
    geom_hline(yintercept = 0.8, color = "#D55E00", linetype = 2) +
    geom_vline(xintercept = power, color = "#666666", linetype = 3) +
    labs(x = "Soft power", y = expression("Signed scale-free fit (" * R^2 * ")"))
  p2 <- ggplot(fit, aes(Power, mean.k.)) +
    geom_line(color = "#0072B2") +
    geom_point(color = "#0072B2", size = 1.8) +
    geom_vline(xintercept = power, color = "#666666", linetype = 3) +
    labs(x = "Soft power", y = "Mean connectivity")
  save_figure(
    cowplot::plot_grid(p1, p2, nrow = 1), outdir, "soft_threshold",
    width = 180, height = 90
  )
}

# 每个网络分块单独一页，保留模块颜色。
plot_wgcna_modules <- function(network, outdir) {
  draws <- map(seq_along(network$dendrograms), \(block) {
    # 每个闭包固定当前分块，导出时才执行实际绘图。
    force(block)
    function() {
      par(bty = "n", cex = 0.95)
      plotDendroAndColors(
        network$dendrograms[[block]],
        network$colors[network$blockGenes[[block]]],
        "Module",
        dendroLabels = FALSE, hang = 0.03,
        addGuide = TRUE, guideHang = 0.05
      )
    }
  })
  save_base_pages(draws, outdir, "gene_dendrogram_modules", width = 180, height = 100)
}

# 模块和表型较多时分页，数值为相关系数及 BH 校正值。
plot_wgcna_association <- function(results, MEs, traits, small_n, outdir) {
  # 均衡拆分模块与表型，减少最后一页仅剩少量格子的情况。
  module_pages <- page_indices(ncol(MEs), 10, balanced = TRUE)
  trait_pages <- page_indices(ncol(traits), 4, balanced = TRUE)
  pages <- expand_grid(
    module_page = seq_along(module_pages), trait_page = seq_along(trait_pages)
  )
  plots <- map2(pages$module_page, pages$trait_page, \(m, t) {
    rows <- module_pages[[m]]
    columns <- trait_pages[[t]]
    plot_data <- results |>
      filter(module %in% colnames(MEs)[rows], trait %in% colnames(traits)[columns]) |>
      mutate(
        module = factor(module, levels = rev(colnames(MEs)[rows])),
        label = sprintf("%.2f\nq=%.2g", correlation, padj)
      )
    ggplot(plot_data, aes(trait, module, fill = correlation)) +
      geom_tile(color = "white", linewidth = 0.3) +
      geom_text(aes(label = label), size = 3.3, lineheight = 0.95) +
      scale_fill_gradient2(
        low = "#2166AC", mid = "white", high = "#B2182B",
        limits = c(-1, 1), name = "Pearson r"
      ) +
      guides(fill = upper_colorbar()) +
      scale_x_discrete(labels = \(x) wrap_labels(str_remove(x, "^group_"), 18)) +
      labs(
        x = NULL, y = NULL, title = "Module–trait association",
        subtitle = if (small_n) {
          "Exploratory: permutation P values, BH correction"
        } else {
          "BH adjusted P values"
        }
      ) +
      theme(
        axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 1, lineheight = 0.95),
        axis.line = element_blank(), axis.ticks = element_blank()
      )
  })
  save_plot_pages(
    plots, outdir, "module_trait_heatmap",
    width = 180,
    height = max(85, 45 + max(lengths(module_pages)) * 9)
  )
}

# 固定模块的留一法关联敏感性，不重新建网。
plot_wgcna_sensitivity <- function(diagnostics, MEs, traits, outdir) {
  module_pages <- page_indices(ncol(MEs), 4, balanced = TRUE)
  trait_pages <- page_indices(ncol(traits), 4, balanced = TRUE)
  pages <- expand_grid(
    module_page = seq_along(module_pages), trait_page = seq_along(trait_pages)
  )
  plots <- map2(pages$module_page, pages$trait_page, \(m, t) {
    selected <- diagnostics |>
      filter(
        module %in% colnames(MEs)[module_pages[[m]]],
        trait %in% colnames(traits)[trait_pages[[t]]]
      )
    ggplot(selected, aes(trait, correlation_leave_one_out, color = module)) +
      geom_hline(yintercept = 0, linetype = 2, color = "#999999", linewidth = 0.3) +
      geom_point(
        position = position_jitter(width = 0.1, height = 0, seed = 1), size = 1.5
      ) +
      facet_wrap(~ module, ncol = 2) +
      coord_cartesian(ylim = c(-1, 1)) +
      scale_x_discrete(labels = \(x) wrap_labels(str_remove(x, "^group_"), 18)) +
      labs(
        x = NULL, y = "Leave-one-out Pearson r", title = "Association sensitivity",
        subtitle = "Fixed modules; one sample omitted at a time"
      ) +
      theme(legend.position = "none", axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 1, lineheight = 0.95))
  })
  save_plot_pages(
    plots, outdir, "leave_one_out_association",
    width = 180,
    height = 35 + ceiling(min(4, ncol(MEs)) / 2) * 48
  )
}
