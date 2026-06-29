## ==第一要素: 使用绝对路径==

---

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

---

# 宏基因组

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

---

# miRNA

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

**miRDeep2**

成熟 miRNA 是 22nt，没有二级结构，要根据二级结构预测miRNA，就要找到有发夹结构的 miRNA 前体

**gfold**：广义 Fold Change 对 RNA-Seq 中的差异表达基因排序，无重复时尤其适合

### Question

- [ ] 当前版本 miRNA 前提序列和成熟序列都太老旧，已知 miRNA 定量时 miRDeep2.pl 参数要加 -P，预测可以不用
  但是，第六步，加了 -P 后，将加 -P 前后的两个表合起来，总共470行，排序去重后，还有370行，说明有问题
- [x] gfold 运行报错：error while loading shared libraries: libgsl.so.0: cannot open shared object file: No such file or directory
  在环境目录下 lib 文件夹：ln libgsl.so.25.1.0* libgsl.so.0 即可成功，后续出问题需注意！

---

# Metagene

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

---

# 有参转录组分析（小鼠为例）

0. 改名：测序名称→样本名称
1. 质控：**fastq** 过滤低质量 reads 和测序接头
2. 比对：**hisat2-build** 把基因组 fasta 建库输出 **ht2** 结尾的文件；**hisat2** 将质控后的基因比对到建库后的文件，输出 **sam** 文件；**samtools** 对 sam 排序转换输出 **bam** 文件，然后对 bam 建索引输出 **bai** 文件 
3. 量化：**subread** 软件下 **featureCounts** 对排序后 bam 量化，生成

---

### 数据准备

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

- [ ] Functional_annotation.conf 是干嘛的，分类号在 miRNA 第四步 RepeatMasker 使用替代了 species，好像更快
- [ ] NCBI 分类号，怎么查，用在流程哪个地方
- [ ] gene_type SYMBOL；Species mmu 这俩干嘛用的

**可变剪切**

|      |                           |                |
| ---- | ------------------------- | -------------- |
| SE   | Skippedexon               | 外显子跳跃     |
| A5SS | Alternative5' splice site | 5’端可变剪切   |
| A3SS | Alternative3' splice site | 3’端可变剪切   |
| MXE  | Mutually exclusive exons  | 互斥可变外显子 |
| RT   | Retainedintron            | 内含子保留     |

### 转录组分析副

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

# 无参转录组分析（芍药为例）

`/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome`

对于没有高质量参考基因组的物种，无参转录组组装通过对 RNA-Seq reads 进行图结构重建、直接恢复转录本，获得完整的转录本集合，芍药（凤丹 Paeonia ostii）的同属不同种 2025 年发布了参考基因组

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

---

### Question

- [ ] Step1.QC.smk：fastp 过滤啥东西

- [x] Step4.Mapping.sh：bowtie2 log 报错：[WARNING] Failed to launch x86-64-v3 version, staying with default
  修改总结脚本，其他流程若有要类似修改

---

# Phage_denovo

## Question

- [ ] 第二步：使用`mamba activate vs2`需要 mamba 初始化，改成 conda 最好
  不对，只有这一步不要 vs2 环境，直接写 VirSorter2 的环境路径
  不行，这个软件需要 snakemake 多软件运行，必须进环境，但是下一步又必须出环境

---

# ChIP-Seq

**ChiP（Chromatin Immunoprecipitation，染色质免疫共沉淀）**：ChIP-Seq 用于确定蛋白质和 DNA 的互作情况；包括 **TF ChIP** 和 **Histone ChIP**

**染色质**：真核生物在间期细胞核内由 DNA、组蛋白、非组蛋白和少量 RNA 组成的核酸蛋白复合体

---

# ATAC

---

# Concept

**模式物种**：科学家为研究生命现象普遍规律而选定的生物，具有易于实验操作，遗传背景清晰等优点

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

**TSS（Transcription Start Sites，转录起始位点）**：DNA 链上与 RNA 链第一个核苷酸对应的碱基

**UTR（Untranslated Region，非翻译区）**：mRNA 编码区（CDS）两端的非编码片段

---

# Database

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

# Biology Basics

基因组 FASTA

|      top_level.fa      |               primary_assembly.fa                |   *_rm.fa    |   *_sm.fa    |
| :--------------------: | :----------------------------------------------: | :----------: | :----------: |
| 所有染色体和未定位序列 | 剔除冗余和易混淆可变区域（haplotypes / patches） | 重复序列→“N” | 重复序列小写 |

[^1]:
