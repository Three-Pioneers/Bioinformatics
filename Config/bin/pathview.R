#!/usr/bin/env Rscript
# KEGG 通路图：复用原生通路模板，恢复最初的原生节点样式和色标。
bin <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)))
source(file.path(bin, "plot_utils.R"))

args <- commandArgs(TRUE)
plot_only <- "--plot-only" %in% args
args <- args[args != "--plot-only"]
if (length(args) != 6) {
  stop("用法：Rscript pathview.R Sig_genes_exprData.txt Sig_KEGG_Enrichment.txt KEGG_annotation gene_type species 输出目录 [--plot-only]")
}
genes <- read_input(args[1]) |>
  mutate(log2FoldChange = as.numeric(log2FoldChange))
pathways <- read_input(args[2])
annotation <- read_input(args[3])
gene_type <- args[4]
species <- args[5]
outdir <- normalizePath(args[6])
if (!nrow(genes) || !nrow(pathways)) {
  # 正常分析确定为空后才清旧图；离线重画保留已有结果。
  if (!plot_only) {
    unlink(Sys.glob(file.path(outdir, "*.pathway.png")))
    unlink(file.path(outdir, c("pathview_skipped.txt", "pathview_status.tsv")))
  }
  quit(save = "no", status = 0)
}
suppressMessages(library(pathview))

# SYMBOL 使用输入 ID 中的名称；KO 的多基因映射仍取平均 log2FC，沿用原规则。
if (gene_type == "SYMBOL") {
  changes <- genes |>
    transmute(id = str_replace(id, ".*\\(([^)]+)\\)$", "\\1"), log2FoldChange) |>
    deframe()
} else {
  mapping <- annotation |>
    mutate(ID = str_remove(ID, "\\(.*$")) |>
    distinct(ID, KO)
  mapping <- genes |>
    mutate(id = str_remove(id, "\\(.*$")) |>
    select(id, log2FoldChange) |>
    inner_join(mapping, by = c("id" = "ID"), relationship = "many-to-many") |>
    filter(!is.na(KO), str_detect(KO, "^K[0-9]+$"))
  if (!nrow(mapping)) {
    message("No usable KO mapping; pathview skipped")
    quit(save = "no", status = 0)
  }
  changes <- mapping |>
    filter(!is.na(log2FoldChange)) |>
    group_by(KO) |>
    summarise(log2FoldChange = mean(log2FoldChange), .groups = "drop") |>
    deframe()
  species <- "ko"
  gene_type <- "KEGG"
}
ids <- unique(pathways$ID)
numbers <- str_remove(ids, "^[A-Za-z]+")
prefixes <- paste0(species, numbers)
cache_files <- unlist(map(prefixes, \(prefix) file.path(outdir, paste0(prefix, c(".xml", ".png")))))
cache_size <- file.info(cache_files)$size
missing_cache <- cache_files[is.na(cache_size) | cache_size <= 0]
# 只重画时先核对全部模板；缺失即退出，保持现有 PNG、状态表及统计表原样。
if (plot_only && length(missing_cache)) {
  stop("离线重画缺少缓存模板：", paste(basename(missing_cache), collapse = ", "))
}

# 完整缓存直接使用本地文件；仅正常分析且模板缺失时检查下载连接。
if (!plot_only && length(missing_cache)) {
  options(timeout = 20)
  probe <- tempfile()
  available <- tryCatch({
    suppressWarnings(download.file("https://rest.kegg.jp/info/pathway", probe,
      quiet = TRUE, method = "libcurl"))
    file.exists(probe) && file.info(probe)$size > 0
  }, error = function(e) {
    message("KEGG connection: ", conditionMessage(e))
    FALSE
  })
  unlink(probe)
  if (!available) {
    writeLines("KEGG REST unavailable: pathway images skipped; enrichment tables are unchanged.",
      file.path(outdir, "pathview_skipped.txt"))
    quit(save = "no", status = 0)
  }
}
if (!plot_only) {
  unlink(file.path(outdir, c("pathview_skipped.txt", "pathview_status.tsv")))
  options(timeout = 120)
}

# 沿用最初版本的绿色、灰色和红色及 pathview 原生图例。
color_low <- "green"
color_mid <- "gray"
color_high <- "red"

render_pathway <- function(number, prefix, use_cache) {
  work <- tempfile("pathview_render_")
  dir.create(work)
  oldwd <- getwd()
  on.exit({ setwd(oldwd); unlink(work, recursive = TRUE) }, add = TRUE)
  templates <- paste0(prefix, c(".xml", ".png"))
  if (use_cache) {
    for (name in templates) {
      source <- file.path(outdir, name)
      if (file.exists(source)) file.copy(source, file.path(work, name), overwrite = TRUE)
    }
  }
  setwd(work)
  pathview(gene.data = changes, pathway.id = number, species = species,
    gene.idtype = gene_type, kegg.dir = work, out.suffix = "pathway", node.sum = "mean",
    kegg.native = TRUE,
    low = list(gene = color_low), mid = list(gene = color_mid), high = list(gene = color_high))
  rendered <- file.path(work, paste0(prefix, ".pathway.png"))
  if (!file.exists(rendered) || file.info(rendered)$size <= 0) {
    stop("No pathway image; inspect cached template and ID mapping")
  }
  temporary <- tempfile(paste0(".", prefix, "_native_"), tmpdir = outdir, fileext = ".png")
  on.exit(unlink(temporary), add = TRUE)
  if (!file.copy(rendered, temporary, overwrite = TRUE)) stop("Cannot stage native pathway image")
  output <- file.path(outdir, paste0(prefix, ".pathway.png"))
  # 新图完整生成后再原子替换现有图；失败时保留原图。
  if (!file.rename(temporary, output)) stop("Cannot replace pathway image: ", output)
  if (!plot_only) {
    for (name in templates) {
      source <- file.path(work, name)
      if (file.exists(source) && file.info(source)$size > 0) {
        file.copy(source, file.path(outdir, name), overwrite = TRUE)
      }
    }
  }
  invisible(output)
}

status <- list()
for (i in seq_along(ids)) {
  success <- FALSE
  reason <- ""
  max_attempts <- if (plot_only) 1L else 3L
  for (attempt in seq_len(max_attempts)) {
    reason <- tryCatch({
      render_pathway(numbers[i], prefixes[i], use_cache = plot_only || attempt == 1L)
      success <- TRUE
      ""
    }, error = function(e) conditionMessage(e))
    if (success) break
    message(sprintf("Pathview %s attempt %d/%d failed: %s", ids[i], attempt, max_attempts, reason))
    if (attempt < max_attempts) Sys.sleep(2)
  }
  if (plot_only && !success) stop("Offline pathway redraw failed for ", ids[i], ": ", reason)
  if (!plot_only) {
    status[[length(status) + 1L]] <- tibble(ID = ids[i], template = prefixes[i], attempts = attempt,
      status = if (success) "success" else "failed", reason = if (success) "" else reason)
    if (!success) {
      tibble(ID = ids[i], reason = reason) |>
        write_tsv(file.path(outdir, "pathview_skipped.txt"), append = TRUE, col_names = FALSE)
    }
  }
}
if (!plot_only) {
  bind_rows(status) |> write_tsv(file.path(outdir, "pathview_status.tsv"))
  if (any(vapply(status, function(row) row$status == "failed", logical(1)))) {
    stop("Some KEGG pathway images failed after 3 attempts; see pathview_status.tsv")
  }
  # 当前通路全部成功后，再移除已不属于本次结果集合的旧图。
  obsolete <- setdiff(Sys.glob(file.path(outdir, "*.pathway.png")),
    file.path(outdir, paste0(prefixes, ".pathway.png")))
  unlink(obsolete)
}
