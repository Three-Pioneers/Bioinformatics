#!/usr/bin/env Rscript
# 报告渲染：解析 --infile/--outfile/--format，调用 rmarkdown 生成 HTML。
args <- commandArgs(TRUE)
if (!length(args) || "--help" %in% args) {
  cat("Rscript rmarkdown.R --infile report.Rmd --outfile report.html --format html_document\n")
  quit(save = "no", status = if (length(args)) 0 else 1)
}
if (length(args) %% 2 != 0) {
  stop("选项需要配对的参数值")
}
# 奇数位为选项名，偶数位为值；保留调用方指定的输出格式。
opts <- setNames(
  args[seq(2, length(args), 2)],
  sub("^--", "", args[seq(1, length(args), 2)])
)
if (!all(c("infile", "outfile") %in% names(opts))) {
  stop("缺少 --infile/--outfile")
}

# 使用解释器所在环境的 Pandoc，避免激活脚本和服务器路径依赖。
if (!nzchar(Sys.which("pandoc"))) {
  candidate <- file.path(dirname(dirname(R.home())), "bin", "pandoc")
  if (file.exists(candidate)) {
    Sys.setenv(RSTUDIO_PANDOC = dirname(candidate))
  }
}
output_format <- if ("format" %in% names(opts)) opts[["format"]] else "html_document"
rmarkdown::render(
  opts[["infile"]], output_file = opts[["outfile"]],
  output_format = output_format, quiet = TRUE
)
# 流水线先复制模板到报告目录，渲染后清理与 HTML 同目录的 report.Rmd 副本。
if (basename(opts[["infile"]]) == "report.Rmd" &&
    normalizePath(dirname(opts[["infile"]])) == normalizePath(dirname(opts[["outfile"]]))) {
  unlink(opts[["infile"]])
}
old_session <- file.path(dirname(opts[["outfile"]]), "render_sessionInfo.txt")
if (file.exists(old_session)) {
  unlink(old_session)
}
