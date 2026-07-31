## ==第一要素: 使用绝对路径==

---

# Linux

---

数据块：存储文件内容
元数据（文件附加属性）：文件大小、创建时间、创建人等以及 incode（系统识别文件的唯一标识符），名字方便人记不属于 incode，mv 名字后 incode 不变

链接: 硬链接（Hard link）和软链接（Soft link）
硬链接：文件副本，无独立 incode，必须在同一系统文件下创建，源文件必须存在且不能为目录
软链接：包含独立 incode，指向源文件



## 基础命令

~~~bash
# ls（list directory contents）
##	权限	硬链接	创建人		创建人所在组	大小	最后修改时间	相对路径
drwxrwxrwx 1 zhangxuejie zhangxuejie 4096 Mar 10 22:40 Training/
## 列向展示所有 gz 文件
ls *gz|awk -F '.part' '{print$1}'

# pwd（print working directory）
# cd（change directory）
cd -	# 返回刚才目录
~~~

~~~bash
# 文件重命名
rename 's/new/old/' old_load.txt
~~~

~~~bash
# 查找正在运行的 programme 的 ID; 终止运行
ps aux | grep Trinity | grep -v grep | awk '{print $2}' | xargs kill -9

# 一步到位
pkill -9 firefox
~~~

~~~bash
# 创建文件和目录默认权限，公司所有人都在所属组，所以同组权限足够使用
umask 0002
~~~

~~~bash
# 添加新用户, 赋予文件权限
su root
adduser zhangfugui
chmod 765(读写执-读写-读执) filename
~~~

~~~bash
# 不进入环境查看 python 版本号
conda run -n 环境名称 python --version

# 查看当前环境下自己下载的包，不包括依赖
conda env export --from-history

# conda activate 在命令行可以用，在脚本中不可用，原因是激活 conda 默认运行 .bashrc；而 bash 脚本不会加载 .bashrc
conda run -n vs2 
~~~



### awk

名字是因为三个老外作者的姓第一个字母分别是 A W K

~~~bash
# NF（Number of Field）
# NR（）
awk '{print NR}' test.txt
awk '{print NF}' test.txt	# 输出每行字段数
awk '{print $NF}' test.txt	# 每行字段数就是最后一列的列数，$NF 代表最后一列的值；$1 代表第一列，$0 代表整行

# -F '/' 指定 / 为分割符，默认分隔符空格

# （正则）匹配
awk '/^a.*r$/ {print $1}' test.txt	# 正则匹配行以 a 开头 r 结尾，中间任意字符串
awk '$2 == "haha" {print $0}' test.txt	# 打印第二列为 haha 的所有行
awk '$3~/^;/ {print $2"\t"$6}' test.txt	# 打印第三列开头为 ; 的第二列和第六列
awk '$3!~/^;/ {print $2"\t"$6}' test.txt	# 打印第三列开头不是 ; 的第二列和第六列
awk 'NR==1 || NR==2 || NR==4 || NR==6 || NR==8 || NR==10' test.txt

# 数值判断
awk '$3 > 20 || $3 <12 {print $0}' test.txt	# 判断：|| 或；&& 且

# 打印单引号
awk '{print "'\''"}' test.txt
# 打印双引号
awk '{print "\""}' test.txt

# '{printf $1}' 无空格横向输出第一列；printf 格式化输出
~~~



### 文件操作

~~~bash
# less 严格匹配 12 的单词，不包含 1122 1312 等
/\<12\>
~~~

~~~bash
# sed(Stream Editor) ^啥意思
sed 's/^.*addr://g'
sed "1i1231414"
# -i --in-place <edit files in place (makes backup if SUFFIX supplied)>
# d <delete>
~~~

~~~bash
# 文件内容合并重定向输出
cat Step_1.1_qc.sh Step_2_megahit.sh > ../connect.sh
~~~

~~~bash
# grep（global regular expression print）
grep 'Au_60' Step_2_megahit.sh

# -E 启用扩展正则表达式，找出包含任意字符的行；-i 无视大小写
grep -i -E "word1|word2|word3|word4" Step_2_megahit.sh

# ^a 表示以 a 开头；r$ 表示以 r 结尾；.* 表示任意字符（包括空字符）
grep "^a.*r\$" filename.txt	# 实际加不加 \ 都可

# 查找文本中单双引号
grep "'" test.txt
grep "\"" test.txt
~~~

~~~bash
# 比较俩文件大小，相同则没输出
diff file1 file2
~~~

~~~bash
# wc 行数, 单词数(空格, 制表符, 换行符分割), 字符数
wc file.txt
# 打印第四行
wc file.txt | head -n 4 | tail -n 1
~~~

~~~bash
# sort 按照 ASCII 码排列, 数字则按相同顺序的 ASCII 往后排
## -g 按数值排列
## -k 指定 key 排列
## -u 去重
## -k 1,1 第一个字段排序后，仍然按照后续字段排序，因为默认不稳定排序（排序的字段相同时，原文相对顺序不保留），-s 取消默认
# 将以下内容写入文件
apple 5 red
banana 3 yellow
apple 2 green
cherry 1 red

sort -k 1 text.txt
sort -k 1,1 text.txt
sort -k 1,1 -s text.txt
~~~

~~~bash
# csvtk cut: select and arrange fields
~~~

~~~bash
# 输出从第四行开始到结尾
tail -n +4 file

# 把文件按行分成两份
head -n 56 file > file1	# 第一份
tail -n +57 file > file2	# 第二份，注意行数要比 head 加一
~~~

~~~bash
mkdir -s file	# 检查文件是否存在且非空
mkdir -d file	# 检查是否为目录
~~~

~~~bash
# 全局替换
%s/2/5/g
# 撤销
u
# 撤销重做
Ctrl + r
# 复制
yy
# 删除当前行及之后所有行
dG
~~~

---

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

---

# Python

---

~~~python
import sys
print(sys.argv[0])
print(sys.argv[1:])
print(sys.argv)
print(type(sys.argv))

python sys.py haha ouha hehe
~~~

文件读取F1，F2，F3; 写入out; 读取后直接file1=F1.read()，anno=file.split()



## 字典

~~~python
print(dict)
# 二者相等? 值，类型
print(list(dict))
print(dict.keys())
~~~

读取一个文件内容，如何去除空行



## Pandas

替换脚本中繁琐的循环，改成 [Pandas](https://www.runoob.com/pandas/pandas-intro.html)；需要在 VsCode 中安装 Jupyter 扩展



### 读取文件

~~~python
import pandas as pd

df = pd.read_csv(
    "file.txt",
    sep = "\t",
    header = 0,	# 以第 0 行作为表头；不用则为 None
    skiprows = 3,	# 跳过行的数量
    index_col = ["Chr"]	# 这样会看着奇怪，除[2, 1]外其余第二行其余元素为空，应该有设置方法；也可以用索引
)
~~~



### 排序

~~~python
# 按 Length 列升序排列，默认升序
df = df.sort_values(by = "Length", ascending = True)
# 按 Length 列降序排列
df = df.sort_values(by = "Length", ascending = False)
~~~



### 数据聚合

~~~python
# 根据
df.groupby(by = "Length")
~~~



## Jupyter



---

# 工具

---

## [Snakemake](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html)

**通配符**

1. 由输出反向推导输入以确定通配符的值
2. 自由选择字符或者使用 Python 也可，同一 rule 关联输入输出通配符相同即可
3. 输出为目录时，加函数 directory()，输入和 params 不可用；但一般目录不是实际输出，应此参数输出文件夹一般放在 params 中

**运行**

1. 输出文件不含通配符的 rules 被执行时，若输入含通配符，必须指定通配符的值？
2. ==中间规则改变，被影响的所有 rules 都会重新运行==
3. 如果手动终止运行，会产生锁文件`snakemake --unlock`即可解除
4. 不要用 script 代替 shell，尽量不改变原脚本运行方式
5. 修改了参数，但是不影响结果或者不想重新运行，`snakemake --cleanup-metadata {outputfile}`

**命令与参数**

~~~bash
--forceall	# 全部强制执行
--forcerun	# 好像没啥用
--cores all	# 设置几都跑慢
# threads 不是越多越好，最好多任务，小线程，找到每个软件最佳线程数

--dag | dot -Tsvg > dag.svg	# 画图
~~~

**规则**

~~~bash
# 输入输出有文件夹
rule multiqc_fastp:
	input:
		dir=directory("analysis/1.QC/json")
	output:
		dir=directory("analysis/1.QC/stats/")
	log:
		"log/1.QC/multiqc.log"
	shell:
		"multiqc {input.dir} --filename multiqc_fastp --outdir {output.dir} 2> {log}"
~~~

**模板**

~~~bash
# Ctrl + shift + p，搜索配置代码片段，新建，名字添 Snakemake。粘贴下列代码
{
	// Place your snippets for snakemake here. Each snippet is defined under a snippet name and has a prefix, body and 
	// description. The prefix is what is used to trigger the snippet and the body will be expanded and inserted. Possible variables are:
	// $1, $2 for tab stops, $0 for the final cursor position, and ${1:label}, ${2:another} for placeholders. Placeholders with the 
	// same ids are connected.
"Snakemake Script/Single": {
    	"prefix": "rule-single",
    	"body": [
        	"rule ${1:rule_name}:",
        	"    input:",
        	"        \"${2:path/to/input}\"",
        	"    output:",
        	"        \"${3:path/to/output}\"",
        	"    log:",
        	"        \"${4:log/to/log}\"",
        	"    threads: ${5:1}",
        	"    shell:",
        	"        \"${6:command} {input} {output} > {log} 2>&1\"",
        	"$0"
    	],
    	"description": "Snakemake Single Shell"
	},	
"Snakemake Multiple": {
		"prefix": "rule-multiple",
		"body": [
			"rule ${1:rule_name}:",
			"    input:",
			"        \"${2:path/to/input}\"",
			"    output:",
			"        \"${3:path/to/output}\"",
			"    log:",
			"        \"${4:log/to/log}\"",
			"    threads: 1",
			"    shell:",
			"        \"\"\"",
			"        ${5:command} {input} {output} > {log} 2>&1",
			"        \"\"\"",
			"$0"
		],
		"description": "Snakemake Multiple Shell"
	},
}
~~~

**难点**

1. 双端测序数据建立软链接，以及单端测序建立软链接以及后续质控和比对的参数设置问题
   AI 说能在规则中用 if_else，判断语句

---

## VSCode

~~~bash
# 修改视窗大小不要 Ctrl + / -，容易触发 BUG，直接要修改配置文件
"terminal.integrated.fontSize": 18,
"editor.fontSize": 18
~~~

---

## IDM

下载很快但需激活，Github 有脚本可跳激活 https://github.com/WindowsAddict/IDM-Activation-Script

---

## IGV

---

## SRA

**Sequence Read Archive** 是 NCBI 存储高通量测序数据的数据库，框架包含四种概念。其中 Study 代表研究研究课题；Experiment 代表实验，可含有一个或多个 Sample；Sample 代表样本信息；Run 代表下机的测序数据，是最小概念；accession number 开头第一个字母包含 S E D 分别代表 NCBI(SRA) EBI DDBJ、第二个字母固定为 R 代表 Read、第三个字母包含 P X S R 分别代表 Project / Study Experiment Sample Run，下载时使用 SRR 号；[知乎大佬](https://zhuanlan.zhihu.com/p/493358239?s_r=0)

**下载方法**

~~~bash
# 1.1 sra-tools 直接下载 sra 后缀文件
prefetch SRR3624173

# 1.2 获取 sra 文件下载路径，wget 或 IDM（推荐，开小日本VPN加速） 下载
srapath SRR3624173
wget https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR3624173/SRR3624173

# 2 下载结果为 SRR3624175.man（和 sra 只是后缀不一样，不用管），转化为 fastq；多个样本并行运行即可
fastq-dump --gzip --split-3 SRR3624125.man
~~~

---

## 脱靶位点



CRISPR-Cas9 系统原理：**1.切割外源 DNA 片段并插入自身基因组 CRISPR 区域**。Cas1 / Cas2 蛋白识别外源 DNA 片段中的 PAM 序列并选择其上游的 DNA 作为候选原型间隔序列，Cas1 / Cas2 蛋白复合体切割候选原型间隔序列，并在其他酶的协助下将这些序列插入到 CRISPR 序列的启动子的下游



[参考文章](https://zhuanlan.zhihu.com/p/137760447)

https://zhuanlan.zhihu.com/p/539819746

https://zhuanlan.zhihu.com/p/645806380

http://www.rgenome.net/cas-offinder/result?hash=3e082c86a072c93b80eecfa2504ba2cd

https://zhuanlan.zhihu.com/p/668984590

https://cctop.cos.uni-heidelberg.de/

http://skl.scau.edu.cn/targetdesign/

**参考序列（随便写的）：CAGCAACTCCAGGGGGCCGCNGG**



**CRISPR-Cas**：某些细菌在遭受病毒入侵时，会将病毒 DNA 的一小段存入到 CRISPR 的序列中，当再次遭受该病毒入侵时，会根据存储的 DNA 片段识别并切断病毒 DNA 使之失效；该系统包含 CRISPR 基因座和 Cas 基因（CRISPR 关联基因）两部分；**CRISPR（Clustered Regularly Interspersed Short Palindromic Repeats，成簇规律性间隔短回文重复序列）**由**前导序列（leader）**、**重复序列（repeat）**、**间隔序列（spacer）**构成。前导序列位于 CRISPR 基因上游，富含 AT 碱基，被认为**是 CRISPR 的启动子**；重复序列是 25-50 bp 包含 5-7 bp 回文序列的核苷酸序列，转录产物形成发卡结构，**可稳定 RNA 的二级结构**；间隔序列是被细菌**俘获的外源 DNA 序列**，当外源遗传物质再次入侵时，CRISPR-Cas 系统就会精准识别；**Cas 基因**分布于 CRISPR 基因附近或基因组的其他地方，Cas 基因产生的蛋白质都可以于 CRISPR 基因发生相互作用，因此命名 CRISPR 关联基因（CRISPR associated，Cas）

Cas 基因编码的蛋白在防御过程中产生至关重要的作用，根据 Cas 蛋白的作用方式分为两大类
Ⅰ：切割外源核酸的蛋白是多个 Cas 蛋白的复合物，有 Ⅰ型、Ⅲ型、Ⅳ型
Ⅱ：切割外源核酸的蛋白是单个 Cas 蛋白，包括 Ⅱ型 Cas9 蛋白和 V型 Cpf 蛋白；被最广泛应用的就是Ⅱ型 CRISPR-Cas9 系统



### CRISPR-Cas9 作用机理

**1.CRISPR 间隔区的获得**：将外来噬菌体或质粒的 DNA 片段整合到宿主菌的基因组之中，整合到 CRISPR 区域的 5` 端的两个重复序列之间。新间隔序列的获得可能为三步：Cas1 / Cas2 蛋白扫描整体 DNA 序列，寻找 PAM 区域（三个碱基，NGG）并将其附近的 DNA 片段作为候选原型间隔序列；Cas1 / 2 复合物将外源 DNA 原型间隔序列剪切下来，并在其他酶的辅助下将切割下来的区域插入到前导序列的下游；DNA 修复使打开的双链缺口闭合得到一段包含间隔序列的 CRISPR 序列

**2.CRISPR 基因座的表达**：CRISPR 序列在前导序列的调控下，转录生成 pre-crRNA（crRNA，CRISPR RNA）以及与之互补 tracrRNA（trans-activating crRNA），pre-crRNA 与 tracrRNA 通过碱基互补配对形成 RNA 双链并与 Cas9 基因编码的蛋白形成复合体，该复合体能根据外来 DNA，选择对应的间隔序列片段（crRNA），并在核酸内切酶Ⅲ的作用下剪切该片段形成一段包含单一种类间隔序列和部分重复序列的短小 crRNA 序列

**3.CRISPR-Cas9 靶向干扰**：Cas9 蛋白、crRNA、tracrRNA 的复合体扫描外来 DNA，并识别与 crRNA 互补的原型间隔序列，然后复合体定位到 PAM / 原型间隔序列区域并打开 DNA 双链，形成 R-Loop 区域，crRNA 与互补链配对同时非互补链游离在外；Cas9 蛋白切割位点在 PAM 区域上游三个核苷酸的位置，切割产生平末端，Cas9 蛋白的 HNH 结构域负责切割与 crRNA 的互补链，Cas9 蛋白的 RuvC 结构域负责非互补链，最终在 Cas9 蛋白的作用下，外源 DNA 双链断裂（DSB），表达被沉默，外源入侵被消灭



CRISPR-Cas9 作用机理：
Cas1/2 蛋白扫描外源 DNA 片段，寻找 PAM 区域并将其附近的 DNA 序列作为候选原型间隔序列，Cas1/2 蛋白复合体切割原型间隔序列，并在其他酶的协助下将该片段插入到 CRISPR 前导序列的下游，然后 DNA 修复使双链闭合，形成包含外源间隔序列的 CRISPR 序列的基因组
CRISPR 序列在前导序列的调控下，转录生成 precrRNA 和 tracrRNA，这两个互补配对并于 Cas9 蛋白形成复合体，复合体扫描外源 DNA，并能根据原型间隔序列找到 crRNA 对应的间隔序列，在核糖核酸酶Ⅲ的作用下，切割对应间隔序列形成一段包含单一种类间隔序列和部分重复序列的短小 crRNA
复合体定位到外源 DNA 的 PAM / 原型间隔序列并打开 DNA 双链，形成 R-Loop，crRNA 与互补链配对，非互补链有利在外；Cas9 蛋白的切割位点位于 PAM 区域上方三个核苷酸位置，并形成平末端，Cas9 蛋白 HNH 结构域切割互补链，Cas9 蛋白的 RuvC 结构域切割非互补链，最终在 Cas9 蛋白的作用下 DNA 双链断裂（DSB），表达被沉默，入侵被消灭



**要求**

1. 做一个通过 CDS 区域和确定的 PAM 就能找到可能的 sgRNA 序列及其在基因组中的脱靶位点的网站
2. 修改基因组为我们大豆 Glycline max V2.1
3. 自定义打分矩阵
4. 输出结果自定义
5. 做成网站形式



http://skl.scau.edu.cn/targetdesign/result/ 这个网站看不懂，回去好好研究下



**（Cas9 蛋白为例）以 Cas-offfinder 本地版本为基础，添加识别 PAM 和 sgRNA，引入打分矩阵等**

1. 将 CDS 序列比对到基因组上确定详细染色体位置
   目的？参考网站这么做的目的？AI 为啥同意？
2. 给定 CDS 序列，规定 PAM 及端侧位置，规定 sgRNA 的长度，正负链都匹配，输出候选 sgRNA 序列
3. 通过本地 cas-offinder，由序列和基因组文件以及 mismatch 数量，找出算法上所有可能的脱靶位点；同时由第一步比对信息得到真正的脱靶位点
4. 联合脱靶位点和 sgRNA 碱基错配打分矩阵及规定的 PAM 的打分矩阵，对 sgRNA 的每个脱靶位点打分，并根据得分筛选合适序列

~~~bash
# 1.输出所有候选 sgRNA 序列
python sgRNA_from_CDS.py \
  -i cds.fa \
  -o candidate_sgrna.tsv \
  --pam NGG \
  --pam-side 3prime \
  --guide-len 20
  
# 2.运行本地 cas-offinder，找所有可能脱靶位点
cas-offinder target_seq.txt C out.txt

awk -F '\t' '$6==0{count[$1]++} END{for(i in count) print i,count[i]}' out.txt | sort -k2,2nr | head -n 29 >poor.txt	# mismatch 大于 1 个的所有序列和数量

awk '{printf $1"|"}' poor.txt >wu.txt	# mismatch 大于 1 个的所有序列横向排列以被筛选

grep -v -i -E "TTCATCAAAGGTAACATGAATGG|ATTCATGAACAAGATTCCAAAGG|TATAGCATTAGATTCATCAAAGG|CTTGAAGTTTTCCATTCTCTTGG|TTGAAGTTTTCCATTCTCTTGGG|GTTTCCTTTGTCATTTCCTTTGG|GATTCCAAAGGAAATGACAAAGG|AATGAAGATCCTCCAGAAGAAGG|TTGGATTTGCCTTCTTCTGGAGG|TCATTGGATTTGCCTTCTTCTGG|ATGATGTACTCCCAAGAGAATGG|TTCTCTTGGGAGTACATCATTGG|AATTGGTGATATCTCAAAAGGGG|ATAATTGGTGATATCTCAAAAGG|TAATTGGTGATATCTCAAAAGGG|ATCACCAATTATGTTGTCGAGGG|CATCCCCTCGACAACATAATTGG|TATCACCAATTATGTTGTCGAGG|TCACCAATTATGTTGTCGAGGGG|TCTTGGATAGCTACTTTAATTGG|ACATTCAAGAAAATCTAGGATGG|CATGGCAGTTAACCACAACATGG|CTAGGATGGAAAATTGGATTTGG|GAAAATCTAGGATGGAAAATTGG|GATATGAACATTAGCAAAGCAGG|GGATTAATTTCTATTGGAGCTGG|GTGTACATTCAAGAAAATCTAGG|TGCTTTGCTAATGTTCATATCGG|TTGATCTGCTCCAAAGGCTATGG" out.txt > hehe.txt	# 第二步查到的所有序列，去除 mismatch 大于1个之后剩下的序列

# 3.
python score_cfd_casoffinder.py \
  --candidates /home/zhangxuejie/workspace/test/Step1.find_sgRNA/candidate_sgrna.tsv \
  --casoffinder /home/zhangxuejie/workspace/test/Step2.Cas-offinder/out.txt \
  --mismatch-score mismatch_score.pkl \
  --pam-score pam_scores.pkl \
  --detail-out offtarget_detail_cfd.tsv \
  --summary-out sgrna_cfd_summary.tsv \
  #--remove-one-perfect-match
~~~



[参考网站](http://skl.scau.edu.cn/targetdesign/)

1. 输入 CDS 序列后分别从 + - 两条链儿开始查找 PAM 及临近 DNA 序列



### Basic

**脱靶效应**：核酸酶在非预期的位点切割或修饰

**DSB（DNA Double-Strand Breaks）**：是最有害的 DNA 损伤之一，可能导致细胞死亡或基因组不稳定，从而导致癌变

**sgRNA（single guide RNA）**：向导 RNA；crRNA-tracrRNA 融合成 sgRNA，可以识别 PAM 序列，进而引导 Cas9 蛋白切割双链 DNA,形成双链断裂，损伤后修复可以造成碱基插入和敲除，从而达到修饰的目的

**PAM（Protospacer Adjacent Motif，原间隔相邻序列）**

**intron**：内含子

**exon（expressed region）**：外显子

intergenic：



### Question

- [x] http://www.rgenome.net/cas-offinder/result?hash=3e082c86a072c93b80eecfa2504ba2cd 这个网站好像是单纯的比对错配，没有实际数据支撑，仅仅是算法上预测
- [ ] 而且设置两个隆起时，推测出的序列两个隆起必须在一起，不能分开两旁
  如果分开两旁，意味着在同一条序列上的两个切割位点，好像不太可能哦
- [x] 给定一段 on-target sequence，设置 mismatch 后，如何在全基因组中搜索？http://www.rgenome.net/cas-offinder/result?hash=3e082c86a072c93b80eecfa2504ba2cd 下载离线版本，研究学习代码看如何用 C++ 等运行的
  直接下载离线版本，运行即可
- [x] 哔哩哔哩脱靶效应视频中，有设计 sgRNA 每个位点进行三种突变以研究不同突变与脱靶比率之间的关系，我司可据此效仿研究
  其他方向，不做研究
- [ ] 为啥人也会有脱靶位点，不是细菌和古细菌才有吗
- [ ] 研究参考网站结果每一行代表什么
- [ ] 参考网站将每一条序列可能的脱靶位点序列列出来，而且 PAM 序列也有可能脱靶，那样的话就太多了吧

---

## [Django](https://docs.djangoproject.com/zh-hans/5.2/intro/tutorial01/#top)



### Basic

**[API](https://zhuanlan.zhihu.com/p/347125981)（Application Programming Interface，应用程序之间的接口）**：提供输入后给出输出的复杂函数，用于程序间相互通信

**[URL](https://zhuanlan.zhihu.com/p/352034056)（Uniform Resource Locator，统一资源定位）**：协议 + 主机名 / 目录名 / 文件地址

**HTTP（Hyper Text Transfer Protocol，超文本传输协议）**

**WWW（World Wide Web，万维网）**



### Question

- [ ] 第一个教程 polls 创建好后，打开的 URL 地址还是原来的 http://127.0.0.1:8000/，而不是 http://localhost:8000/polls/

---

# Pipeline

---

## 质控

测序多个样本凑一条 lane 跑，通过接头 Index_i5 Index_i7 不同的组合区分不同样本，用于下机拆分样本

adapter 用于质控时的接头？

~~~bash
# ln(link files) -s 创建软链接, 链接指向源文件
~~~

~~~bash
# fastp SE(Single-End Sequencing); PE(Paired-End Sequencing)
~~~

~~~bash
# md5sum 生成文件在网络传输前后的md5值(只与文件内容有关), 根据前后值判断文件内容传输过程是否变化
~~~

~~~bash
# multiqc 识别 json 生成总文件
~~~



### Question

- [ ] 不同格式文件要将文件内容复制到另一种格式中，不能直接改名字，否则会出现不可控错误
  批量修改文件名，尤其如何批量输出

~~~bash
-rwxrwxr-x 1 zhangxuejie bioinfo 425861587 Mar 12 12:05 'P9_40d_R2.fq.gz'$'\r'*
-rwxrwxr-x 1 zhangxuejie bioinfo 402502035 Mar 12 12:05 'P9_55d_R1.fq.gz'$'\r'*
-rwxrwxr-x 1 zhangxuejie bioinfo 425828469 Mar 12 12:05 'P9_55d_R2.fq.gz'$'\r'*
~~~

- [x] 小 RNA 质控的数据名称只能是 WR2243M01.fq.gz 样式，若是 WR2243M01_R1.fq.gz 的会出错
- [ ] conda 安装包报错 "fastp1.1.*.*"，由于 conda 解析包名出错导致，下载 mamba 代替 conda
- [ ] 

---

## 有参转录组分析

0. 改名：测序名称 → 样本名称
1. 质控：**fastp** 过滤低质量 reads 和测序接头
2. 比对：**hisat2-build** 对基因组 fasta 建索引输出 **8个ht2** 结尾的文件；**hisat2** 比对质控后的序列到基因组索引，输出的 **sam** 文件被**samtools** 排序后转换输出 **bam** 文件
3. 量化：**subread** 软件下 **featureCounts** 对排序后 bam 量化，生成



### 步骤

**1.QC**

**2.Mapping**

~~~bash
hisat2
~~~

**3.GenesExpress**

~~~bash
# featureCounts
~~~

**4.diffExprGene**

~~~bash
# DESeq2

~~~





### Basic





### Question

- [ ] 质控 md5sum 这一步无效，可以删除

~~~bash
md5sum /data0_2/2026_03/SunNan_15_ren_QC/analysis/1.QC/raw/*gz|awk -F'/' '{print$1, $NF}'|awk -F' ' '{print$1, $NF}' > /data0_2/2026_03/SunNan_15_ren_QC/analysis/1.QC/raw/rawdata_md5.txt
~~~

- [ ] hisat2 比对率低，试试 star；分析下区别还有 bowtie2

~~~bash
STAR --runThreadN 12 --runMode genomeGenerate --genomeDir /data/users/minmingw/Alignment/index --genomeFastaFiles /data/users/minmingw/Alignment/hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa --sjdbGTFfile /data/users/minmingw/Alignment/hg38/Homo_sapiens.GRCh38.103.gtf
~~~

- [ ] SAM 和 BAM 文件区别

- [ ] featureCounts 以 GTF 和 GFF 分别做注释统计 exon 的到的 Counts 数相同；统计 gene 的 Counts 数不同，应是 GTF 文件将 GFF 特征为 ncrna 等的都转化为 gene，但是计数应该更高啊，因为基因多了，为啥比同条件下 GFF 更低呢？需了解计数原理，应该是按照坐标统计的

- [ ] GO 和 KEGG 富集分析选择差异基因的参数是 pvalue 但好像通用的是 padj

- [ ] 下载 KEGG 通路图必须开 VPN，服务器可以，是默认开 VPN？~~

- [ ] 富集分析 clusterProfiler 服务器版本 4.6.2，本地 4.18.4；导致输出的富集分析的文件结果列数，新版多了3列

- [ ] R 脚本排版混乱，命名混乱，注释不足；后期要统一；同时最好使用 python-pandas 处理数据，R-ggplot2 只负责作图

- [ ] rmats --readLength 服务器是 149，应该为 150~~
  149 会将 reads 数小于 149 的过滤掉；测试发现会过滤掉绝大部分

- [ ] Step9 总文件根本没有 2.mapping/hisat2_sorter.bam 这个文件，本地要报错，服务器不报错；echo，rmatsplot 的参数都要改

- [ ] rmatsplot 服务器和本地版本一致，但是本地 python3 缺少了某个模块；服务器是 python2

- [ ] Step 10 rush 改为 parallel，后者用的人很多
- [ ] 基因组和注释文件选择问题，以及不同软件的匹配度相关性
- [ ] Functional_annotation.conf 是干嘛的，分类号在 miRNA 第四步 RepeatMasker 使用替代了 species，好像更快
- [ ] NCBI 分类号，怎么查，用在流程哪个地方
- [ ] gene_type SYMBOL；Species mmu 这俩干嘛用的
- [ ] 有参转录组第七步蛋白互作，有问题



### 基因课

1. 比对到参考基因组：数据准备
2. 表达定量：对数据计数
3. 归一化：统一标准
4. 差异分析-火山图、热图：看基因是上调还是下调
5. 富集分析-GO、KEGG：关注的基因参与了什么功能
6. 聚类分析：探索样本间关系，锁定变化的关键样本
7. 相关系数：又分为组间相关系数和组内相关系数
8. 聚类分析和 WGCNA：模块构建-性状与模块相关分析-鉴定主要基因



#### 数据准备

~~~bash
# 配置文件，脚本
cp -r /Data_all/script/Reference_transcriptome/V1/{bin/,cmd,Transcriptome.conf}

# 修改配置文件
数据库路径 /Data_all/GenomicDatabases/Mouse/
数据库版本 Mus_musculus.GRCm39.113
基因组 /Data_all/GenomicDatabases/Mouse/Ensembl/genome.fa
注释 /Data_all/GenomicDatabases/Mouse/Ensembl/genome.gtf
功能注释 /Data_all/GenomicDatabases/Mouse/Ensembl/Functional_annotation/ #包含各种蛋白数据库
id_name /Data_all/GenomicDatabases/Mouse/Ensembl/gene_name.txt #名字与id对应表
taxonomy 10090 #NCBI 分类号
gene_type SYMBOL
Species mmu
~~~

**可变剪切**

|      |                           |                |
| ---- | ------------------------- | -------------- |
| SE   | Skippedexon               | 外显子跳跃     |
| A5SS | Alternative5' splice site | 5’端可变剪切   |
| A3SS | Alternative3' splice site | 3’端可变剪切   |
| MXE  | Mutually exclusive exons  | 互斥可变外显子 |
| RT   | Retainedintron            | 内含子保留     |



**表型差异缘由**

DNA：SNP、InDel（插入和缺失）、SV-Structural Variation（倒位）、甲基化

RNA：可变剪切（外显子跳跃和内含子保留）、差异表达、修饰

Protein：丰度差异、折叠方式差异

**归一化**

count 受 基因长度、测序深度的影响

RPKM / FPKM：（count / length） / all_reads
不对的，all reads 也会受到基因长度的影响

TPM：（count / length） / sum(count / length)
正确，消除了基因长度和基因深度的影响

TMM：假定大多数没有发生差异变化，避免单一基因过度影响整体基因

**差异表达**

FC-Fold Change（变化倍数）：实验组的平均表达量与对照组的平均表达量的比值
FC = 2，即实验组表达超对照组一倍；FC = 0.5，即实验组表达是对照组一半

logFC（log~2~FC）：方便比较将 FC 统一取2对数
logFC > 0代表上调，logFC < 0代表下调；logFC = 1即实验组表达超对照组一倍，logFC = -1即实验组表达是对照组一半

pvalue：一次检验矫正，即检验一个样本的错误率是0.05是可接受的；要组内差异小，组间差异大

FDR：多重检验矫正，当样本过多时0.05错误率是不可接受的，所以需要更加小的值来检验

**富集分析**

富集：通过富集的基因在reads上的比例比较基因组中该基因的比例来比较

~~~bash
# 下载测序数据
conda install bioconda::sra-tools = 3.4.1
prefetch SRRxxxxx
awk '{print "prefetch "$1" &"}' SRAxxxx.txt
fastq-dump --split-3 SRRxxxxx.sra

# 下载参考基因组
cat gene.chr*.fasta > genome.fasta

# 下载基因组注释 gff3 利好人; gtf 利好软件. 将 gff3 转换为 gtf
gffread -T -o gene.gft gene.gff3
~~~

#### 1.Mapping

~~~shell
# step1.hisat2_build.sh
hisat2-build ../ref/genome.fasta ../ref/genome 1>hisat2-build.log 2>&1

# step2.run_hisat.sh
hisat2 --new-summary -p 8 -x ../ref/genome -U ../data/BLO_S1_LD2.fq.gz -S BLO_S1_LD2.sam --rna-strandness R 1>BLO_S1_LD2.log 2>&1
# 批量生成脚本
awk '{print "hisat2 --new-summary -p 8 -x /home/zxj/genome -U "$3" -S "$2".sam --rna-strandness R 1>"$2".log 2>&1 &"}' ../data/samples.txt

# step3.sam2bam.sh
samtools sort -o BLO_S1_LD2.bam BLO_S1_LD2.sam

# step4.bamindex.sh
samtools index BLO_S1_LD2.bam
rm *.sam
~~~

#### 2.Quantification

~~~R
#!/usr/bin/env Rscript
# parse parameter ---------------------------------------------------------
library(argparser, quietly=TRUE)
# Create a parser
p <- arg_parser("run featureCounts and calculate FPKM/TPM")

# Add command line arguments
p <- add_argument(p, "--bam", help="input: bam file", type="character")
p <- add_argument(p, "--gtf", help="input: gtf file", type="character")
p <- add_argument(p, "--output", help="output prefix", type="character")

# Parse the command line arguments
argv <- parse_args(p)

library(Rsubread)
library(limma)
library(edgeR)

bamFile <- argv$bam
gtfFile <- argv$gtf
nthreads <- 1
outFilePref <- argv$output

outStatsFilePath <- paste(outFilePref, '.log', sep = '');
outCountsFilePath <- paste(outFilePref, '.count', sep = '');

fCountsList = featureCounts(bamFile, annot.ext=gtfFile, isGTFAnnotationFile=TRUE, nthreads=nthreads, isPairedEnd=TRUE)
dgeList = DGEList(counts=fCountsList$counts, genes=fCountsList$annotation)
fpkm = rpkm(dgeList, dgeList$genes$Length)
tpm = exp(log(fpkm) - log(sum(fpkm)) + log(1e6))

write.table(fCountsList$stat, outStatsFilePath, sep="\t", col.names=FALSE, row.names=FALSE, quote=FALSE)
~~~

---

## miRNA

miRNA 入手分析 small RNA：占比大；易建库；公共数据库维护好；生信分析快且容易

1. 质控：原始 fastq 数据
2. 去接头、质控
3. 筛选 18–30 nt 小 RNA
4. 去除 rRNA/tRNA/snRNA/snoRNA/repeat
5. 比对参考基因组
6. 已知 miRNA 鉴定
7. novel miRNA 预测
8. miRNA 表达量统计
9. 差异表达分析
10. 靶基因预测
11. GO/KEGG 富集
12. miRNA-target 调控网络



### miRDeep2

**mapper.pl**

成熟 miRNA 是 22nt，没有二级结构，要根据二级结构预测miRNA，就要找到有发夹结构的 miRNA 前体

**gfold**：广义 Fold Change 对 RNA-Seq 中的差异表达基因排序，无重复时尤其适合

**quafiler.pl**



### Basic

**small RNA（小 RNA）**：长度18-40 nt，起转录后调控作用的非编码 RNA

**3’UTR（3’ UnTranslated Region）**：成熟 mRNA 分子中在终止密码子后，PolyA 前的非翻译区

**HairPin（发夹结构）**：DNA、RNA中的单链核酸碱基配对部分形成 “茎”，没有配对部分形成 “环”

**mRNA（messenger RNA，信使 RNA）**：

**rRNA（ribosomal RNA，核糖体 RNA）**：

**tRNA（transfer RNA，转运 RNA）**：

**snRNA（small nuclear RNA，核小 RNA）**：负责 mRNA 前体的加工

**snoRNA（small nucleolar RNA，核仁小 RNA）**：指导 rRNA、tRNA、snRNA 的化学修饰

crRNA（）

**piRNA（）**：特异性 piwi 蛋白结合发挥作用



### Question

- [ ] 当前版本 miRNA 前提序列和成熟序列都太老旧，已知 miRNA 定量时 miRDeep2.pl 参数要加 -P，预测可以不用
  但是，第六步，加了 -P 后，将加 -P 前后的两个表合起来，总共470行，排序去重后，还有370行，说明有问题
- [x] gfold 运行报错：error while loading shared libraries: libgsl.so.0: cannot open shared object file: No such file or directory
  在环境目录下 lib 文件夹：ln libgsl.so.25.1.0* libgsl.so.0 即可成功，后续出问题需注意！
- [ ] conf 文件 DB_version Soybean 有好多个
- [ ] gene_descript 这个是啥，没查到
- [ ] 物种缩写之类的有官网查吗；物种的数字编号是啥，用脚本说模块没有，环境不对
- [ ] ncRNA_TargetGene_analysis = false 这步是默认非吗
- [ ] Step_4_RepeatMasker.sh 运行过慢
  该软件分两步，第一步比对，第二部整理结果；慢的是第二步，可拆分数据，分成多个小份，先串行跑比对，然后并行跑整理，最后合并结果
  拆分会造成重复序列出现在不同的小份数据中，整理后会出现同一序列出现多次在 repeat 的地方 
  搞不懂不去重跑一个样本，和分成小份有啥区别

---

## Metagene

0. 改名：下机名称 → 样本名称
1. 质控：**fastq** 过滤低质量 reads 和测序接头；**kneaddata** 过滤重复序列
2. 组装：**megahit** 组装经过滤及去重后的测序文件，输出 **fasta** 文件；**quast** 评估组装结果
3. 预测：**prodigal** 通过起始密码子和终止密码子预测**开放阅读框**，进而反向从 fasta 文件中寻找可能 DNA 和蛋白质
4. 聚类：**mmseqs** 对上述预测的 **DNA** 进行聚类，输出有不同类中有代表的基因，再关联4中预测的 DNA 和蛋白以备后续分析输入
5. 丰度：**metaphlan** 将**质控过滤去重后的序列**比对到数据库，输出所有样本界门纲目科属种的丰度表
6. 功能：**diamond** 将蛋白质或基因 **blast** 到不同数据库，输出 outfmt 6，注释含有什么不同的功能
7. 量化：**salmon** 对**质控去重的测序数据**进行量化输出基因表达表；再进行 α-多样性和 β-多样性（PCA分析）以及后续的 GO、KEGG富集分析



**kneaddata**

~~~bash
# --trimmomatic [PATH]
which trimmomatic #/home/zhangxuejie/miniconda3/envs/Metagene/bin/trimmomatic
## 参数为 /home/zhangxuejie/miniconda3/envs/Metagene/share/trimmomatic-0.40-0/
~~~

**kneaddata_read_count_table**

~~~bash
# 生成的报告 stat，第一列按制表符分割，不知是否会影响报告
#Sample	raw	pair1	raw	pair2	trimmed	pair1	trimmed	pair2	trimmed	orphan1	trimmed	orphan2
~~~

**为什么要组装**

|            | 不组装                | 组装                                       |
| ---------- | --------------------- | ------------------------------------------ |
| 数据库比对 | 150bp，不能精确到物种 | 长片段，可精确比对                         |
| 聚类分析   | 各自为阵，没法看联系  | 联合分析同一类细菌的某个共同基因作用       |
| 完整性     | 基因片段              | 包含起始和终止密码子的完整基因，可分析功能 |

### 2.Megahit

~~~bash
# megahit
## k-mer 从一条 DNA 片段中连续截取的, 长度为 k 的核苷酸子序列
## --presets meta-large 参数设置后, --k-list, --k-step 都被固定, 即使后面再加参数也不能修改
## --no-mercy <do not add mercy kmers> 舍弃因低丰度而被过滤 k-mer, 严格执行固定的频率, 同时丢失部分错误过滤的基因组
~~~

**quast(quality assessment tool for genome assemblies)**

### 3.ORF_Prediction

~~~bash
# 预测的核苷酸和蛋白质序列终止位置不一定时终止密码子, 其允许预测未组装完整的基因序列
~~~

**MMseqs2: ultra fast and sensitive sequence search and clustering suite**

**metaphlan: metagenomic phylogenetic analysis for metagenomic taxonomic profiling**

### 6.Functional_Annotation

**Card**

输出表要不同的ARO号, 相同的舍弃

~~~bash
## -t --tabs <specifies that the input CSV file is delimited with tabs. Overrides "-d">
## -f, --fields string <select only these fields>

python /Data_all/script/Metagene/bin/Card_function.py /Data_all/Databases/Card_data/aro_index.tsv /data2/2026_03/New_test/6.Functional_annotation/Card/Card_tmp_1.txt /data2/2026_03/New_test/6.Functional_annotation/Card/Card_function.txt
~~~

**eggnog-mapper: Fast genome-wide functional annotation through orthology assignment**

### 7.Gene_Quantify

[salmon](https://salmon.readthedocs.io/en/latest/salmon.html)

~~~bash
# quant: quantifies expression using raw reads
## -l --libType <Format string describing the library type> 与文库有关, 链特异性和非特异性等, A Auto 自动检测

# alpha_diversity: 对样品丰度和多样性分析
## shannon	simpson	Richness	chao1	ace	observed_features	pielou_e	goods_coverage
## shannon <综合考虑物种丰富度和均匀度，对稀有物种敏感>
## simpson <更关注优势物种，赋予常见物种更高权重>
## Richness <群落中物种（或特征）的总数，常指观测到的丰富度>
## chao1 <基于稀有种（单例、双例）估算群落总丰富度的非参数方法>
## ace: Abundance-based Coverage Estimator <另一类基于丰度分布的非参数丰富度估计量>
## observed_features <在样本中实际观测到的特征（OTU/ASV）数量，即实测丰富度>
## pielou_e <衡量群落中物种个体数分布的均匀程度，是 Shannon 指数与最大可能 Shannon 值的比值>
## goods_coverage <测序深度覆盖度，表示群落中已被测序到的物种占总物种的比例估计>
~~~

~~~bash
# beta_diversity: 样本多维数据降维
# PCA: Principle Component Analysis
# PCoA: Principle Co-ordinates Analysis
# NMDS: Non-metric Multidimensional Scaling
~~~



### Basic

**Gene**：携带遗传物质的 DNA 或 RNA



### Question

- [ ] awk 挑选在排序相比于 csvtk cut + awk 分别负责挑选和排序慢很多

~~~bash
awk -F "\t" '{print$2"\t"$1"\t"$3"\t"$4}' 1.txt > 2.txt
csvtk cut -t -f 1.2.3.4 1.txt | awk -F "\t" '{print$2"\t"$1"\t"$3"\t"$4}' > 2.txt
~~~

- [ ] megahit 对同意测序文件组装的同一个基因起始不同

~~~bash
# --presets meta-large 定制了一系列参数，会使自定义 --k-skip 等参数失效
megahit --presets meta-large 
~~~

- [ ] kneaddata 新版本将重复序列也去除了，而且它再一次去除了接头和低质量 reads

- [ ] sort 的排序问题需要加 -s，不然 -k 1 后还会默认按后续列继续排序

- [ ] alpha_diversity 没有 Richness 的图

- [ ] 失败，本地电脑不好搞宏基因组组装
  服务器也是一天一个样本

---

## ATAC



### 原理

**染色质与染色体结构**：8个由 DNA 缠绕的组蛋白形成约 147 bp 的串珠状的核小体，同一条 DNA 上的核小体经过折叠、聚合在其他架构蛋白的帮助下形成染色体

**开放染色质与染色质可及性**：基因转录时，染色体通过组蛋白修饰（乙酰化）将待转录区域打开，打开后的区域就叫开放染色质；染色质打开后就允许一些调控蛋白（如转录因子）与之结合，称为染色质可及性，这反映了调控蛋白与染色质结合的状态，与转录调控密切相关

[ATAC-Seq（Assay for Transposase-Accessible Chromatin with high throughput Sequencing）](https://zhuanlan.zhihu.com/p/512163334)对携带NGS接头的转座酶剪切后的样本进行测序就知道哪些序列

根据转座酶容易结合开放染色质的特性，人为的将 NGS 标签连接到 Tn5 上，携带接头的 Tn5 进入细胞核后，在开放染色质随意切割并将接头插入到切割位点，这样开放染色质区域就包含大量的NGS 接头，把细胞破碎后提取 DNA 然后根据已知 NGS 接头进行测序，就可以知道哪些开放染色质区域容易结合调控蛋白

https://www.jianshu.com/p/e8f236a98613



### Basic

**TSS（Transcription Start Sites，转录起始位点）**：DNA 链上与 RNA 链第一个核苷酸对应的碱基

**TES（Transcription End Sites，转录终止位点）**：

**DNA 转座**：由 DNA 转座酶介导的将 DNA 序列从染色体的一个区域插入到另一个区域的现象

~~~bash
/data3/Data_all/Software/miniconda3/bin/computeMatrix scale-regions -S Z733-2_bowtie2_sort.bigwig Z733-1_bowtie2_sort.bigwig  -R /data3/2026_05/XuTuo_2_MaGuZi_ATAC/ref/gene.bed -b 3000 -a 3000 -out Matrix.txt.gz --binSize 150 --regionBodyLength 4500 -p 40 --missingDataAsZero --metagene
/data3/Data_all/Software/miniconda3/bin/plotHeatmap -m Matrix.txt.gz --samplesLabel Z733-2 Z733-1  -out TSS_Heatmap.png --heatmapHeight 12 --heatmapWidth 5 --regionsLabel 'Genes' --startLabel TSS --endLabel TES --yAxisLabel 'ATAC signal' --colorMap YlGnBu --plotTitle 'Genes' --dpi 300
~~~



### Question

- [x] bw 生成 Matrix 的步骤，小于 bin size 的会过滤掉，现有信号图曲线会不平滑，考虑 bin size 设置大一点 1000；或者干脆不要过滤
  不要先默认 10 就可以
- [x] 拿 GTF 文件来做 computeMatrix
  拿 gene.bed 做，因为 GTF 包含 exon、gene、CDS 等，==ATAC 是关于基因的？==
- [x] ATAC 第三步 read_distribution.sh 不可以同时运行，他们会争抢阅读 tmp 和 基因组文件

---

## 无参转录组分析（芍药为例）

`/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome`

对于没有高质量参考基因组的物种，无参转录组组装通过对 RNA-Seq reads 进行图结构重建、直接恢复转录本，获得完整的转录本集合，芍药（凤丹 Paeonia ostii）的同属不同种 2025 年发布了参考基因组

0. 改名：测序名称 → 样本名称
1. 质控：**fastq** 过滤低质量 reads 和测序接头
2. 组装：**Trinity** **分别合并**样本的单端数据，构建 contig、生成结构图、最终生成新的**转录本**及基因和转录本**映射表**
3. 预测：**TransDecoder** 预测**最长开放阅读框**，将预测的蛋白 blastp Uniprot 数据库输出**比对信息表**，重新预测生成最终注释、蛋白和编码序列，根据最终注释文件过滤 Trinity 生成的转录本文件
4. 比对



### 转录本组装

**Trinity** 中三个独立的模块：**Inchworm**、**Chrysalis**、**Butterfly** 分别负责初始 contig 构建、图结构划分和最终转录本解析

**Trinity.fasta**

~~~bash
>TRINITY_DN31_c0_g1_i1 len=525 path=[1:0-201 2:202-230 3:231-524]
>TRINITY_DN31_c0_g1_i2 len=892 path=[1:0-201 2:202-230 4:231-891]

TRINITY_DN31_c0	# 对应基因
g1_i1	# 不同转录本
len=525	# 转录本长度
path=[1:0-201 2:202-230 3:231-524]	# 组装路径
~~~

==脚本：/data3/Data_all/script/Denovo_transcriptome/bin//gene_result_stas.py pandas 以及简短循环判断写的太好了，要认真学习==

~~~bash
# 物种 ko，则去除所有 kegg 编号，加上 ko；物种为 kegg 缩写，则选取所有 kegg 编号前缀相等的
/data3/Data_all/script/Denovo_transcriptome/bin//Enrichment_KEGG_id.py
~~~

### Variance Calling（变异检测）

SNP-Indel



### Question

- [ ] Step1.QC.smk：fastp 过滤啥东西

- [x] Step4.Mapping.sh：bowtie2 log 报错：[WARNING] Failed to launch x86-64-v3 version, staying with default
  修改总结脚本，其他流程若有要类似修改
  
- [ ] 第二步 Trinity 组装，如果要输入有改变，则需要删除 Trinity 已有结果的文件夹

- [ ] 第三步 TransDecoder 模块，如果输入有改变，也需要删除 TransDecoder 已有结果文件夹

---

## Phage_denovo

0. 改名：软链接下机名称 → 样本名称
1. 质控：**fastp** 过滤质量值大于 **15** 的碱基、质量合格率高于 **40%** 且长度大于 **15bp** 的读段
2. 比对：**bowtie2** 比对宿主基因组输出排序后 **BAM**，根据比对 **FLAG** 挑选 read1 和 read2 **都没有比对上**的去宿主序列
3. 组装：reformat 确定随机抽样去宿主序列交由 spades 进行组装，然后



### Question

- [ ] 第二步：使用`mamba activate vs2`需要 mamba 初始化，改成 conda 最好
  不对，只有这一步不要 vs2 环境，直接写 VirSorter2 的环境路径
  不行，这个软件需要 snakemake 多软件运行，必须进环境，但是下一步又必须出环境
- [ ] 这个环境 Python=3.8 后续安装 virsorter 要加上它的配置文件，总的配置文件来安装

---

## ChIP-Seq

https://zhuanlan.zhihu.com/p/512163334



### Basic

**ChiP（Chromatin Immunoprecipitation，染色质免疫共沉淀）**：ChIP-Seq 用于确定蛋白质和 DNA 的互作情况；包括 **TF ChIP** 和 **Histone ChIP**

**染色质**：真核生物在间期细胞核内由 DNA、组蛋白、非组蛋白和少量 RNA 组成的核酸蛋白复合体

---

## RIP



### Question

- [ ] samtools index

~~~bash
# 王道文 RIP 测序_20260604，由于索引长度过长，无法建立 bai 索引
[E::hts_idx_check_range] Region 536877267..536877401 cannot be stored in a bai index. Try using a csi index
[E::sam_index] Read 'E250146742L1C018R03903964548' with ref_name='Chr1A', ref_length=598660471, flags=99, pos=536877268 cannot be indexed
samtools index: failed to create index for "TaGW2IP1G_IP_sorted.bam": Numerical result out of range

# 建立 cai 索引
samtools index -c <sample_sorted.sam>
~~~

---

## Vector_detection





### Basic





### Question

- [ ] 

---

## 致病性位点检测





### Basic





### Question

- [ ] 第七步注释表：`head -n 13 cnv_outputfile_anno.txt|awk '{print $1,$2,$3,$4,$5,$6,$7,$21,$22,$31,$32,$34}'|ct -s ' '|le`
- [ ] 报告的 html 模板：`/Databackup3/2026_07/ZhuYaSha_1_human_WGS/analysis/5.Report/report.Rmd`

---

## Concept

**模式物种**：科学家为研究生命现象普遍规律而选定的生物，具有易于实验操作，遗传背景清晰（遗传特征简单？）等优点

**转录本**：由一条基因转录形成成熟 RNA 分子，包括编码蛋白质的 mRNA 和非编码 RNA（ncRNA）

**CircRNA（Circular RNA）**：mRNA前体反向剪接形成，由共价键连接，没有5'帽子和3'尾巴的闭合环状不编码 RNA，稳定不易降解

**RNA_denovo**：全转录组

**Metagene**：宏基因组，指以特定生物环境整体微生物群落作研究对象，通过高通量测序，获得的微生物基因信息的总和

**Contig**：基因组测序中由重叠 DNA 片段拼接形成的连续序列，是基因组组装的最小单元

**Scaffold**：测序获得的若干 reads，若能完全拼接，中间没有 gap，则拼接后的序列称 **contig**（连续）；若中间由 gap，但是知道 gap 的长度，则称 **Scaffold**（脚手架）；将 contig 和 scaffold 从长到短进行排列相加，相加长度到总长度一半时的 contig 或 scaffold 的长度即称为 **N50**，N50 越长代表组装质量越好

**Sequence Identity**：两条序列之间的相似程度

**PPI（Protein-Protein Interaction Networks）**：通过蛋白之间的彼此的相互作用构成，来参与生物信号传递、基因表达调控、能量与物质代谢和细胞周期调控等生命过程

==**ORF（Open Reading Frame）**==：DNA 或 RNA 序列中，从起始密码子开始，到下一个终止密码子结束的一段连续的核苷酸序列
从起始密码子（AUG）对应的序列（ATG）开始，三个碱基一组向后延伸，找到第一个终止密码子（UAG、UGA、UAA）对应的序列终止的连续序列，是理论上的蛋白编码区

**阅读框架**：DNA 或 RNA 从 5’→3’ 翻译蛋白质过程中，如 5'-ATGCAGCGTACTC-3'，分别以 ATG、TGC、GCA 三种三联体向后翻译称三种**阅读框架**；其中 ATG 为起始密码子的阅读框架被称为 **ORF**。但 **CDS** 可能是 TGC 的阅读框架，因为该阅读框架起始密码子可能在前面

==**CDS（Coding Sequence）**==：实际编码蛋白质的序列

**GSEA（Gene Set Enrichment Analysis）**：预估一个预定基因集的基因在与表型相关性排序的基因表中的分布趋势，以此来判断其对表型变化的贡献

**可变剪切（Differential Splicing）**：剪切未成熟 mRNA 的内含子，生成保留外显子的成熟 mRNA 的过程

**nt（ntcleotide，核苷酸）**：描述**单链核酸**中核苷酸的数量

**bp（base pair，碱基对）**：描述**双链核酸**中互补配对的碱基数量，每一对包含两个互补碱基（如 A-T）

**密码子**：mRNA 或 DNA 上三个连续的碱基，用于编码特定氨基酸

**SSR**（Simple Sequence Repeat，简单重复序列）：由 1~6 个核苷酸组成的短串联重复序列

**启动子（Promoter）**：结合 RNA 聚合酶转录特定基因合成 RNA 的 DNA 序列

**UTR（Untranslated Region，非翻译区）**：mRNA 编码区（CDS）两端的非编码片段

**组蛋白（Histone）**：是一种富含赖氨酸和精氨酸的高度碱性蛋白质，DNA 缠绕组蛋白形成螺旋状的结构称之为核小体，组蛋白能防止 DNA 缠结

---

## Database

**[Ensembl 数据库](https://ftp.ebi.ac.uk/pub/ensemblorganisms/)**

|          |                                                  |                                                              |
| -------- | ------------------------------------------------ | ------------------------------------------------------------ |
| Card     | The Comprehensive Antibiotic Resistance Database | A bioinformatic database of resistance genes, their products and associated phenotypes |
| CAZy     | The Carbohydrate-Active enZYmes Database         | The CAZy database describes the families of structurally-related catalytic and carbohydrate-binding modules (or functional domains) of enzymes that degrade, modify, or create glycosidic bonds |
| COG      | Database of Clusters of Orthologous Genes        |                                                              |
| EggNOG   | Orthology predictions and functional annnotaion  | A database of orthology relationships, functional annotation, and gene evolutionary histories |
| GO       | Gene Ontology Resource                           | The Gene Ontology (GO) knowledgebase is the world’s largest source of information on the functions of genes |
| KEGG     | Kyoto Encyclopedia of Genes and Genomes          | KEGG is a database resource for understanding high-level functions and utilities of biological systems |
| NR       | Non-redundant protein sequences                  |                                                              |
| Pfam     | Protein Families Database                        | The Pfam database is a large collection of protein families, each represented by multiple sequence alignments and hidden Markov models (HMMs) |
| PHI-base | Pathogen Host Interactions                       | From mutant genes to phenotypes! The mission of PHI-base is to provide expertly curated molecular and biological information on genes proven to affect the outcome of pathogen-host interactions. Information is also given on the target sites of some anti-infective chemistries |
| VFDB     | Virulence Factors of Bacterial Pathogens         | The virulence factor database (VFDB) is an integrated and comprehensive online resource for curating information about virulence factors of bacterial pathogens |
| UniProt  | Universal Protein Resource                       | UniProt is the world’s leading high-quality, comprehensive and freely accessible resource of protein sequence and functional information |

---

## 质控

FastQC、Picard、PerSeq、Trimmomatic

---

## 比对

Bowtie2、hisat2、STAR、Bowtie、bwa

---

## 计数

featureCounts

---

## 差异

基于读段数的差异分析（没有经过归一化）：DESeq2、edgeR、limma；其中 DESeq2 只能用于含有重复样本的情况，对于没有重复样本可以选择 edgeR 和 gfold（我司选择的）

~~~bash
A basic task in the analysis of count data from RNA-seq is the detection of differentially expressed genes. The count data are presented as a table which reports, for each sample, the number of sequence fragments that have been assigned to each gene. Analogous data also arise for other assay types, including comparative ChIP-Seq, HiC, shRNA screening, and mass spectrometry. An important analysis question is the quantification and statistical inference of systematic changes between conditions, as compared to within-condition variability. The package DESeq2 provides methods to test for differential expression by use of negative binomial generalized linear models; the estimates of dispersion and logarithmic fold changes incorporate data-driven prior distributions. This vignette explains the use of the package and demonstrates typical workflows. An RNA-seq workflow on the Bioconductor website covers similar material to this vignette but at a slower pace, including the generation of count matrices from FASTQ files. DESeq2 package version: 1.52.0

RNA-Seq 计数分析的主要任务就是发现差异基因，计数展示位表格形式，行名为样本名称，列名为基因名称，他们的交集点为序列片段数。相似的数据也出现在 ChIP-Seq、HiC、shRNA 鉴定以及大量的分光光度定量分析中。重要的问题是鉴定和统计学推断在不同条件之间作为可比内部条件可变的系统性的不同；DESeq2 通过使用负二项分布概括线性模型来对差异表达进行测试。分散和对数倍数改变的评价包含在数据驱动优先分布。

分析 RNA-seq 计数数据时，一项基本任务是检测差异表达基因。这些计数数据通常以表格形式呈现，记录了每个样本中分配给各个基因的序列片段数量。类似的数据形式也见于其他类型的实验分析，包括比较 ChIP-Seq、HiC、shRNA 筛选和质谱分析等。分析中的一个关键问题是量化并进行统计推断，以评估不同实验条件间的系统性变化与条件内部变异之间的差异。DESeq2 软件包利用负二项广义线性模型来检验基因的差异表达；其中，离散度（dispersion）和对数倍数变化（logarithmic fold changes）的估计过程结合了基于数据生成的先验分布。
~~~

### DESeq2

基于读段计数的统计方法，利用负二项分布来估计，必须含有重复样本

创建一个格式，包含 COUNT coldata design（实验组或对照组）、进行计算、显示结果

不懂，得看视频学下，太难了有点

| id                  | baseMean[^31]    | log2FoldChange[^32] | pvalue[^33]        | padj              | Direction |
| ------------------- | ---------------- | ------------------- | ------------------ | ----------------- | --------- |
| TraesCS1A03G0013400 | 77.0233863074995 | 2.32107942326657    | 0.0212752711076134 | 0.619156717292587 | Up        |
| TraesCS1A03G0015500 | 56.2981855998486 | -2.95982721680433   | 0.0372072141001547 | 0.720666820263197 | Down      |



---

### 富集

---

### 变异检测

[GATK（Genome Analysis Toolkit）](https://gatk.broadinstitute.org/hc/en-us)

---

# 基因组学

---

**基因组概念**

## 高通量测序技术

**双脱氧链终止法（Sanger 测序法）**：
==如何读取凝胶上的序列，哪边大哪边小，即凝胶电泳咋跑的==

鸟枪法

二代测序（Next Generation Sequencing，NGS）引入可逆末端终止法，实现边合成边测序；同时引入荧光标记法，对单个 DNA 分子扩增相同 DNA 组成的簇，然后同步进行复制，以增强荧光信号来识别不同碱基。但过长 DNA 分子同步复制会导致协同性降低，碱基质量也会下降，因此读长限制在 500 bp

## 文库构建

文库构建即给每个 DNA 双链加接头

---

# 转录组学

---

**转录组**：**广义上**指同一时间或环境下，单个细胞或者一群细胞产生的所有 RNA 的总和。包括未成熟的 RNA（pre-RNA）、mRNA、ncRNA 等；**狭义上**指细胞产生的所有 mRNA

**mRNA（message RNA，信使 RNA）**：

**tRNA（transfer RNA，转运 RNA）**：

**miRNA（micro RNA，微小 RNA）**：



## 建库

RNA 提取后其中 80%～90% 为 rRNA，10%～15% 为 tRNA，1%～5% 为 mRNA。对 mRNA 测序要消除 rRNA 的影响即富集 mRNA，而真核生物大多数成熟的 mRNA 3`端含有 PolyA 尾巴（几十上百 nt 连续的 A 碱基）**mRNA 建库**采用的 PolyA 试剂盒中含有 oligo（dT）即磁珠上含有大量的 T 碱基序列，可以结合 mRNA 的 PolyA 使得富集后 80% 都是 mRNA



## 分析流程

### 组装

分为有参考基因组下的组装和无参考基因组下的组装（de nonvov，即从头组装）

### 定量

定量包括

### 聚类

### 降维

### GCNA

### 转录调控网络

### 富集



### 表观遗传



### Basic

**表观遗传**：在 DNA 序列不发生改变的情况下，基因表达发生可遗传的改变，从而影响生物体的表型

**DNA 甲基化（DNA methylation）**：DNA 在甲基转移酶的作用下选择性的将甲基转移到特定的碱基上，可以在不改变 DNA 序列的前提下，改变基因的表达，是表观遗传的调控方式

---

# 数据

---

## 分类

### DNA 数据库

#### 核酸序列数据库

| Database | Belong To |
| -------- | --------- |
| GenBank  | NCBI      |
| EMBI     | EBI       |
| DDBJ     | NIG       |
| NGDC     | CNCB      |

#### 基因组数据库

#### 功能基因数据库

#### 基因型与表型数据库

#### 基因表达数据库

#### 功能元件数据库

#### 表观遗传信息数据库

### RNA 数据库

#### RNA 综合数据库

| Database  | Description                                         |
| :-------- | :-------------------------------------------------- |
| Rfam      | 涵盖 RNA 注释和结构家族集合                         |
| RNAmod    | 收录 mRNA 修饰信息                                  |
| RMBase    | 整合 RNA 转录后修饰、microRNA 结合以及 RNA 结合蛋白 |
| RNALocate | 收录 RNA 亚细胞定位                                 |

#### 非编码 RNA 数据库

收录不同类型非编码 RNA 的 **miRBase**、**RNAcentral**、**lncRNAdb**

### 蛋白质数据库

### 物种特异性数据库

---

## 数据格式



**CSV（Comma Separated Values）**即逗号为分隔符

**TSV（Tab Separated Values）**即制表符为分割符号



### 基因组 FASTA

|      top_level.fa      |               primary_assembly.fa                |   *_rm.fa    |   *_sm.fa    |
| :--------------------: | :----------------------------------------------: | :----------: | :----------: |
| 所有染色体和未定位序列 | 剔除冗余和易混淆可变区域（haplotypes / patches） | 重复序列→“N” | 重复序列小写 |



### BAM

| 比对序列名称                             | 比对信息 | 参考序列   | 染色体起始（1起） | 比对质量值（MAPQ） | CIGAR    | RNEXT[^1] | PNEXT[^2] | TLEN[^3] | Seq                                                          | BaseQ                                                        | 可选标签                                                     |
| ---------------------------------------- | -------- | ---------- | ----------------- | ------------------ | -------- | --------- | --------- | -------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| LH00391:737:23JNNMLT4:7:1154:30472:12336 | 99       | chr1       | 253               | 1                  | 150M     | =         | 284       | 181      | CCACATATGTTTCCTTGTCGTAGATCACATTCTTGGATTTCTGGTGGAGACCATTTCTTGGTCAGAAAACCGTAGGTGTTAGCCTTCGATATTATTGAAAATGGTCGTTCATGGCTATTTTCGACAAAAATGGGGGTTGTGTGGCCATTG | IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII | AS:i:-6 XS:i:-6 XN:i:0 XM:i:1 XO:i:0 XG:i:0                  |
| E250146686L1C041R04200374075             | 163      | CP099973.1 | 1                 | 40                 | 4M7I139M | =         | 125       | 274      | GTCCGCCGTGTCACTTTCGCTTTGGCAGCAGTGTCTTGCCCGATTGCAGGATGAGTTACCAGCCACAGAATTCAGTATGTGGATACGCCCGTTGCAGGCGGAACTGAGCGATAACACGCTGGCTTTGTATGCGCCAAACCGTTTTGTGCT | C?HAHH@H)H4FCB3DBH5EDB?IACC@;CIBICG?DIG:BIB<@IECEDC>GC??>C?ICI;HCGCICC?DICIECAIBDDC?CFGEHHG??IDBHCDICCBDEIC(IDCBCCHCFCH"ADGDCDIBC?IDFFICBCGID?3D?G>EEE | AS:i:-36 XN:i:0  XM:i:2 XO:i:1  XG:i:7 NM:i:9   MD:Z:2G0T139               YS:i:0 YT:Z:CP |

==miRNA 为啥还分正负链==

**第一列**：Fastq ID

**第二列**：FLAG

> 0：该 read 是一条比对到参考基因组正链的单端测序 read
>
> 16：该 read 的反向互补序列能比对到参考基因组上

**第三列**：染色体

**第四列**：比对到染色体上的位置，以第三列染色体第1位往后计算

**第五列**：MAPQ比对质量值。0 表示比对到参考基因组多个位置，60 表示在参考基因组只有一个匹配

**第六列**：M-匹配。22M 表示 22 个碱基全部匹配；128M2I11M 128个碱基匹配，2 个插入，11 个碱基匹配上

**第七列**：第二次匹配的位置，* 表示没有完全一模一样的参考序列，= 表示参考基因组与 read 一模一样

**第八列**：mate 的比对位置，没有 mate 则为 0

**第九列**：序列模板长度，==正负号==

**第十列**：read 的序列



### GTF

| seqname | source | feature    | start    | end      | score | strand | frame[^11] | attributes                                                   |
| ------- | ------ | ---------- | -------- | -------- | ----- | ------ | ---------- | ------------------------------------------------------------ |
| 1       | havana | gene       | 43781121 | 43783055 | .     | -      | .          | gene_id "ENSMUSG00000100764"; gene_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; |
| 1       | havana | transcript | 43781121 | 43783055 | .     | -      | .          | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | exon       | 43782986 | 43783055 | .     | -      | .          | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; exon_number "1"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001334242"; exon_version "2"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | exon       | 43781121 | 43781266 | .     | -      | .          | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; exon_number "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001327336"; exon_version "2"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | transcript | 43782744 | 43783012 | .     | -      | .          | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000185910"; transcript_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-201"; transcript_source "havana"; transcript_biotype "lncRNA"; tag "gencode_basic"; transcript_support_level "NA (assigned to previous version 1)"; |
| 1       | havana | exon       | 43782744 | 43783012 | .     | -      | .          | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000185910"; transcript_version "2"; exon_number "1"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-201"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001328607"; exon_version "2"; tag "gencode_basic"; transcript_support_level "NA (assigned to previous version 1)"; |



featureCounts -t 选第三列中某个特征进行定量 -g 选第九列某个特征进行定量(张老师？)

一个基因可含有多个转录本



### GFF3





### outfmt 6

| qseqid[^21]                                         | sseqid[^22]             | pident[^23] | length[^24] | mismatch | gapopen | qstart[^25] | qend [^26] | sstart [^27] | send[^28] | evalue [^29] | bitscore |
| --------------------------------------------------- | ----------------------- | ----------- | ----------- | -------- | ------- | ----------- | ---------- | ------------ | --------- | ------------ | -------- |
| TRINITY_DN31_c0_g1::TRINITY_DN31_c0_g1_i1::g.1::m.1 | sp\|Q94F47\|UBC28_ARATH | 98.496      | 133         | 2        | 0       | 1           | 133        | 1            | 133       | 1.18e-96     | 274      |
| TRINITY_DN8_c0_g1::TRINITY_DN8_c0_g1_i1::g.6::m.6   | sp\|Q06396\|ARF1_ORYSJ  | 99.448      | 181         | 1        | 0       | 1           | 181        | 1            | 181       | 7.36e-135    | 374      |



### Question

- [ ] GFF3 转化 GTF 文件会将 ncrna 等转化为基因

---

## 图

### Violin

中位数；两个四分位数；最大值；最小值

---

# AI



[^1]: Read Next：双端测序中，pair reads 比对到的染色体位置。= 表示比对到同一条染色体；* 表示没有比对到参考基因组
[^2]: Position of the NEXT read in the template：双端测序中，pair reads 的主要比对起始位置
[^3]: Template Length：插入片段长度；如果 reads 在模板左端，即为 +；如果 reads 在模板右端，即为 -
[^11]: 仅对 CDS 而言，表示到达下一个密码子需要跳过的碱基数，可以是 0、1、2；非 CDS 则为 “.”
[^21]: qurey sequence id
[^22]: subject sequence id
[^23]: percentage of identical matches
[^24]: alignment length (sequence overlap)
[^25]: query sequence start
[^26]: query sequence end
[^27]: subject sequence start
[^28]: subject sequence end
[^29]: expect value
[^31]:基础均值：基因在所有样本中标准化后的平均表达量，用于量化基因总体表达水平
[^32]:差异倍数以 2 为底取对数，+1 即为 2 倍上调；-1 即为 0.5 倍下调，也即对照组表达量是实验组 2 倍
[^33]:假设检验的重要指标，即假设 A 为真的情况下，出现该结果的概率，普遍以 0.05 为阈值；差异分析中 A 代表不存在差异，出现这种结果的概率极小，那么就存在差异；这个版本解释有待商榷；还有其他版本的

