# 工具

---

## VSCode

~~~bash
# 修改视窗大小不要 Ctrl + / -，容易触发 BUG，直接要修改配置文件
"terminal.integrated.fontSize": 18,
"editor.fontSize": 18
~~~

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



## 质控

测序多个样本凑一条 lane 跑，通过接头 Index_i5 Index_i7 不同的组合区分不同样本，用于下机拆分样本

adapter 用于质控时的接头？

FastQC、Picard、PerSeq、Trimmomatic

read、contig、scaffold

Q20

Q30

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



## 比对

Bowtie2、hisat2、STAR、Bowtie、bwa



## 计数

featureCounts



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



### 富集



### 变异检测

[GATK（Genome Analysis Toolkit）](https://gatk.broadinstitute.org/hc/en-us)

---

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
