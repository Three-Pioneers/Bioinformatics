## ==第一要素: 使用绝对路径==

测序多个样本凑一条 lane 跑，通过接头 Index_i5 Index_i7 不同的组合区分不同样本，用于下机拆分样本

adapter 用于质控时的接头？

---

# 文件格式

## BAM

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

# Linux

### 基础命令

~~~bash
# ls(list directory contents)
## 权限	硬链接	创建人		创建人所在组	大小	最后修改时间	相对路径
drwxrwxrwx 1 zhangxuejie zhangxuejie 4096 Mar 10 22:40 Training/

# pwd(print working directory)

# cd(change directory)
# 刚才目录
cd -
~~~

### 文件操作

**ESC 模式**

~~~bash
# 全局替换
%s/2/5/g
# 撤销
u
# 撤销重做
Ctrl + r
# 复制
yy
# 删除到文件尾巴
dG
~~~

~~~bash
# 文件重命名
rename 's/new/old/' old_load.txt
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
# 查找正在运行的 programme 的 ID; 终止运行
ps aux | grep programme
kill ID
~~~

~~~bash
# 列向展示所有 gz 文件
ls *gz|awk -F '.part' '{print$1}'
~~~

~~~bash
# 创建文件和目录默认权限
umask

# 把其他人加到权限里来

# 
~~~



### 文件操作

~~~bash
# 添加新用户, 赋予文件权限
su root
adduser zhangfugui
chmod 765(读写执-读写-读执) filename
~~~

~~~bash
# grep(global regular expression print)
## -E 启用扩展正则表达式
grep 'Au_60' Step_2_megahit.sh
~~~

~~~bash
# wc 行数, 单词数(空格, 制表符, 换行符分割), 字符数
wc file.txt
# 打印第四行
wc file.txt | head -n 4 | tail -n 1
~~~

~~~bash
# sort 按照ASCII码排列, 数字则按相同顺序的ASCII往后排
## -g 按数值排列
## -k 指定列排列
## -u 去重
## -s 当 -k 1, 1 仍然不起作用, 默认第一列相同就按后续列排, -s 取消默认
sort -k 1, 1 -s text.txt # 只按照第一列进行排序
~~~

~~~bash
seqkit split2 -p 10 -1 WR260064S_R1.fq.gz -2 WR260064S_R2.fq.gz
~~~

~~~bash
# awk
## -F '/' 指定 / 为分割符, 默认分隔符空格
## '{print $1}' 输出第一列
## '{print $NF}' 输出最后一列
awk 'NR==1 || NR==2 || NR==4 || NR==6 || NR==8 || NR==10'
~~~

~~~bash
# csvtk cut: select and arrange fields
~~~

~~~bash
# 输出从第四行开始到结尾
tail -n +4 file
~~~

~~~bash
-s file：检查文件是否存在且非空
-d file：检查是否为目录
~~~

**删除**

~~~bash
# 删除当前行及之后所有行
dG
~~~

~~~bash
# 不进入环境查看 python 版本号
conda run -n 环境名称 python --version

# 查看当前环境下自己下载的包，不包括依赖
conda env export --from-history
~~~

数据块: 存储文件内容
元数据(文件附加属性): 文件大小、创建时间、创建人等以及 incode(系统识别文件的唯一标识符), 名字方便人记不属于 incode, mv 但 incode 不变

链接: 硬链接(Hard link)和软链接(Soft link)
硬链接: 文件副本, 无独立 incode, 必须在同一系统文件下创建, 源文件必须存在且不能为目录
软链接: 包含独立 incode, 指向源文件

---

# Python

### sys

~~~python
import sys
print(sys.argv[0])
print(sys.argv[1:])
print(sys.argv)
print(type(sys.argv))
~~~

~~~python
python sys.py haha ouha hehe
~~~

文件 读取F1, F2, F3; 写入out; 读取后直接file1=F1.read(), anno=file.split()

### 字典

~~~python
print(dict)
# 二者相等? 值, 类型
print(list(dict))
print(dict.keys())
~~~

读取一个文件内容, 如何去除空行

---

# Biology

**[Ensembl 数据库](https://ftp.ebi.ac.uk/pub/ensemblorganisms/)**

基因组 FASTA

|      top_level.fa      |               primary_assembly.fa                |   *_rm.fa    |   *_sm.fa    |
| :--------------------: | :----------------------------------------------: | :----------: | :----------: |
| 所有染色体和未定位序列 | 剔除冗余和易混淆可变区域（haplotypes / patches） | 重复序列→“N” | 重复序列小写 |

---

### Concept

|                                                              |                                                              |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| circRNA：Circular RNA                                        | mRNA前体反向剪接形成，由共价键连接，没有5'帽子和3'尾巴的闭合环状不编码RNA，稳定不易降解 |
| RNA_denovo                                                   | 全转录组                                                     |
| Metagene                                                     | 宏基因组，指以特定生物环境整体微生物群落作研究对象，通过高通量测序，获得的微生物基因信息的总和 |
| Contig                                                       | 基因组测序中由重叠 DNA 片段拼接形成的连续序列，是基因组组装的最小单元 |
| Sequence Identity                                            | 两条序列之间的相似程度                                       |
| PPI：Protein-Protein Interaction Networks                    | 通过蛋白之间的彼此的相互作用构成，来参与生物信号传递、基因表达调控、能量与物质代谢和细胞周期调控等生命过程 |
| ORF：Open Reading Frame                                      | DNA 或 RNA 序列中，从起始密码子开始，到下一个终止密码子结束的一段连续的核苷酸序列 |
|                                                              | 从起始密码子（AUG）对应的序列（ATG）开始，三个碱基一组向后延伸，找到第一个终止密码子（UAG、UGA、UAA）对应的序列终止的连续序列，是理论上的蛋白编码区 |
| GSEA：Gene Set Enrichment Analysis                           | 预估一个预定基因集的基因在与表型相关性排序的基因表中的分布趋势，以此来判断其对表型变化的贡献 |
| 可变剪切：Differential Splicing / 选择性剪切：Alternative Splicing | 剪切未成熟 mRNA 的内含子，生成保留外显子的成熟 mRNA 的过程   |
|                                                              |                                                              |

---

### Database

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

# Quertion

**质控**

1. 不同格式文件要将文件内容复制到另一种格式中, 不能直接改名字, 否则会出现不可控错误
   批量修改文件名, 尤其如何批量输出 "'"

~~~bash
-rwxrwxr-x 1 zhangxuejie bioinfo 425861587 Mar 12 12:05 'P9_40d_R2.fq.gz'$'\r'*
-rwxrwxr-x 1 zhangxuejie bioinfo 402502035 Mar 12 12:05 'P9_55d_R1.fq.gz'$'\r'*
-rwxrwxr-x 1 zhangxuejie bioinfo 425828469 Mar 12 12:05 'P9_55d_R2.fq.gz'$'\r'*
~~~

2. ~~小RNA质控的数据名称只能是WR2243M01.fq.gz样式, 若是WR2243M01_R1.fq.gz的会出错~~
3. ~~conda 安装包报错 "fastp1.1.*.*", 由于 conda 解析包名出错导致, 下载 mamba 代替 conda~~

### 宏基因组

1. awk 挑选在排序相比于 csvtk cut + awk 分别负责挑选和排序慢很多

~~~bash
awk -F "\t" '{print$2"\t"$1"\t"$3"\t"$4}' 1.txt > 2.txt
csvtk cut -t -f 1.2.3.4 1.txt | awk -F "\t" '{print$2"\t"$1"\t"$3"\t"$4}' > 2.txt
~~~

2. megahit 对同意测序文件组装的同一个基因起始不同

~~~bash
# --presets meta-large 定制了一系列参数，会使自定义 --k-skip 等参数失效
megahit --presets meta-large 
~~~

3. kneaddata 新版本将重复序列也去除了, 而且它再一次去除了接头和低质量 reads
4. sort 的排序问题需要加 -s，不然 -k 1 后还会默认按后续列继续排序
5. alpha_diversity 没有 Richness 的图

### 转录组分析

1. 质控 md5sum 这一步无效，可以删除

~~~bash
md5sum /data0_2/2026_03/SunNan_15_ren_QC/analysis/1.QC/raw/*gz|awk -F'/' '{print$1, $NF}'|awk -F' ' '{print$1, $NF}' > /data0_2/2026_03/SunNan_15_ren_QC/analysis/1.QC/raw/rawdata_md5.txt
~~~

2. ~~有参转录组第七步蛋白互作，有问题~~
3. hisat2 比对率低，试试 star

~~~bash
STAR --runThreadN 12 --runMode genomeGenerate --genomeDir /data/users/minmingw/Alignment/index --genomeFastaFiles /data/users/minmingw/Alignment/hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa --sjdbGTFfile /data/users/minmingw/Alignment/hg38/Homo_sapiens.GRCh38.103.gtf
~~~

4. GO 和 KEGG 富集分析选择差异基因的参数是 pvalue 但好像通用的是 padj
5. ~~下载 KEGG 通路图必须开 VPN，服务器可以，是默认开 VPN？~~
6. 富集分析 clusterProfiler 服务器版本 4.6.2，本地 4.18.4；导致输出的富集分析的文件结果列数，新版多了3列
7. R 脚本排版混乱，命名混乱，注释不足；后期要统一；同时最好使用 python-pandas 处理数据，R-ggplot2 只负责作图
8. ~~rmats --readLength 服务器是 149，应该为 150~~
   149 会将 reads 数小于 149 的过滤掉；测试发现会过滤掉绝大部分
9. Step9 总文件根本没有 2.mapping/hisat2_sorter.bam 这个文件，本地要报错，服务器不报错；echo，rmatsplot 的参数都要改
10. ~~rmatsplot 服务器和本地版本一致，但是本地 python3 缺少了某个模块；服务器是 python2~~
11. Step 10 rush 改为 parallel，后者用的人很多

### miRNA

1. ~~conf 文件 DB_version Soybean 有好多个~~
   ~~gene_descript 这个是啥，没查到~~
   ~~物种缩写之类的有官网查吗；物种的数字编号是啥，用脚本说模块没有，环境不对~~
   ~~ncRNA_TargetGene_analysis = false 这步是默认非吗~~
2. Step_4_RepeatMasker.sh 运行过慢
   该软件分两步，第一步比对，第二部整理结果；慢的是第二步，可拆分数据，分成多个小份，先串行跑比对，然后并行跑整理，最后合并结果
   拆分会造成重复序列出现在不同的小份数据中，整理后会出现同一序列出现多次在 repeat 的地方 
   搞不懂不去重跑一个样本，和分成小份有啥区别

### 参考数据

1. 基因组和注释文件选择问题，以及不同软件的匹配度相关性

---

# R

**Rstudio**：zoom=75%；Editor font size=20

最小的数据结构是向量, ==注: 不是标量==

索引从 1 开始, Vector[-2] 打印除第二个外的向量

R 计算的时候是从最右边往左边算的`a <- 10/5%%1`

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

### 数据结构

**向量（vector）**

~~~R
# 
## 创建
a <- c(2, 4, 6)

a <- seq(1, 100, 4)

a <- rep(1:5, 5)
a <- rep(1:5, times = 5)

a <- rep(1:5, each = 3)

a <- rep(1:2, each = 3, times = 2)
a <- rep(1:2, times = 2, each = 3)

# 取值
a <- c(13, 11, 12.3, 33.5, 55.3)
## 位置
a[2]
a[-1]
a[-5]

a[c(2,5)]
a[-c(2,5)]

a[1:3]

## 逻辑
a < 12
a[a < 12]
a[a != 11]
a[a == 13]

a %in% c(1:20)
a[a %in% c(1:20)]

## 名称
names(a) <- c("zhangsan", "lisi", "wangwu", "zhaoliu", "fugui")
a["fugui"]
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
nrow(df)
ncol(df)
dim(df)
~~~

### 数据类型

**数值型（numeric）**

~~~R
a <- 10
b <- c(1.5, 4.1, 2.5, 11.531)
c <- c(-4, 20, 3.14, -124.1)
log(a)
round(b, digits = 1)
ceiling(b)
floor(b)
max(c)
min(b)
sum(b)
mean(b)
median(c)
# 方差
var(b)
# 标准差：方差平方根
sd(c)
cor(b, c)

data <- c(5,6,8,2,9,3)
sort(data)
orderdataorder(data)
data[order(data)]
~~~

**字符型（character）**

~~~R
library(stringr)
DNA <- c("A", "AcccTT", "CCCtttGG", "TTTCCa")
str_count(DNA, "c")
# 位置划分
str_sub(DNA, 1, 3)

a <- "asdfghjkl"
str_sub(a, 1)
str_sub(a, 1, 3)
# 输出符合的子集
str_subset(DNA, "C")
str_length(DNA)
# 代替
str_replace(DNA, "C", "M")
str_replace_all(DNA, "C", "M")
str_to_lower(DNA)
str_to_upper(DNA)
# 连接
str_c("haha", DNA, sep = "_")
# 分割
str_split(a, "d", simplify = T)

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

# 管道; 管道后的函数不带前面的文件结果, 逗号也可不带(left_join()函数在管道符后带带逗号错误!)
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

## 将result_2按description分组, 统计函数n(), 重命名count=n()
group_by(result_2, description) %>%
  summarise(count = n())

## 找logFC绝对值最大数
group_by(result_2, description) %>%
  summarise(max(abs(logFC)))

## 筛选logFC绝对值最大数的行
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

**富集分析**

~~~R
# GO
## 数据准备
### 1.感兴趣的 gene_id，如：差异表达基因 → enrichGO() → barplot()、enrichplot()、emapplot()
### 2.名字为 gene_id 的向量 log2FoldChange，即差异倍数向量 → cnetplot()
## 富集分析
## 绘图
### barplot
### enrichplot
### cnetplot
### emapplot

# KEGG
## 数据准备
### 输入类型严格：ENTREZ
~~~

# Snakemake

**通配符**

> 由出反向推导输入获得
>
> 自由选择，统一规则下相同就行

**运行**

> 输出文件不含通配符的 rules 被执行时，若输入含通配符，必须指定通配符的值？
>
> 中间规则改变，被影响的所有 rules 都会重新运行

**参数**

~~~bash
--forceall	# 全部强制执行
--forcerun	# 好像没啥用
--cores all	# 设置几都跑慢
# threads 不是越多越好，最好多任务，小线程，找到每个软件最佳线程数
~~~

**Snakefile**

~~~bash
# Ctrl + shift + p，搜索配置代码片段，新建，名字添 Snakemake。粘贴下列代码
{
	// Place your snippets for snakemake here. Each snippet is defined under a snippet name and has a prefix, body and 
	// description. The prefix is what is used to trigger the snippet and the body will be expanded and inserted. Possible variables are:
	// $1, $2 for tab stops, $0 for the final cursor position, and ${1:label}, ${2:another} for placeholders. Placeholders with the 
	// same ids are connected.
"Snakemake Single": {
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
        	"        \"${6:command} {input} {output} 2> {log}\"",
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
			"        ${5:command} {input} {output} 2> {log}",
			"        \"\"\"",
			"$0"
		],
		"description": "Snakemake Multiple Shell"
	},
	"Snakemake R/Py_脚本": {
		"prefix": "rule-script",
		"body": [
			"rule ${1:rule_name}:",
			"    input:",
			"        \"${2:path/to/input}\"",
			"    output:",
			"        \"${3:path/to/output}\"",
			"    log:",
			"        \"${4:log/to/log}\"",
			"    script:",
			"        \"\"\"",
			"        scrpts/your_script.py/R 2> {log}",
			"        \"\"\"",
			"$0"
		],
		"description": "Snakemake R/Py_脚本"
	},
}
~~~

**难点**

> 双端测序数据建立软链接
