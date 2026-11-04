#!/usr/bin/env Rscript
# WGCNA：构建 signed 共表达网络，输出模块、模块-表型关联和候选枢纽基因。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))
source(file.path(bin, "WGCNA_plots.R"))

args <- commandArgs(TRUE)
if (length(args) < 6) {
  stop("用法：Rscript WGCNA.R COUNT.txt sample_info.txt 输出目录 线程数 软阈值 表型表 [最大基因数] [--plot-only]")
}
counts_file <- args[1]
sample_file <- args[2]
outdir <- args[3]
threads <- as.integer(args[4])
power_input <- as.numeric(args[5])
trait_file <- args[6]
max_genes <- if (length(args) >= 7 && !startsWith(args[7], "--")) {
  as.integer(args[7])
} else {
  5000L
}
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# 只重绘缓存网络，不重复建网、软阈值检验或置换分析。
if ("--plot-only" %in% args) {
  suppressMessages(library(WGCNA))
  saved <- readRDS(file.path(outdir, "WGCNA.rds"))
  plot_wgcna_samples(saved$expression, outdir)
  fit <- read_tsv(
    file.path(outdir, "soft_threshold.txt"),
    name_repair = "minimal", show_col_types = FALSE
  )
  plot_wgcna_power(fit, saved$power, outdir)
  plot_wgcna_modules(saved$network, outdir)
  association_file <- file.path(outdir, "module_trait_association.txt")
  if (file.exists(association_file) && !is.null(saved$traits)) {
    MEs <- saved$network$MEs[, colnames(saved$network$MEs) != "MEgrey", drop = FALSE]
    association <- read_tsv(
      association_file,
      col_types = cols(module = col_character(), trait = col_character()),
      name_repair = "minimal"
    )
    plot_wgcna_association(
      association, MEs, saved$traits,
      saved$mode == "exploratory_small_n", outdir
    )
    loo <- file.path(outdir, "leave_one_out_association.txt")
    if (file.exists(loo)) {
      plot_wgcna_sensitivity(
        read_tsv(
          loo,
          col_types = cols(
            module = col_character(), trait = col_character(),
            omitted_sample = col_character()
          ),
          name_repair = "minimal"
        ),
        MEs, saved$traits, outdir
      )
    }
  }
  quit(save = "no", status = 0)
}

# 1. 推荐样本数不是软件的硬限制：6–14 个样本进入探索模式，少于 6 个跳过。
counts <- read_expression(counts_file)
samples <- read_groups(sample_file, colnames(counts))
status <- function(text) {
  write_lines(text, file.path(outdir, "WGCNA_status.txt"))
  message(text)
}
if (ncol(counts) < 6) {
  status(sprintf(
    "SKIPPED: %d samples; this workflow requires at least 6 independent samples for exploratory analysis.",
    ncol(counts)
  ))
  quit(save = "no", status = 0)
}
small_n <- ncol(counts) < 15
mode <- if (small_n) "exploratory_small_n" else "standard"
write_lines(
  c(
    paste("mode:", mode), paste("samples:", ncol(counts)),
    "WGCNA authors recommend at least 15 samples, preferably 20+.",
    "Small-n results are exploratory; no duplicated or simulated biological samples are introduced."
  ),
  file.path(outdir, "analysis_mode.txt")
)
options(error = function() {
  status("FAILED: inspect WGCNA.log / R error output")
  quit(save = "no", status = 1)
})
status("RUNNING")
suppressMessages(library(WGCNA))
suppressMessages(library(DESeq2))
cor <- WGCNA::cor
cor_type <- if (small_n) "pearson" else "bicor"
if (threads > 1) {
  allowWGCNAThreads(nThreads = threads)
} else {
  disableWGCNAThreads()
}
set.seed(1)

# 2. 只按表达/变异过滤，不使用差异基因筛选；VST 校正样本测序深度。
keep <- rowSums(counts >= 10) >= max(2, ceiling(ncol(counts) * 0.1))
counts <- counts[keep, , drop = FALSE]
if (nrow(counts) < 100) {
  status("SKIPPED: fewer than 100 expressed genes; not enough genes for this network workflow.")
  quit(save = "no", status = 0)
}
if (any(colSums(counts) == 0)) {
  stop("WGCNA 存在零计数样本")
}
col_data <- tibble(sample_id = colnames(counts), group = samples$group) |>
  column_to_rownames("sample_id")
dds <- DESeqDataSetFromMatrix(round(counts), col_data, ~ 1)
dds <- estimateSizeFactors(dds, type = "poscounts")
expression <- assay(varianceStabilizingTransformation(dds))
variation <- apply(expression, 1, mad)
keep <- is.finite(variation) & variation > 0
expression <- expression[keep, , drop = FALSE]
# 保留变异最大的至多 max_genes 个基因，控制常见服务器内存占用。
top_genes <- order(variation[keep], decreasing = TRUE) |> head(max_genes)
expression <- expression[top_genes, , drop = FALSE]
if (nrow(expression) < 100) {
  status("SKIPPED: fewer than 100 variable genes after VST/MAD filtering.")
  quit(save = "no", status = 0)
}
# WGCNA 要求行为样本、列为基因，与输入计数矩阵方向相反。
datExpr <- t(expression)
good <- goodSamplesGenes(datExpr)
write_tsv(
  tibble(sample_id = rownames(datExpr), included = good$goodSamples),
  file.path(outdir, "sample_QC.txt")
)
datExpr <- datExpr[good$goodSamples, good$goodGenes, drop = FALSE]
if (nrow(datExpr) < 6 || ncol(datExpr) < 100) {
  status("SKIPPED: fewer than 6 usable samples or 100 usable genes after QC.")
  quit(save = "no", status = 0)
}
sampleTree <- hclust(dist(datExpr), method = "average")
plot_wgcna_samples(datExpr, outdir)
write_tsv(
  tibble(sample_id = rownames(datExpr)[sampleTree$order]),
  file.path(outdir, "sample_clustering_order.txt")
)

# 3. 先看真实的软阈值诊断；无合格拟合时用样本数经验值，并记录选择依据。
powers <- c(1:10, seq(12, 30, 2))
sft <- pickSoftThreshold(
  datExpr,
  powerVector = powers, networkType = "signed",
  corFnc = if (small_n) "cor" else "bicor",
  corOptions = if (small_n) list(use = "p") else list(use = "p", maxPOutliers = 0.1),
  verbose = 1
)
fit <- sft$fitIndices
write_tsv(fit, file.path(outdir, "soft_threshold.txt"))
# 拟合度与负斜率共同筛选候选 power，无候选时按样本数回退。
eligible <- fit |>
  filter(is.finite(SFT.R.sq), SFT.R.sq >= 0.8, slope < 0) |>
  pull(Power)
fallback <- case_when(
  nrow(datExpr) < 20 ~ 18,
  nrow(datExpr) <= 30 ~ 16,
  nrow(datExpr) <= 40 ~ 14,
  TRUE ~ 12
)
power <- if (power_input > 0) {
  power_input
} else if (length(eligible)) {
  min(eligible)
} else {
  fallback
}
selection <- if (power_input > 0) {
  "user_supplied"
} else if (length(eligible)) {
  "scale_free_fit"
} else {
  "sample_size_fallback"
}
write_lines(
  c(
    paste("power:", power), paste("selection:", selection),
    paste("correlation:", cor_type),
    "Sample-size fallback is a heuristic, not evidence that scale-free topology has been achieved."
  ),
  file.path(outdir, "power_selection.txt")
)
plot_wgcna_power(fit, power, outdir)
write_lines(as.character(power), file.path(outdir, "selected_power.txt"))

# 4. signed 网络分模块；固定随机种子，保留原始基因 ID。
network <- blockwiseModules(
  datExpr,
  power = power, networkType = "signed",
  TOMType = "signed", corType = cor_type,
  maxPOutliers = 0.1, maxBlockSize = max_genes,
  minModuleSize = 30, mergeCutHeight = 0.25,
  pamRespectsDendro = FALSE, randomSeed = 1, verbose = 1
)
modules <- tibble(id = colnames(datExpr), module = network$colors)
write_tsv(modules, file.path(outdir, "gene_modules.txt"))
MEs <- orderMEs(network$MEs)
write_tsv(
  as_tibble(MEs, rownames = "sample_id", .name_repair = "minimal"),
  file.path(outdir, "module_eigengenes.txt")
)
plot_wgcna_modules(network, outdir)
# 先缓存网络，表型关联阶段中断后仍可单独重绘网络图。
saveRDS(
  list(network = network, expression = datExpr, power = power, mode = mode),
  file.path(outdir, "WGCNA.rds")
)
write_lines(capture.output(sessionInfo()), file.path(outdir, "sessionInfo.txt"))

# 5. 默认将分组转成 0/1 表型；自定义表型表必须以 sample_id 为第一列。
if (tolower(trait_file) != "none") {
  traits <- read_tsv(
    trait_file,
    col_types = cols(.default = col_character()), name_repair = "minimal"
  )
  trait_ids <- traits[[1]]
  traits <- suppressMessages(type_convert(traits[-1])) |> as.data.frame()
  rownames(traits) <- trait_ids
} else {
  traits <- tibble(sample_id = samples$sample_id, group = samples$group) |>
    column_to_rownames("sample_id")
}
if (!all(rownames(datExpr) %in% rownames(traits)) || anyDuplicated(rownames(traits))) {
  stop("表型表缺少样本或样本重复")
}
traits <- traits[rownames(datExpr), , drop = FALSE]
# 连续表型直接保留，分类表型按每个水平生成指示变量。
encoded <- imap(traits, \(values, name) {
  if (anyNA(values)) {
    stop(paste("表型不能含缺失值：", name))
  }
  if (is.numeric(values)) {
    return(as_tibble(set_names(list(values), name)))
  }
  levels <- sort(unique(as.character(values)))
  map(levels, \(level) as.numeric(values == level)) |>
    set_names(paste(name, levels, sep = "_")) |>
    as_tibble(.name_repair = "minimal")
})
traits <- as.matrix(bind_cols(encoded, .name_repair = "minimal"))
rownames(traits) <- rownames(datExpr)
# 常量表型没有相关性信息，编码后统一移除。
traits <- traits[, apply(traits, 2, var) > 0, drop = FALSE]
if (!ncol(traits)) {
  stop("所有表型均为常量，无法计算模块关联")
}
# grey 为未归属基因，不作为有效模块检验。
MEs <- MEs[, colnames(MEs) != "MEgrey", drop = FALSE]
if (!ncol(MEs)) {
  status(paste0("COMPLETED_", toupper(mode), ": all genes are grey; no supported modules were found."))
  quit(save = "no", status = 0)
}

# 6. 模块-表型统一使用 Pearson；小样本用置换 P 值，常规样本保留 t 近似。
correlation <- stats::cor(MEs, traits)
pvalues_t <- corPvalueStudent(correlation, nrow(datExpr))
pvalues <- pvalues_t
permutation_count <- rep(0L, ncol(traits))
if (small_n) {
  # n<=8 枚举排列，去掉相同标签排列；更大样本随机置换 1999 次。
  permutations <- function(x) {
    if (length(x) == 1L) {
      return(list(x))
    }
    unlist(lapply(seq_along(x), function(i) {
      lapply(permutations(x[-i]), function(rest) c(x[i], rest))
    }), recursive = FALSE)
  }
  indices <- if (nrow(datExpr) <= 8) {
    permutations(seq_len(nrow(datExpr)))
  } else {
    replicate(1999, sample.int(nrow(datExpr)), simplify = FALSE)
  }
  for (j in seq_len(ncol(traits))) {
    permuted <- vapply(indices, \(index) traits[index, j], numeric(nrow(datExpr)))
    if (nrow(datExpr) <= 8) {
      permuted <- unique(permuted, MARGIN = 2)
    }
    null <- stats::cor(MEs, permuted)
    exceed <- rowSums(abs(null) >= abs(correlation[, j]) - 1e-12, na.rm = TRUE)
    pvalues[, j] <- if (nrow(datExpr) <= 8) {
      exceed / ncol(permuted)
    } else {
      (exceed + 1) / (ncol(permuted) + 1)
    }
    permutation_count[j] <- ncol(permuted)
  }
}
# 将全部模块-表型检验合并校正，再恢复原矩阵的行列对应关系。
adjusted <- matrix(
  p.adjust(as.vector(pvalues), method = "BH"),
  nrow = nrow(pvalues), dimnames = dimnames(pvalues)
)
# expand_grid 先放 trait，使 module 仍按原来的矩阵列优先顺序展开。
results <- expand_grid(trait = colnames(correlation), module = rownames(correlation)) |>
  select(module, trait) |>
  mutate(
    correlation = as.vector(.env$correlation),
    pvalue = as.vector(.env$pvalues),
    padj = as.vector(.env$adjusted),
    pvalue_asymptotic = as.vector(.env$pvalues_t),
    pvalue_method = if (.env$small_n) "permutation_two_sided" else "Student_t",
    permutations = rep(.env$permutation_count, each = nrow(.env$correlation)),
    analysis_mode = .env$mode
  )
write_tsv(results, file.path(outdir, "module_trait_association.txt"))
write_tsv(
  as_tibble(traits, rownames = "sample_id", .name_repair = "minimal"),
  file.path(outdir, "traits_encoded.txt")
)
plot_wgcna_association(results, MEs, traits, small_n, outdir)

# 留一法只检验已识别模块的关联敏感性，不冒充独立样本或网络重复验证。
if (small_n) {
  diagnostics <- list()
  for (i in seq_len(nrow(datExpr))) {
    reduced <- moduleEigengenes(
      datExpr[-i, , drop = FALSE], network$colors,
      excludeGrey = TRUE
    )$eigengenes
    reduced <- reduced[, colnames(MEs), drop = FALSE]
    align <- sign(diag(stats::cor(reduced, MEs[-i, , drop = FALSE])))
    reduced <- sweep(reduced, 2, ifelse(align == 0, 1, align), "*")
    loo <- stats::cor(reduced, traits[-i, , drop = FALSE])
    item <- results |>
      select(module, trait, correlation) |>
      mutate(
        omitted_sample = rownames(datExpr)[i],
        correlation_leave_one_out = as.vector(loo)
      )
    diagnostics[[i]] <- item
  }
  diagnostics <- bind_rows(diagnostics)
  write_tsv(diagnostics, file.path(outdir, "leave_one_out_association.txt"))
  plot_wgcna_sensitivity(diagnostics, MEs, traits, outdir)
}

# 模块成员度 kME 供筛选候选枢纽基因，保留原基因 ID，避免名称歧义。
membership <- signedKME(
  datExpr, MEs,
  corFnc = if (small_n) "cor" else "bicor",
  corOptions = if (small_n) "use = 'p'" else "use = 'p', maxPOutliers = 0.1"
)
write_tsv(
  bind_cols(
    modules, as_tibble(membership, .name_repair = "minimal"),
    .name_repair = "minimal"
  ),
  file.path(outdir, "module_membership.txt")
)
saveRDS(
  list(
    network = network, expression = datExpr, traits = traits,
    power = power, mode = mode, selection = selection
  ),
  file.path(outdir, "WGCNA.rds")
)
write_lines(capture.output(sessionInfo()), file.path(outdir, "sessionInfo.txt"))
# 候选枢纽基因按所属模块的 kME 排序，不将其视为已验证的功能基因。
own_kme <- map_dbl(seq_len(nrow(modules)), \(i) {
  column <- paste0("kME", modules$module[i])
  if (column %in% names(membership)) membership[i, column] else NA_real_
})
hubs <- modules |>
  mutate(own_kME = own_kme) |>
  filter(module != "grey", is.finite(own_kME)) |>
  arrange(module, desc(own_kME)) |>
  group_by(module) |>
  mutate(rank_in_module = row_number()) |>
  ungroup()
write_tsv(
  filter(hubs, rank_in_module <= 10), file.path(outdir, "candidate_hub_genes.txt")
)
status(sprintf(
  "COMPLETED_%s: %d samples, %d genes, signed network, power=%s (%s).",
  toupper(mode), nrow(datExpr), ncol(datExpr), power, selection
))
