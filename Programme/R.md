# R

---

**最小的数据结构是向量，不是标量**

**索引从 1 开始**

~~~R
10 / 5 %% 2	# 了解 R 的计算方式
~~~



## 基础命令

~~~R
a <- read.table("test.txt",
                sep = "\t",	# 制表符分割
                quote = "",	# 取消默认把单双引号当引用（将两个单（双）引号之间的内容当作一个元素，使行数大大变少）
                comment.char = "",	# 取消默认将 # 做注释（元素中含有 # 则会报错）
                check.names = FALSE,	# 取消默认直接计算列名中包含的运算公式（会修改列名为运算形式）
                header = T)	# 根据需要加
~~~



## Rstudio

**设置**：zoom 100%；Editor font size 14

**初始下载或加载包**

~~~R
# require() 若存在包则加载，不存在则返回逻辑值 FALSE，可作为判断
for (pkg in c("tidyverse", "palmerpenguins", "ggthemes")) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
    require(pkg, character.only = TRUE, quietly = TRUE)
  }
}
~~~

**ggplot2 模板**

~~~R
for (pkg in c("tidyverse", "palmerpenguins", "ggthemes")) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
    require(pkg, character.only = TRUE)
  }
}

view(penguins)
penguins <- penguins

p <- ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Penguins",
    x = "Flipper length (mm)",
    y = "Body mass (g)"
  ) +
  scale_color_colorblind() +  # 挑选模板颜色
  theme_classic() +
  theme(
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 18),
    plot.title = element_text(size = 20)
  )

ggsave(
  filename = "plot.pdf",
  plot = p,
  device = cairo_pdf
)

ggsave(
  filename = "plot.png",
  plot = p,
  dpi = 600
)
~~~



~~~R
data.frame()
subset()
dim()
apply()
abs(): absolute value function
~~~

~~~R
df <- data.frame(S1 = c(1, 2, 3, 4, 5), 
                 S2 = c(5, 4, 3, 2, 1), 
                 S3 = runif(5, -10, 10), 
                 S4 = runif(5, -10, 10))
# 有惊喜
df + c(1, 2)
~~~



## 数据结构

**向量（vector）**

~~~R
a <- c(2, 4, 6, 8, 10)

a[2]
a[-5]
a[1:3]
a[c(2,5)]
a[-c(2,5)]

a < 7
a[a < 7]
a[a != 7]
a[a == 6]

a %in% c(1:8)
a[a %in% c(1:8)]

names(a) <- c("zhangsan", "lisi", "wangwu", "zhaoliu", "fugui")
a["fugui"]
a[5]
unname(a["fugui"])


seq(1, 100, 4)


rep(1:5, 5)
rep(1:5, times = 5)

rep(1:5, each = 3)

rep(1:2, each = 3, times = 2)
rep(1:2, times = 2, each = 3)
~~~

**数据框**

~~~R
# 创建
df <- data.frame(row.names = c("小红", "小李", "校长", "小香"),
                 数学 = c(12, 44, 74, 13),
                 语文 = c(98, 45, 64, 97),
                 性别 = c("女", "男", "男", "女")
                 )

# 取值
df[2, 2]
df[, 3]
df[, 1:3]
df$数学
df[1:2, 1:2]
df[c(1, 3), 1:2]

# 函数
rownames(df)
colnames(df)

nrow(df)
ncol(df)
df[, c(1, 3)]
sum(df$数学)
dim(df)

colSums(df[, c(1, 3)])
~~~



## 数据类型

**数值型（numeric）**

~~~R
a <- 9
b <- c(1.5, 4.1, 2.5, 11.551)
c <- c(-4, 20, 3.14, -124.1)

log(a)
log(a, 3)

round(b, digits = 1)

ceiling(b)
floor(b)

max(c)
min(b)
sum(b)
mean(b)
median(c)

# 方差（variance）
var(b)
# 标准差（standard deviation）
sd(c)
# 相关性（Correlation）
cor(b, c)

data <- c(5, 6, 8, 2, 9, 3)
sort(data)
order(data)
data[order(data)]
~~~

**字符型（character）**

~~~R
library(tidyverse)

DNA <- c("Ac", "AcccTT", "CCCtttGG", "TTTCCa")
str_count(DNA, "c")
# 对每个字符串通过位置来提取元素
str_sub(DNA, 1, 3)
str_sub(DNA, 1, -2)

a <- "asdfghjkl"
str_sub(a, 1)
str_sub(a, 1, 3)
# 对每个字符串通过位置来替换元素
str_sub(DNA, 1, 3) <- 1
DNA

# 输出符合的子集
DNA <- c("Ac", "AcccTT", "CCCtttGG", "TTTCCa")
str_subset(DNA, "C")
str_length(DNA)

# 第一个匹配代替和全部替代
str_replace(DNA, "C", "M")
str_replace_all(DNA, "C", "M")
str_to_lower(DNA)
str_to_upper(DNA)

# 连接
str_c("haha", DNA, sep = "_")
# 分割
a <- "asdfghjklasd"
str_split(a, "a")
class(str_split(a, "d"))
class(str_split(a, "d", simplify = T))

str_sort(a)
str_sort(DNA)
b <- c(1, 23, 67, 12, 55)
str_sort(b)
str_sort(b, decreasing = T)
~~~

**逻辑型（logical）**

~~~R
# 与 或 非
& | ！
~~~



**Tidyverse**

~~~R
# tibble: 行名转为变量; 也可变量转为行名
library(tibble)
## 行名变为第一列, 列名'gene_id'
de_result <- rownames_to_column(de_result, var = 'gene_id')
## 第一列变行名, 删除列名'gene_id'
de_result <- column_to_rownames(de_result, var = 'gene_id')

# readr: 图形操作数据框行名改列

# dplyr
library(dplyr)
## 行过滤
filter(de_result, abs(logFC) > 1 & FDR < 0.05)

de_result[abs(de_result$logFC) > 1 & de_result$FDR < 0.05,]
## 列过滤
select(de_result, gene_id, logFC, FDR)

de_result[,c("gene_id", "logFC", "FDR")]

## 排序
arrange(de_result, desc(abs(logFC)), FDR)

## 增加/修改列
mutate(de_result, FC = 2 ** logFC)

# 管道后的函数不带前面的文件结果，逗号也可不带；left_join 函数在管道符后带带逗号错误!
library(tidyverse, dplyr, tibble)
result <- rownames_to_column(de_result, var = "gene_id") %>%
          filter(, abs(logFC) > 1 & FDR < 0.05) %>%
          select(, gene_id, logFC, FDR) %>%
          arrange(, desc(abs(logFC)), FDR) %>%
          mutate(, FC = 2 ** logFC)
result

# 分组统计
result_2 <- mutate(de_result,
                   description = if_else(abs(logFC) < 1 | FDR > 0.05, "ns",
                                         if_else(logFC >= 1, "up", "down")))

## 将 result_2 按 description 分组，统计函数 n()，重命名 count = n()
group_by(result_2, description) %>%
  summarise(count = n())

## 找logFC绝对值最大数
group_by(result_2, description) %>%
  summarise(max(abs(logFC)))

## 筛选 logFC 绝对值最大数的行
group_by(result_2, description) %>%
  filter(abs(logFC) == max(abs(logFC)))

# 多表关联

## 对result表只添加result表中已有id的function列, 而不引入result表没有的gene_neme
left_join(result, gene_function, by = c("gene_id" = "gene_name"))

## 对result表添加gene_function表中所有function列, 若result表无id, 则引入NA
right_join(result, gene_function, by = c("gene_id" = "gene_name"))

## 取俩表的全集
full_join(result, gene_function, by = c("gene_id" = "gene_name"))

## 取俩表的交集
inner_join(result, gene_function, by = c("gene_id" = "gene_name"))

## 三表关联

#! left_join()在管道符之后不增加变量的话报错, 因为其没有默认值; 所以需要去掉第一个逗号; by可省一个
left_join(result, gene_function, by = c("gene_id" = "gene_name")) %>%
  left_join(, gene_exp, by = c("gene_id" = "gene_id"))
##! 修改后
left_join(result, gene_function, by = c("gene_id" = "gene_name")) %>%
  left_join(gene_exp, by = "gene_id")
~~~

**差异基因的火山图、热图**

~~~R
# 绘图保存图片会出现中文字体不在字体库的问题
# 记事本编辑 R/etc/Rprofile.site，添加下列信息

# 中文显示设置
Sys.setlocale(category = "LC_ALL", locale = "Chinese")
windowsFonts(微软雅黑=windowsFont("微软雅黑"))
options(ggplot2.continuous.colour="viridis")
theme_set(theme_bw(base_family = "微软雅黑"))

# 准备数据
library(tidyverse)

## 1.表达矩阵
gene_exp <- read.delim("RNASeq-downstream/data/genes.TMM.EXPR.matrix")

## 2.样本信息表
sample_info <- read.table("RNASeq-downstream/data/sample_info.txt",
                          header = T,
                          row.names = 1)

## 3.差异分析结果
de_result <- read.delim("RNASeq-downstream/data/genes.counts.matrix.KID_S1_vs_KID_S4.DESeq2.DE_results")

## 4.多表关联与数据整理
de_result <- dplyr::select(de_result, id, log2FoldChange, pvalue, padj) %>%
  mutate(description=if_else(abs(log2FoldChange) < 2 | padj > 0.01, "ns",
                             if_else(log2FoldChange >= 2, "up", "down"))) %>%
  left_join(gene_exp, by=c("id"="X"))


group_by(de_result, description) %>%
  summarise(count = n())

# 火山图
EnhancedVolcano(de_result,
                lab = de_result$id,
                x = "log2FoldChange",
                y = "padj",
                FCcutoff = 2,
                pCutoff = 0.01)

# 热图
colnames(de_result)
top_de <- arrange(de_result, desc(abs(log2FoldChange)))[1:20,] %>%
  select(-log2FoldChange, -pvalue, -padj, -description) %>%
  column_to_rownames(var="id") %>%
  select(contains("BLO_S1_"), contains("BLO_S4_"))

library(pheatmap)
pheatmap(log2(top_de + 1))
~~~
