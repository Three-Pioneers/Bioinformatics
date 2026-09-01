## 步骤

0. 改名：测序名称 → 样本名称
1. 质控：**fastp** 过滤低质量 reads 和测序接头
2. 比对：**hisat2-build** 对基因组 fasta 建索引输出 **8个ht2** 结尾的文件；**hisat2** 比对质控后的序列到基因组索引，输出的 **sam** 文件被**samtools** 排序后转换输出 **bam** 文件
3. 量化：**subread** 软件下 **featureCounts** 对排序后 bam 量化，生成



### 步骤

**1.QC**



**2.Mapping**

1. hisat2 尽量跑物理核心，不要多线程多任务运行。即每次只跑一个任务
2. hisat2 可以直接和 Samtools 联动运行。即不产生 Sam 直接将标准输出交给 Samtools 进行排序

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



**9.rMATS**

1. rmats.py 每个脚本需要消耗 20 个线程，Snakemake 最多使用 2 或 3 个同时运行



**10.Variance Calling**





### Basic

#### 3.4 基因表达水平分析

- [ ] 标准化计算方法：FPKM / TPM
- [ ] 相关性图
- [ ] 小提琴图

#### 3.5 差异分析

- [ ] 差异分析热图
- [ ] 差异分析火山图

#### 3.7 GO KEGG 富集分析

- [ ] 输入、输出、作用、解释
- [ ] GO 柱状图
- [ ] GO 气泡图
- [ ] GO 圈图
- [ ] KEGG 柱状图
- [ ] KEGG 气泡图

#### 3.8 GSEA 基因集富集分析

- [ ] 软件、定义
- [ ] 基因集富集分析图

#### 3.9 可变剪切

- [ ] 软件

#### 3.10 变异位点

- [ ] 软件



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
