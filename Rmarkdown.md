# R Markdown 自动生成 HTML 报告学习文档

## 学习目标

学会通过一个 `R` 脚本，把 `Rmd` 模板自动转换成 `HTML` 报告。

最终流程：

```text
report.Rmd + 表格文件 + 图片文件
        ↓
Rscript render.R
        ↓
report.html
```

报告中可以包含：

```text
标题
目录
正文
多级标题
表格
图片
结果说明
结果文件说明
```

---

# 一、整体流程说明

## 1. 需要哪些文件

推荐目录结构：

```text
report_project/
├── render.R
├── report.Rmd
├── style.css
├── data/
│   ├── sample_info.txt
│   ├── qc_stat.txt
│   └── diff_result.txt
├── figures/
│   ├── 01_qc.png
│   ├── 02_pca.png
│   └── 03_volcano.png
└── output/
```

各文件作用：

| 文件或目录 | 作用 |
|---|---|
| `render.R` | 负责把 `report.Rmd` 转成 `report.html` |
| `report.Rmd` | 报告模板，写正文、标题、表格、图片 |
| `style.css` | 控制 HTML 报告样式，例如字体、标题、表格样式 |
| `data/` | 存放表格文件 |
| `figures/` | 存放图片文件 |
| `output/` | 存放最终生成的 HTML 报告 |

---

# 二、安装 R 包

## 1. 安装命令

在 R 中运行：

```r
install.packages("rmarkdown")
install.packages("knitr")
install.packages("kableExtra")
install.packages("DT")
```

安装失败：R 版本太新，需要从源码安装包
**Linux**

~~~bash
sudo apt install build-essential libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libfreetype6-dev

# 选择清华镜像源
options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))

# 验证是否生效
getOption("repos")
# 为啥我从 Tools 换不行？
~~~



## 2. 命令解释

### install.packages()

```r
install.packages("rmarkdown")
```

| 部分 | 解释 |
|---|---|
| `install.packages()` | R 中安装扩展包的函数 |
| `"rmarkdown"` | 要安装的包名 |
| 引号 `" "` | 包名必须放在引号中 |

## 3. 每个包的作用

| R 包 | 作用 |
|---|---|
| `rmarkdown` | 把 `.Rmd` 转成 `.html`、`.docx`、`.pdf` |
| `knitr` | 执行 Rmd 里面的 R 代码块 |
| `kableExtra` | 美化普通表格 |
| `DT` | 生成网页交互式表格，可以搜索、翻页、横向滚动 |

---

# 三、第一步：写 render.R

## 1. 最基础 render.R

新建文件：

```text
render.R
```

内容：

```r
library(rmarkdown)

args <- commandArgs(trailingOnly = TRUE)

rmd_file <- args[1]
out_file <- args[2]

rmarkdown::render(
  input = rmd_file,
  output_file = out_file,
  output_format = "html_document",
  clean = TRUE,
  encoding = "UTF-8"
)
```

---

## 2. 每一行解释

### library(rmarkdown)

```r
library(rmarkdown)
```

| 部分 | 解释 |
|---|---|
| `library()` | 加载已经安装好的 R 包 |
| `rmarkdown` | 加载 rmarkdown 包，用来生成报告 |

---

### commandArgs()

```r
args <- commandArgs(trailingOnly = TRUE)
```

| 部分 | 解释 |
|---|---|
| `args` | 保存命令行传进来的参数 |
| `<-` | R 中的赋值符号，把右边结果保存到左边变量 |
| `commandArgs()` | 读取命令行参数 |
| `trailingOnly = TRUE` | 只读取用户自己写的参数，不读取 Rscript 自带参数 |

例如运行：

```bash
Rscript render.R report.Rmd output/report.html
```

此时：

```r
args[1] = "report.Rmd"
args[2] = "output/report.html"
```

---

### args[1]

```r
rmd_file <- args[1]
```

| 部分 | 解释 |
|---|---|
| `rmd_file` | 保存输入 Rmd 文件路径 |
| `args[1]` | 命令行传入的第 1 个参数 |
| `<-` | 把第 1 个参数赋值给 `rmd_file` |

---

### args[2]

```r
out_file <- args[2]
```

| 部分 | 解释 |
|---|---|
| `out_file` | 保存输出 HTML 文件路径 |
| `args[2]` | 命令行传入的第 2 个参数 |

---

### rmarkdown::render()

```r
rmarkdown::render(
  input = rmd_file,
  output_file = out_file,
  output_format = "html_document",
  clean = TRUE,
  encoding = "UTF-8"
)
```

| 参数 | 解释 |
|---|---|
| `rmarkdown::render()` | 使用 rmarkdown 包中的 render 函数生成报告 |
| `::` | 指定使用某个包里的函数，避免函数名冲突 |
| `input = rmd_file` | 输入文件，也就是要转换的 `.Rmd` 文件 |
| `output_file = out_file` | 输出文件，也就是生成的 `.html` 文件 |
| `output_format = "html_document"` | 输出格式为 HTML 网页报告 |
| `clean = TRUE` | 生成报告后删除中间临时文件 |
| `encoding = "UTF-8"` | 使用 UTF-8 编码，减少中文乱码问题 |

---

# 四、运行 render.R

## 1. 创建输出目录

```bash
mkdir -p output
```

| 部分 | 解释 |
|---|---|
| `mkdir` | 创建文件夹 |
| `-p` | 如果文件夹已经存在，不报错；如果上级目录不存在，自动创建 |
| `output` | 要创建的文件夹名称 |

---

## 2. 生成 HTML 报告

```bash
Rscript render.R report.Rmd output/report.html
```

| 部分 | 解释 |
|---|---|
| `Rscript` | 用命令行运行 R 脚本 |
| `render.R` | 要运行的 R 脚本 |
| `report.Rmd` | 第 1 个参数，输入的 Rmd 模板 |
| `output/report.html` | 第 2 个参数，输出的 HTML 报告 |

对应到 `render.R` 中：

```r
args[1] = "report.Rmd"
args[2] = "output/report.html"
```

---

# 五、改进版 render.R：自动创建输出目录

## 1. 完整代码

```r
library(rmarkdown)

args <- commandArgs(trailingOnly = TRUE)

rmd_file <- args[1]
out_file <- args[2]

out_dir <- dirname(out_file)

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

rmarkdown::render(
  input = rmd_file,
  output_file = basename(out_file),
  output_dir = out_dir,
  output_format = "html_document",
  clean = TRUE,
  encoding = "UTF-8"
)
```

---

## 2. 新增命令解释

### dirname()

```r
out_dir <- dirname(out_file)
```

| 部分 | 解释 |
|---|---|
| `dirname()` | 提取文件路径中的目录部分 |
| `out_file` | 输出文件路径 |
| `out_dir` | 保存输出目录 |

例如：

```r
out_file = "output/report.html"
dirname(out_file) = "output"
```

---

### dir.exists()

```r
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}
```

| 部分 | 解释 |
|---|---|
| `if` | 判断条件是否成立 |
| `!` | 表示“不是” |
| `dir.exists(out_dir)` | 判断输出目录是否存在 |
| `!dir.exists(out_dir)` | 判断输出目录是否不存在 |
| `{ }` | 条件成立时执行里面的代码 |

---

### dir.create()

```r
dir.create(out_dir, recursive = TRUE)
```

| 参数 | 解释 |
|---|---|
| `dir.create()` | 创建文件夹 |
| `out_dir` | 要创建的文件夹路径 |
| `recursive = TRUE` | 如果上级目录不存在，也一起创建 |

---

### basename()

```r
output_file = basename(out_file)
```

| 部分 | 解释 |
|---|---|
| `basename()` | 提取路径中的文件名 |
| `out_file` | 完整输出路径 |

例如：

```r
out_file = "output/report.html"
basename(out_file) = "report.html"
```

---

### output_dir

```r
output_dir = out_dir
```

| 参数 | 解释 |
|---|---|
| `output_dir` | 指定 HTML 文件输出到哪个目录 |
| `out_dir` | 前面提取出来的输出目录 |

---

# 六、参数化 render.R

## 1. 为什么要参数化

如果公司有很多项目，不建议每次手动改 `report.Rmd`。

推荐方式：

```text
同一个 report.Rmd
不同项目只换命令参数
自动生成不同报告
```

---

## 2. 参数化 render.R 完整代码

```r
library(rmarkdown)

args <- commandArgs(trailingOnly = TRUE)

rmd_file <- args[1]
out_file <- args[2]
project_name <- args[3]
data_dir <- args[4]
fig_dir <- args[5]

out_dir <- dirname(out_file)

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

rmarkdown::render(
  input = rmd_file,
  output_file = basename(out_file),
  output_dir = out_dir,
  output_format = "html_document",
  params = list(
    project_name = project_name,
    data_dir = data_dir,
    fig_dir = fig_dir
  ),
  clean = TRUE,
  encoding = "UTF-8"
)
```

---

## 3. 每个参数解释

### 命令运行方式

```bash
Rscript render.R report.Rmd output/report.html "ATAC-seq 分析报告" data figures
```

| 命令部分 | 对应 R 中变量 | 解释 |
|---|---|---|
| `Rscript` | 无 | 使用命令行运行 R 脚本 |
| `render.R` | 无 | 要执行的 R 脚本 |
| `report.Rmd` | `args[1]` / `rmd_file` | 输入的报告模板 |
| `output/report.html` | `args[2]` / `out_file` | 输出的 HTML 报告路径 |
| `"ATAC-seq 分析报告"` | `args[3]` / `project_name` | 报告标题 |
| `data` | `args[4]` / `data_dir` | 表格文件目录 |
| `figures` | `args[5]` / `fig_dir` | 图片文件目录 |

---

### params

```r
params = list(
  project_name = project_name,
  data_dir = data_dir,
  fig_dir = fig_dir
)
```

| 部分 | 解释 |
|---|---|
| `params` | 传给 Rmd 的参数列表 |
| `list()` | R 中创建列表的函数 |
| `project_name = project_name` | 把项目名称传给 Rmd |
| `data_dir = data_dir` | 把表格目录传给 Rmd |
| `fig_dir = fig_dir` | 把图片目录传给 Rmd |

在 `report.Rmd` 中可以这样使用：

```r
params$project_name
params$data_dir
params$fig_dir
```

---

# 七、report.Rmd 基础结构

## 1. 最小 report.Rmd

````markdown
---
title: "分析报告"
author: "公司名称"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = FALSE,
  warning = FALSE,
  message = FALSE,
  fig.align = "center"
)
```

# 一、项目概述

本报告用于展示本次分析的主要结果。

# 二、样本信息

这里展示样本分组和样本基本信息。

# 三、结果展示

这里展示分析图片和结果表格。
````

---

# 八、YAML 参数解释

Rmd 最上面的 `---` 到 `---` 之间叫 YAML 区域，用来设置报告标题、作者、输出格式等。

## 1. YAML 示例

```yaml
---
title: "分析报告"
author: "公司名称"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
---
```

## 2. 每个参数解释

| 参数 | 解释 |
|---|---|
| `title` | 报告标题 |
| `author` | 报告作者或公司名称 |
| `date` | 报告日期 |
| `` `r Sys.Date()` `` | 在报告中自动显示当前日期 |
| `output` | 设置输出格式 |
| `html_document` | 输出为 HTML 网页报告 |
| `toc: true` | 显示目录 |
| `toc_depth: 3` | 目录显示到三级标题 |
| `number_sections: true` | 标题自动编号 |
| `theme: flatly` | 使用 flatly 网页主题 |

---

## 3. 注意缩进

YAML 对缩进很敏感。

正确写法：

```yaml
output:
  html_document:
    toc: true
```

错误写法：

```yaml
output:
html_document:
toc: true
```

---

# 九、参数化 report.Rmd

## 1. YAML 写法

```yaml
---
title: "`r params$project_name`"
author: "公司名称"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
params:
  project_name: "分析报告"
  data_dir: "data"
  fig_dir: "figures"
---
```

## 2. 参数解释

| 参数 | 解释 |
|---|---|
| `title: "`r params$project_name`"` | 报告标题使用命令行传入的项目名称 |
| `params:` | 定义 Rmd 可以接收的参数 |
| `project_name` | 项目名称 |
| `data_dir` | 表格目录 |
| `fig_dir` | 图片目录 |

---

## 3. 在 Rmd 中使用参数

```r
params$project_name
params$data_dir
params$fig_dir
```

| 写法 | 解释 |
|---|---|
| `params` | Rmd 中保存参数的对象 |
| `$` | 从对象中取出某个参数 |
| `params$project_name` | 取出项目名称 |
| `params$data_dir` | 取出表格目录 |
| `params$fig_dir` | 取出图片目录 |

---

# 十、Rmd 代码块参数解释

## 1. R 代码块格式

````markdown
```{r setup, include=FALSE}
代码内容
```
````

| 部分 | 解释 |
|---|---|
| ``` | 代码块开始或结束 |
| `{r}` | 表示这是 R 代码块 |
| `setup` | 代码块名称 |
| `include=FALSE` | 不在报告中显示这个代码块和运行结果 |

---

## 2. 常用代码块参数

| 参数 | 解释 |
|---|---|
| `echo = FALSE` | 不显示代码，只显示结果 |
| `warning = FALSE` | 不显示警告信息 |
| `message = FALSE` | 不显示包加载信息 |
| `include = FALSE` | 代码和结果都不显示，只执行 |
| `eval = FALSE` | 不执行代码，只显示代码 |
| `fig.align = "center"` | 图片居中 |
| `out.width = "80%"` | 控制图片显示宽度 |
| `fig.width = 8` | R 直接画图时设置图片宽度 |
| `fig.height = 6` | R 直接画图时设置图片高度 |

---

## 3. setup 代码块

```r
knitr::opts_chunk$set(
  echo = FALSE,
  warning = FALSE,
  message = FALSE,
  fig.align = "center"
)
```

| 参数 | 解释 |
|---|---|
| `knitr::opts_chunk$set()` | 设置所有代码块的默认参数 |
| `echo = FALSE` | 默认不显示 R 代码 |
| `warning = FALSE` | 默认不显示警告 |
| `message = FALSE` | 默认不显示提示信息 |
| `fig.align = "center"` | 默认图片居中 |

---

# 十一、Markdown 正文语法

## 1. 标题

```markdown
# 一级标题

## 二级标题

### 三级标题
```

| 写法 | 解释 |
|---|---|
| `#` | 一级标题 |
| `##` | 二级标题 |
| `###` | 三级标题 |

---

## 2. 普通文字

```markdown
本部分展示样本测序数据质量情况。
```

解释：

```text
普通文字直接写，不需要特殊符号。
```

---

## 3. 加粗

```markdown
重点关注 **Q30、比对率和有效数据量**。
```

| 写法 | 解释 |
|---|---|
| `**文字**` | 加粗显示 |

---

## 4. 列表

```markdown
主要结果包括：

1. 样本质控结果
2. 比对统计结果
3. 差异分析结果
```

| 写法 | 解释 |
|---|---|
| `1.` | 有序列表 |
| `-` | 无序列表 |

---

# 十二、插入图片

## 1. 基础写法

````markdown
```{r qc-figure, out.width="80%"}
knitr::include_graphics("figures/01_qc.png")
```
````

## 2. 参数解释

| 部分 | 解释 |
|---|---|
| `qc-figure` | 代码块名称，不能和其他代码块重复 |
| `out.width="80%"` | 图片显示为页面宽度的 80% |
| `knitr::include_graphics()` | 插入已经存在的图片 |
| `"figures/01_qc.png"` | 图片路径 |

---

## 3. 参数化图片路径

```r
knitr::include_graphics(file.path(params$fig_dir, "01_qc.png"))
```

| 部分 | 解释 |
|---|---|
| `file.path()` | 自动拼接路径 |
| `params$fig_dir` | 图片所在目录 |
| `"01_qc.png"` | 图片文件名 |

例如：

```r
file.path("figures", "01_qc.png")
```

结果是：

```text
figures/01_qc.png
```

---

## 4. 图片说明推荐写法

````markdown
## 3.1 质控结果图

下图展示样本质控结果，重点关注各样本质量是否稳定，是否存在明显异常样本。

```{r qc-figure, out.width="85%"}
knitr::include_graphics(file.path(params$fig_dir, "01_qc.png"))
```
````

---

# 十三、读取表格

## 1. 基础 read.table()

```r
sample_info <- read.table(
  "data/sample_info.txt",
  header = TRUE,
  sep = "\t",
  quote = "",
  check.names = FALSE,
  as.is = TRUE
)
```

## 2. 参数解释

| 参数 | 解释 |
|---|---|
| `sample_info <-` | 把读取到的表格保存为 `sample_info` |
| `read.table()` | 读取文本表格 |
| `"data/sample_info.txt"` | 表格文件路径 |
| `header = TRUE` | 第一行是列名 |
| `sep = "\t"` | 表格使用 Tab 分隔 |
| `quote = ""` | 不把引号当作特殊字符处理 |
| `check.names = FALSE` | 不自动修改列名 |
| `as.is = TRUE` | 字符列保持为字符，不自动转成因子 |

---

## 3. 常见分隔符

| 文件类型 | 参数写法 |
|---|---|
| Tab 分隔 txt | `sep = "\t"` |
| 逗号分隔 csv | `sep = ","` |
| 空格分隔 | `sep = ""` |

---

## 4. 参数化读取表格

```r
sample_info <- read.table(
  file.path(params$data_dir, "sample_info.txt"),
  header = TRUE,
  sep = "\t",
  quote = "",
  check.names = FALSE,
  as.is = TRUE
)
```

| 部分 | 解释 |
|---|---|
| `file.path(params$data_dir, "sample_info.txt")` | 从参数指定的数据目录中读取样本表 |
| `params$data_dir` | 命令行传入的数据目录 |
| `"sample_info.txt"` | 具体文件名 |

---

# 十四、展示静态表格：knitr::kable

## 1. 基础写法

```r
knitr::kable(sample_info, align = "l", caption = "样本信息表")
```

## 2. 参数解释

| 参数 | 解释 |
|---|---|
| `knitr::kable()` | 把 R 数据框显示成网页表格 |
| `sample_info` | 要展示的数据框 |
| `align = "l"` | 表格内容左对齐 |
| `caption = "样本信息表"` | 表格标题 |

---

## 3. kableExtra 美化

```r
knitr::kable(sample_info, align = "l", caption = "样本信息表") %>%
  kableExtra::kable_styling(full_width = FALSE)
```

## 4. 参数解释

| 部分 | 解释 |
|---|---|
| `%>%` | 管道符，把前一步结果传给下一步 |
| `kableExtra::kable_styling()` | 美化 kable 表格 |
| `full_width = FALSE` | 表格不强制占满整个页面宽度 |

---

## 5. 只展示前 20 行

```r
knitr::kable(head(diff_result, 20), align = "l", caption = "差异分析结果前 20 行")
```

| 部分 | 解释 |
|---|---|
| `head(diff_result, 20)` | 只取 `diff_result` 的前 20 行 |
| `20` | 要展示的行数 |

---

# 十五、展示交互式表格：DT::datatable

## 1. 基础写法

```r
DT::datatable(
  diff_result,
  rownames = FALSE,
  filter = "top",
  options = list(
    pageLength = 20,
    scrollX = TRUE
  )
)
```

## 2. 参数解释

| 参数 | 解释 |
|---|---|
| `DT::datatable()` | 生成网页交互式表格 |
| `diff_result` | 要展示的数据框 |
| `rownames = FALSE` | 不显示 R 默认行号 |
| `filter = "top"` | 每列顶部显示筛选框 |
| `options = list()` | 设置表格显示参数 |
| `pageLength = 20` | 每页显示 20 行 |
| `scrollX = TRUE` | 列很多时允许横向滚动 |

---

## 3. 不要上下滚动条，只保留分页

```r
DT::datatable(
  diff_result,
  rownames = FALSE,
  filter = "top",
  options = list(
    pageLength = 20,
    scrollX = TRUE
  )
)
```

说明：

```text
不要设置 scrollY。
设置 scrollY 后，表格会出现上下滚动条。
```

---

## 4. 展示全部行

```r
DT::datatable(
  diff_result,
  rownames = FALSE,
  filter = "top",
  options = list(
    paging = FALSE,
    scrollX = TRUE
  )
)
```

| 参数 | 解释 |
|---|---|
| `paging = FALSE` | 关闭分页，直接显示所有行 |
| `scrollX = TRUE` | 列多时横向滚动 |

注意：

```text
如果表格行数特别多，不建议展示全部行。
HTML 会变慢。
```

---

# 十六、完整 report.Rmd 模板：带注释

````markdown
---
title: "`r params$project_name`"
author: "公司名称"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
params:
  project_name: "分析报告"
  data_dir: "data"
  fig_dir: "figures"
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = FALSE,
  warning = FALSE,
  message = FALSE,
  fig.align = "center"
)

library(knitr)
library(kableExtra)
library(DT)
```

# 一、项目概述

本报告用于展示本次项目的主要分析结果，包括样本信息、数据质控、统计分析和可视化结果。

# 二、样本信息

本部分展示样本名称、分组信息和重复信息。

```{r sample-info}
sample_info <- read.table(
  file.path(params$data_dir, "sample_info.txt"),
  header = TRUE,
  sep = "\t",
  quote = "",
  check.names = FALSE,
  as.is = TRUE
)

knitr::kable(sample_info, align = "l", caption = "样本信息表") %>%
  kableExtra::kable_styling(full_width = FALSE)
```

# 三、数据质控

本部分展示测序数据质量控制结果，用于判断样本是否满足后续分析要求。

## 3.1 质控统计表

```{r qc-table}
qc_stat <- read.table(
  file.path(params$data_dir, "qc_stat.txt"),
  header = TRUE,
  sep = "\t",
  quote = "",
  check.names = FALSE,
  as.is = TRUE
)

knitr::kable(qc_stat, align = "l", caption = "质控统计表") %>%
  kableExtra::kable_styling(full_width = FALSE)
```

## 3.2 质控结果图

下图展示样本质控结果，重点关注各样本质量是否稳定。

```{r qc-figure, out.width="85%"}
knitr::include_graphics(file.path(params$fig_dir, "01_qc.png"))
```

# 四、样本关系分析

样本关系分析用于观察样本间整体差异和组内重复性。

## 4.1 PCA 分析

PCA 图用于展示样本间整体分布情况，重点关注组内样本是否聚集、组间样本是否分离。

```{r pca-figure, out.width="75%"}
knitr::include_graphics(file.path(params$fig_dir, "02_pca.png"))
```

# 五、差异分析

本部分展示不同分组之间的差异分析结果。

## 5.1 差异结果表

```{r diff-table}
diff_result <- read.table(
  file.path(params$data_dir, "diff_result.txt"),
  header = TRUE,
  sep = "\t",
  quote = "",
  check.names = FALSE,
  as.is = TRUE
)

DT::datatable(
  diff_result,
  rownames = FALSE,
  filter = "top",
  options = list(
    pageLength = 20,
    scrollX = TRUE
  )
)
```

## 5.2 差异结果图

火山图用于展示差异结果的整体分布情况，重点关注显著上调和显著下调的特征。

```{r volcano-figure, out.width="80%"}
knitr::include_graphics(file.path(params$fig_dir, "03_volcano.png"))
```

# 六、结果文件说明

| 文件 | 内容说明 |
|---|---|
| `sample_info.txt` | 样本分组信息 |
| `qc_stat.txt` | 质控统计结果 |
| `diff_result.txt` | 差异分析结果 |
| `01_qc.png` | 质控结果图 |
| `02_pca.png` | PCA 分析图 |
| `03_volcano.png` | 火山图 |

# 七、总结

本报告展示了本次分析的主要结果，后续可根据重点表格和图片进一步筛选候选结果。
````

---

# 十七、完整 render.R 模板：推荐使用

```r
library(rmarkdown)

args <- commandArgs(trailingOnly = TRUE)

rmd_file <- args[1]
out_file <- args[2]
project_name <- args[3]
data_dir <- args[4]
fig_dir <- args[5]

out_dir <- dirname(out_file)

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

rmarkdown::render(
  input = rmd_file,
  output_file = basename(out_file),
  output_dir = out_dir,
  output_format = "html_document",
  params = list(
    project_name = project_name,
    data_dir = data_dir,
    fig_dir = fig_dir
  ),
  clean = TRUE,
  encoding = "UTF-8"
)
```

---

# 十八、完整运行命令

```bash
mkdir -p output
Rscript render.R report.Rmd output/report.html "ATAC-seq 分析报告" data figures
```

## 命令拆解

### mkdir -p output

| 部分 | 解释 |
|---|---|
| `mkdir` | 创建文件夹 |
| `-p` | 如果文件夹存在也不报错 |
| `output` | 输出目录 |

### Rscript 命令

| 部分 | 解释 |
|---|---|
| `Rscript` | 用命令行运行 R 脚本 |
| `render.R` | 负责生成报告的脚本 |
| `report.Rmd` | 报告模板 |
| `output/report.html` | 最终生成的 HTML 报告 |
| `"ATAC-seq 分析报告"` | 报告标题 |
| `data` | 表格所在目录 |
| `figures` | 图片所在目录 |

---

# 十九、CSS 美化报告

## 1. style.css

新建文件：

```text
style.css
```

内容：

```css
body {
  font-size: 15px;
  line-height: 1.8;
}

h1 {
  border-bottom: 2px solid #2c7fb8;
  padding-bottom: 8px;
  margin-top: 35px;
}

h2 {
  margin-top: 28px;
  color: #2c7fb8;
}

table {
  font-size: 14px;
}

caption {
  font-weight: bold;
  text-align: left;
}

img {
  margin-top: 10px;
  margin-bottom: 20px;
}
```

## 2. CSS 参数解释

| CSS 写法 | 解释 |
|---|---|
| `body` | 控制整个网页正文 |
| `font-size: 15px;` | 正文字体大小为 15 像素 |
| `line-height: 1.8;` | 行距为 1.8 倍 |
| `h1` | 控制一级标题 |
| `border-bottom` | 标题下方加横线 |
| `padding-bottom` | 标题文字和下方横线之间的距离 |
| `margin-top` | 标题上方距离 |
| `h2` | 控制二级标题 |
| `color` | 设置文字颜色 |
| `table` | 控制表格 |
| `caption` | 控制表格标题 |
| `font-weight: bold;` | 加粗 |
| `text-align: left;` | 左对齐 |
| `img` | 控制图片 |
| `margin-top` | 图片上方距离 |
| `margin-bottom` | 图片下方距离 |

---

## 3. 在 Rmd 中引用 CSS

YAML 中加入：

```yaml
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
    css: style.css
```

| 参数 | 解释 |
|---|---|
| `css: style.css` | 使用当前目录下的 `style.css` 控制报告样式 |

---

# 二十、常见错误和解决方法

## 1. 中文乱码

读取表格时可以加：

```r
fileEncoding = "UTF-8"
```

完整示例：

```r
read.table(
  "data/sample_info.txt",
  header = TRUE,
  sep = "\t",
  fileEncoding = "UTF-8",
  check.names = FALSE
)
```

参数解释：

| 参数 | 解释 |
|---|---|
| `fileEncoding = "UTF-8"` | 按 UTF-8 编码读取文件 |

如果文件来自 Windows，可能需要：

```r
fileEncoding = "GBK"
```

---

## 2. 图片不显示

检查图片是否存在：

```r
file.exists("figures/01_qc.png")
```

| 部分 | 解释 |
|---|---|
| `file.exists()` | 判断文件是否存在 |
| `"figures/01_qc.png"` | 要检查的图片路径 |
| 返回 `TRUE` | 文件存在 |
| 返回 `FALSE` | 文件不存在或路径错误 |

---

## 3. 表格列名被修改

读取表格时加：

```r
check.names = FALSE
```

作用：

```text
保留原始列名，不让 R 自动把列名改成合法变量名。
```

---

## 4. 表格分隔符错误

如果表格是 Tab 分隔：

```r
sep = "\t"
```

如果表格是逗号分隔：

```r
sep = ","
```

如果表格是空格分隔：

```r
sep = ""
```

---

## 5. Rmd 中代码块名称重复

错误示例：

````markdown
```{r figure}
knitr::include_graphics("figures/01.png")
```

```{r figure}
knitr::include_graphics("figures/02.png")
```
````

问题：

```text
两个代码块都叫 figure，会报错。
```

正确示例：

````markdown
```{r figure1}
knitr::include_graphics("figures/01.png")
```

```{r figure2}
knitr::include_graphics("figures/02.png")
```
````

---

# 二十一、公司报告建议固定规范

## 1. 文件格式规范

建议统一：

```text
表格：txt
分隔符：Tab
图片：png
编码：UTF-8
输出：html
```

---

## 2. 表格命名规范

```text
sample_info.txt
qc_stat.txt
mapping_stat.txt
diff_result.txt
go_enrichment.txt
kegg_enrichment.txt
result_file_list.txt
```

---

## 3. 图片命名规范

```text
01_rawdata_qc.png
02_mapping_stat.png
03_sample_correlation.png
04_pca.png
05_volcano.png
06_heatmap.png
07_go_barplot.png
08_kegg_bubble.png
```

---

# 二十二、学习顺序

## 第 1 步：跑通最小报告

目标：

```text
生成一个只有标题和正文的 HTML。
```

练习：

```bash
Rscript render.R report.Rmd output/report.html
```

---

## 第 2 步：加入图片

目标：

```text
能把 png 图片插入报告。
```

重点掌握：

```r
knitr::include_graphics()
```

---

## 第 3 步：加入表格

目标：

```text
能读取 txt 表格并展示。
```

重点掌握：

```r
read.table()
knitr::kable()
```

---

## 第 4 步：加入交互式表格

目标：

```text
大表格可以搜索、翻页、横向滚动。
```

重点掌握：

```r
DT::datatable()
```

---

## 第 5 步：改成参数化模板

目标：

```text
不同项目只改命令参数，不改 Rmd。
```

重点掌握：

```r
params = list()
params$data_dir
params$fig_dir
```

---

## 第 6 步：加入 CSS

目标：

```text
让报告更像正式公司报告。
```

重点掌握：

```yaml
css: style.css
```

---

# 二十三、最小可复用文件

## 1. render.R

```r
library(rmarkdown)

args <- commandArgs(trailingOnly = TRUE)

rmd_file <- args[1]
out_file <- args[2]
project_name <- args[3]
data_dir <- args[4]
fig_dir <- args[5]

out_dir <- dirname(out_file)

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

rmarkdown::render(
  input = rmd_file,
  output_file = basename(out_file),
  output_dir = out_dir,
  output_format = "html_document",
  params = list(
    project_name = project_name,
    data_dir = data_dir,
    fig_dir = fig_dir
  ),
  clean = TRUE,
  encoding = "UTF-8"
)
```

---

## 2. report.Rmd

````markdown
---
title: "`r params$project_name`"
author: "公司名称"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
params:
  project_name: "分析报告"
  data_dir: "data"
  fig_dir: "figures"
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = FALSE,
  warning = FALSE,
  message = FALSE,
  fig.align = "center"
)

library(knitr)
library(kableExtra)
library(DT)
```

# 一、项目概述

本报告用于展示本次项目的主要分析结果。

# 二、样本信息

```{r sample-info}
sample_info <- read.table(
  file.path(params$data_dir, "sample_info.txt"),
  header = TRUE,
  sep = "\t",
  quote = "",
  check.names = FALSE,
  as.is = TRUE
)

knitr::kable(sample_info, align = "l", caption = "样本信息表") %>%
  kableExtra::kable_styling(full_width = FALSE)
```

# 三、质控结果

```{r qc-figure, out.width="80%"}
knitr::include_graphics(file.path(params$fig_dir, "01_qc.png"))
```

# 四、差异分析结果

```{r diff-table}
diff_result <- read.table(
  file.path(params$data_dir, "diff_result.txt"),
  header = TRUE,
  sep = "\t",
  quote = "",
  check.names = FALSE,
  as.is = TRUE
)

DT::datatable(
  diff_result,
  rownames = FALSE,
  filter = "top",
  options = list(
    pageLength = 20,
    scrollX = TRUE
  )
)
```

# 五、结果说明

本报告展示了本次分析的主要结果。
````

---

# 二十四、最终运行命令

```bash
mkdir -p output
Rscript render.R report.Rmd output/report.html "ATAC-seq 分析报告" data figures
```

生成结果：

```text
output/report.html
```

---

# 二十五、核心函数总结

| 函数 | 作用 |
|---|---|
| `rmarkdown::render()` | 把 Rmd 转成 HTML |
| `commandArgs()` | 读取命令行参数 |
| `dirname()` | 提取输出目录 |
| `basename()` | 提取文件名 |
| `dir.exists()` | 判断文件夹是否存在 |
| `dir.create()` | 创建文件夹 |
| `read.table()` | 读取 txt 表格 |
| `file.path()` | 拼接路径 |
| `knitr::kable()` | 展示普通表格 |
| `kableExtra::kable_styling()` | 美化普通表格 |
| `DT::datatable()` | 展示交互式表格 |
| `knitr::include_graphics()` | 插入图片 |
| `file.exists()` | 检查文件是否存在 |

---

# 二十六、最重要的理解

初学时只需要记住：

```text
render.R 负责生成报告
report.Rmd 负责写报告内容
data/ 放表格
figures/ 放图片
output/ 放最终 HTML
```

真正核心命令只有一个：

```r
rmarkdown::render()
```

真正核心 Rmd 函数只有三个：

```r
read.table()
knitr::kable()
knitr::include_graphics()
```

大表格再加一个：

```r
DT::datatable()
```
