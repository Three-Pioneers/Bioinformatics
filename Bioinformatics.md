## ==第一要素: 使用绝对路径==

测序时多个样本在凑在一条 lane 上跑，通过原始测序数据中的 Index_i5 Index_i7 不同的组合能识别不同样本，用于下机时拆分样本

adapter 用于质控时的接头？

## 流程

### 转录组质控

**步骤**

1. 重命名
2. 质控；创建md5sum值；multiqc 联合所有样本的 json 输出报告；Python 整理所有样本关键信息
3. 生成结果：将所需软链接到结果文件夹

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

**修改报告**

- 从头开始, 修改配置文件, vi QC.conf, 重新执行所有命令
- 只修改报告文件, 原报告直接被覆盖

~~~bash
vi /data0_2/2026_03/ChenLei_3_renshen_QC/analysis/report/src/table/project_info.txt
cat /data0_2/2026_03/ChenLei_3_renshen_QC/analysis/work_sh/Step_2_Report.sh
/Data_all/Software/miniconda3/bin/Rscript /data0_2/2026_03/ChenLei_3_renshen_QC/bin/rmarkdown.R --infile /data0_2/2026_03/ChenLei_3_renshen_QC/analysis/report/report.Rmd --outfile /data0_2/2026_03/ChenLei_3_renshen_QC/analysis/report/report.html --format html_document
~~~

- edge 开发者修改, 查找定位, 但会产生一个跟随文件，不推荐使用
- VSCode 修改, 不产生跟随文件

---

### 宏基因组

0. 改名：测序名称→样本名称
1. 质控：**fastq** 过滤低质量 reads 和测序接头；**kneaddata** 过滤重复序列
2. 组装：**megahit** 组装经过滤及去重后的测序文件，输出 **fasta** 文件；**quast** 评估组装结果
3. 预测：**prodigal** 通过起始密码子和终止密码子预测**开放阅读框**，进而反向从 fasta 文件中寻找可能 DNA 和蛋白质
4. 聚类：**mmseqs** 对上述预测的 **DNA** 进行聚类，输出有不同类中有代表的基因，再关联4中预测的 DNA 和蛋白以备后续分析输入
5. 丰度：**metaphlan** 将**质控过滤去重后的序列**比对到数据库，输出所有样本界门纲目科属种的丰度表
6. 功能：**diamond** 将蛋白质或基因 **blast** 到不同数据库，输出 outfmt 6，注释含有什么不同的功能
7. 量化：**salmon** 对**质控去重的测序数据**进行量化输出基因表达表；再进行 α-多样性和 β-多样性（PCA分析）以及后续的 GO、KEGG富集分析

---

**2.Megahit**

~~~bash
# megahit
## k-mer 从一条 DNA 片段中连续截取的, 长度为 k 的核苷酸子序列
## 该参数设置后, --k-list, --k-step 都被固定, 即使后面再加参数也不能修改
## --no-mercy <do not add mercy kmers> 舍弃因低丰度而被过滤 k-mer, 严格执行固定的频率, 同时丢失部分错误过滤的基因组
~~~

**quast(quality assessment tool for genome assemblies)**

**3.ORF_Prediction**

~~~bash
# 预测的核苷酸和蛋白质序列终止位置不一定时终止密码子, 其允许预测未组装完整的基因序列
~~~

**MMseqs2: ultra fast and sensitive sequence search and clustering suite**

**metaphlan: metagenomic phylogenetic analysis for metagenomic taxonomic profiling**

**6.Functional_Annotation**

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

### 小RNA

从 miRNA 入手分析 sRNA 原因：占比大；易建库；公共数据库维护好；生信分析快且容易

1. 原始 fastq 数据
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

==/data3/Data_All== 用单独的数据库

#### 准备数据

1. 参考基因组 https://ftp.ensembl.org/pub
2. 注释 gtf https://ftp.ensembl.org/pub
3. Functional_annotation/
4. 测序数据

**概念**

|         |                        |                                                              |
| ------- | ---------------------- | ------------------------------------------------------------ |
| 小RNA   | small RNA              | 长度18-40 nt，起转录后调控作用的非编码 RNA                   |
| 3’UTR   | 3’ UnTranslated Region | 成熟 mRNA 分子中终止密码子后，PolyA 前非翻译区，调控基因的表达 |
| HairPin | 发夹结构               | DNA、RNA中的单链核酸碱基配对部分形成 “茎”，没有配对部分形成 “环”；调控转录终止和 tRNA 的形成 |
|         |                        |                                                              |
| mRNA    | messenger RNA          | 信使 RNA，                                                   |
| rRNA    | ribosomal RNA          | 核糖体 RNA，                                                 |
| tRNA    | transfer RNA           | 转运 RNA，                                                   |
| snRNA   | small nuclear RNA      | 核小 RNA，负责 mRNA 前体的加工                               |
| snoRNA  | small nucleolar RNA    | 核仁小 RNA，指导 rRNA、tRNA、snRNA 的化学修饰                |
| piRNA   |                        | 特异性 piwi 蛋白结合发挥作用                                 |

**数据库**

|                   |                                  |                                                              |
| ----------------- | -------------------------------- | ------------------------------------------------------------ |
| ENCORI / starBase | Encyclopedia of RNA Interactomes | an extensive atlas that integrates precise RNA interactions identified by our innovative rbsSeeker and rriScan algorithms, showcasing the functional and mechanistic insights into the RNA interactomes |
|                   |                                  |                                                              |

5.Known_miRNA_identification

~~~bash
cd      /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1 && \
mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//4.RepeatMasker/D1/Repeat_unmapped.fa \
        -c  -m  -l 15  -r 10 -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1/mapped.fa && \
quantifier.pl -p /data3/Data_all/Databases/miRBase/hsa_hairpin.fa \
        -m /data3/Data_all/Databases/miRBase/hsa_mature.fa \
        -r /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1/mapped.fa  \
        -g 3 -t hsa -y test

python  /data3/Data_all/script/miRNA/bin//unmapped_miRNA_split.py \
        /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1/mapped.fa \
        /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1/expression_analyses/expression_analyses_test/mapped.fa_mapped.arf \
        /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1

python  /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py \
        /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1/miRNAs_expressed_all_samples_test.csv \
        /data3/Data_all/Databases/miRBase/hsa_hairpin.fa \
        /data3/Data_all/Databases/miRBase/hsa_mature.fa \
        /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1
~~~

**miRDeep2**

成熟 miRNA 是 22nt，没有二级结构，要根据二级结构预测miRNA，就要找到有发夹结构的 miRNA 前体

---

## Linux

### Conda

~~~bash
# ===== fast conda init: lazy load conda, keep active env prompt =====
__conda_sh="/home/zhangxuejie/miniconda3/etc/profile.d/conda.sh"

if [[ -n "${CONDA_PREFIX:-}" && -f "$__conda_sh" ]]; then
    __conda_current_prefix="$CONDA_PREFIX"
    source "$__conda_sh"
    conda activate "$__conda_current_prefix" >/dev/null 2>&1
    unset __conda_current_prefix
else
    conda() {
        unset -f conda
        source "/home/zhangxuejie/miniconda3/etc/profile.d/conda.sh"
        conda "$@"
    }
fi

unset __conda_sh
~~~

注释掉

~~~bash
## >>> conda initialize >>>
## !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$('/home/zhangxuejie/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "/home/zhangxuejie/miniconda3/etc/profile.d/conda.sh" ]; then
#        . "/home/zhangxuejie/miniconda3/etc/profile.d/conda.sh"
#    else
#        export PATH="/home/zhangxuejie/miniconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
## <<< conda initialize <<<

## === 保留已激活环境的提示符（与 auto_activate=false 兼容） ===
#if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
#    conda activate "$CONDA_DEFAULT_ENV"
#fi
~~~

**mamba**

~~~bash
# C++ package 解释器, 替代绝大多数 conda 功能
conda install mamba
~~~

~~~bash
# 修改 .condarc
conda config --shouw-sources
channels:
  - conda-forge
  - bioconda

# 不进入环境查看 python 版本号
conda run -n 环境名称 python --version
~~~

数据块: 存储文件内容
元数据(文件附加属性): 文件大小、创建时间、创建人等以及 incode(系统识别文件的唯一标识符), 名字方便人记不属于 incode, mv 但 incode 不变

链接: 硬链接(Hard link)和软链接(Soft link)
硬链接: 文件副本, 无独立 incode, 必须在同一系统文件下创建, 源文件必须存在且不能为目录
软链接: 包含独立 incode, 指向源文件

### 文件操作

**创建**

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
# 树状图查看后台(父子进程形式)
ps fx
# 存储使用
df -h
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

**删除非常规染色体**

~~~python
# 1.以非常规染色体第一行为分隔符，要前面的
with open("genome_conventional.fa", "r") as FR:
    fr = FR.readlines
A = fr.split(">MT")[0]
with open("test.fa", "w") as FW:
    fw = FW.write(A)
    
# 2.到非常规染色体所在首行，即 >MT
dG
~~~

---

## Python

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

---

## R

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

---

## Biology

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

## Quertion

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

## 想法

1. 统计数据用 wc 数个数，然后汇总



## 转录组分析

**步骤**

1. 比对到参考基因组：数据准备
2. 表达定量：对数据计数
3. 归一化：统一标准
4. 差异分析-火山图、热图：看基因是上调还是下调
5. 富集分析-GO、KEGG：关注的基因参与了什么功能
6. 聚类分析：探索样本间关系，锁定变化的关键样本
7. 相关系数：又分为组间相关系数和组内相关系数
8. 聚类分析和 WGCNA：模块构建-性状与模块相关分析-鉴定主要基因

**表型差异缘由**

DNA：SNP、InDel（插入和缺失）、SV-Structural Variation（倒位）、甲基化

RNA：可变剪切（外显子跳跃和内含子保留）、差异表达、修饰

Protein：丰度差异、折叠方式差异

**归一化**

count 受 基因长度、测序深度的影响

RPKM / FPKM：（count / length） / all_reads

TPM：（count / length） / sum(count / length)

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

### 1.Mapping

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

### 2.Quantification

~~~R
Rscript script/run-featurecounts.R \
    -b ../1.Mapping/BLO_S1_LD1.bam \
    -g ../ref/genes.gtf \
    -o BLO_S1_LD1
~~~

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

## Metagene

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

**megahit**

~~~bash
# --presets meta-large 会覆盖其他 k-list k-skep 等参数
~~~

==失败，本地电脑不好搞宏基因组组装==

**为什么要组装**

|            | 不组装                | 组装                                       |
| ---------- | --------------------- | ------------------------------------------ |
| 数据库比对 | 150bp，不能精确到物种 | 长片段，可精确比对                         |
| 聚类分析   | 各自为阵，没法看联系  | 联合分析同一类细菌的某个共同基因作用       |
| 完整性     | 基因片段              | 包含起始和终止密码子的完整基因，可分析功能 |

## Linux

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

---

## R

**Rstudio**：zoom=75%；Editor font size=20

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

**PCA分析**

~~~R

~~~

## Python

文件 读取F1, F2, F3; 写入out; 读取后直接file1=F1.read(), anno=file.split()

![image-20260411234738824](../Users/15303/Desktop/image-20260411234738824.png)

### 字典

~~~python
print(dict)
# 二者相等? 值, 类型
print(list(dict))
print(dict.keys())
~~~

读取一个文件内容, 如何去除空行

## Conda

1. 查看当前环境下自己下载的包，不包括依赖

~~~bash
conda env export --from-history
~~~

## Snakemake

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

## Pandas

1. Series：列表转一维，字典转一维
2. DataFrame：字典转列；增加列；增加行

alias ps_simple='ps -u $USER -f'
