# 基因组学

## 基因组学概述

**基因组概念**

### 高通量测序技术

**双脱氧链终止法（Sanger 测序法）**：
==如何读取凝胶上的序列，哪边大哪边小，即凝胶电泳咋跑的==

鸟枪法

二代测序（Next Generation Sequencing，NGS）引入可逆末端终止法，实现边合成边测序；同时引入荧光标记法，对单个 DNA 分子扩增相同 DNA 组成的簇，然后同步进行复制，以增强荧光信号来识别不同碱基。但过长 DNA 分子同步复制会导致协同性降低，碱基质量也会下降，因此读长限制在 500 bp

### 文库构建

文库构建即给每个 DNA 双链加接头

## 文件格式

### BAM

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

# 转录组学

# 生物统计学

# 数据库

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

## 文件格式

### BAM

| 比对序列名称                             | 比对信息 | 染色体 | 染色体起始（1起） | 比对质量值（MAPQ） | CIGAR | RNEXT[^1] |      |      |      |      |      |
| ---------------------------------------- | -------- | ------ | ----------------- | ------------------ | ----- | --------- | ---- | ---- | ---- | ---- | ---- |
| LH00391:737:23JNNMLT4:7:1154:30472:12336 | 99       | chr1   | 253               | 1                  | 150M  | =         |      |      |      |      |      |

284	181	CCACATATGTTTCCTTGTCGTAGATCACATTCTTGGATTTCTGGTGGAGACCATTTCTTGGTCAGAAAACCGTAGGTGTTAGCCTTCGATATTATTGAAAATGGTCGTTCATGGCTATTTTCGACAAAAATGGGGGTTGTGTGGCCATTG	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII	AS:i:-6	XS:i:-6	XN:i:0	XM:i:1	XO:i:0	XG:i:0	NM:i:1	MD:Z:68T81	YS:i:-12	YT:Z:CP

[^1]: Read Next：双端测序中，pair reads 比对到的染色体位置。= 表示比对到同一条染色体；* 表示没有比对到参考基因组

---

### GTF

| seqname | source | feature    | start    | end      | score | strand | frame[^1] | attributes                                                   |
| ------- | ------ | ---------- | -------- | -------- | ----- | ------ | --------- | ------------------------------------------------------------ |
| 1       | havana | gene       | 43781121 | 43783055 | .     | -      | .         | gene_id "ENSMUSG00000100764"; gene_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; |
| 1       | havana | transcript | 43781121 | 43783055 | .     | -      | .         | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | exon       | 43782986 | 43783055 | .     | -      | .         | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; exon_number "1"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001334242"; exon_version "2"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | exon       | 43781121 | 43781266 | .     | -      | .         | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; exon_number "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001327336"; exon_version "2"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | transcript | 43782744 | 43783012 | .     | -      | .         | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000185910"; transcript_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-201"; transcript_source "havana"; transcript_biotype "lncRNA"; tag "gencode_basic"; transcript_support_level "NA (assigned to previous version 1)"; |
| 1       | havana | exon       | 43782744 | 43783012 | .     | -      | .         | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000185910"; transcript_version "2"; exon_number "1"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-201"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001328607"; exon_version "2"; tag "gencode_basic"; transcript_support_level "NA (assigned to previous version 1)"; |

featureCounts -t 选第三列中某个特征进行定量 -g 选第九列某个特征进行定量(张老师？)

一个基因可含有多个转录本
