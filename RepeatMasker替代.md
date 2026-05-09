RepeatMasker 运行原理如下：

第一步：用 RMBlast（默认） / HMMER / cross_match 等方法把基因组和 Dfam 库比对
第二步：ProcessRepeats 整理比对结果，生成最终 repeat 注释和 mask 文件

慢是因为第二步 Processrepeats 耗时长，但不代表还在大量比对；它是在 整理海量 repeat 命中结果。如果基因组很大、repeat 很多、.cat 很大，它会非常慢

输出结果文件如下：

|                  |                          |
| :--------------- | ------------------------ |
| genome.fa.out    | 最重要的 repeat 注释结果 |
| genome.fa.tbl    | repeat 统计表            |
| genome.fa.masked | 被屏蔽后的基因组         |
| genome.fa.cat.gz | 原始比对合并结果         |

---

1. 第二步就是比对，为啥，第三步比对还有好多比对三分之一不对不上

---

修改流程如下

**数据准备**：

1. 比对到基因组的序列与除 miRNA 的 ncRNA 比对不上的序列
2. UCSC 下载的 hg38.rmsk.txt.gz
3. UCSC 下载的 hg38.fa.gz

第一步：序列比对到参考基因组

~~~bash

~~~

1. 再比对一次将没比对上 piRNA 的数据输出为 sam 格式

~~~bash

~~~

1. 



---

```
小 RNA reads 已经比对到 genome
        ↓
得到 reads 在 genome 上的位置
        ↓
用 repeat.gff3 / TE.gff3 判断这些位置是否落在 repeat 区域
```

也就是：

```
bowtie genome 比对结果
        +
repeat.gff3
        ↓
bedtools intersect
        ↓
repeat reads
```

示例：

1. bowtie 比对 genome，输出 SAM

```
bowtie \
  -f \
  -v 1 \
  -a \
  --best \
  --strata \
  -S \
  genome_index \
  unmapping.fa \
  unmapping_vs_genome.sam
```

2. SAM 转 BAM

```
samtools view -bS unmapping_vs_genome.sam > unmapping_vs_genome.bam
samtools sort unmapping_vs_genome.bam -o unmapping_vs_genome.sorted.bam
samtools index unmapping_vs_genome.sorted.bam
```

3. BAM 转 BED

```
bedtools bamtobed \
  -i unmapping_vs_genome.sorted.bam \
  > unmapping_vs_genome.bed
```

4. reads 和 repeat 区域取交集

```
bedtools intersect \
  -a unmapping_vs_genome.bed \
  -b repeat.bed \
  -wa -u \
  > repeat_reads.bed
```

没有落在 repeat 区域的 reads：

```
bedtools intersect \
  -a unmapping_vs_genome.bed \
  -b repeat.bed \
  -wa -v \
  > non_repeat_reads.bed
```

这个方法的优点是：

```
不用 RepeatMasker
不用 Dfam
速度快
结果基于基因组位置，更适合 small RNA 注释
```

---

**人和小鼠最推荐从 UCSC 下载 RepeatMasker 的 `rmsk` 表**，然后转成 `repeat.bed` 或 `repeat.gff3`。UCSC 的 `hg38/database/` 和 `mm39/database/` 目录都有 `rmsk.txt.gz`，这是 RepeatMasker 注释表，不一定直接叫 `repeat.gff3`。UCSC 说明这些 `*.txt.gz` 是基因组注释数据库表的压缩文本文件；`hg38` 是 GRCh38，`mm39` 是 GRCm39。

------

## 一、人 hg38 和小鼠 mm39 下载

```
mkdir -p repeat_annotation
cd repeat_annotation

# 人 hg38 / GRCh38 RepeatMasker 注释表
wget -c https://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/rmsk.txt.gz -O hg38.rmsk.txt.gz
wget -c https://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/rmsk.sql    -O hg38.rmsk.sql

# 小鼠 mm39 / GRCm39 RepeatMasker 注释表
wget -c https://hgdownload.soe.ucsc.edu/goldenPath/mm39/database/rmsk.txt.gz -O mm39.rmsk.txt.gz
wget -c https://hgdownload.soe.ucsc.edu/goldenPath/mm39/database/rmsk.sql    -O mm39.rmsk.sql
```

UCSC 目录里可以看到：`hg38` 的 `rmsk.txt.gz` 是 148M，`mm39` 的 `rmsk.txt.gz` 是 135M。

------

## 二、转成 repeat.bed

UCSC `rmsk.txt.gz` 是 tab 表格，常用列是：

```
第6列  chr
第7列  start
第8列  end
第10列 strand
第11列 repeat name
第12列 repeat class
第13列 repeat family
```

### 人 hg38 转 BED

```
zcat hg38.rmsk.txt.gz | awk 'BEGIN{OFS="\t"}
{
  chr=$6;
  start=$7;
  end=$8;
  strand=$10;
  repName=$11;
  repClass=$12;
  repFamily=$13;
  name=repName "|" repClass "|" repFamily;
  print chr,start,end,name,0,strand,repName,repClass,repFamily
}' > hg38.repeat.bed
```

### 小鼠 mm39 转 BED

```
zcat mm39.rmsk.txt.gz | awk 'BEGIN{OFS="\t"}
{
  chr=$6;
  start=$7;
  end=$8;
  strand=$10;
  repName=$11;
  repClass=$12;
  repFamily=$13;
  name=repName "|" repClass "|" repFamily;
  print chr,start,end,name,0,strand,repName,repClass,repFamily
}' > mm39.repeat.bed
```

检查：

```
head hg38.repeat.bed
head mm39.repeat.bed
```

这个 `repeat.bed` 就可以直接用于：

```
bedtools intersect -a sample_vs_genome.bed -b hg38.repeat.bed -wa -u > sample.repeat_reads.bed
```

---

`bedtools` 本身是做“基因组坐标集合运算”的工具，支持 BED、BAM、GFF/GTF、VCF 等格式之间的交集、合并、计数等操作；`bamtobed` 可以把 BAM 比对结果转成 BED 坐标。

------

## 1. `bedtools intersect` 输出是什么？

假设有两个文件：

```
sample_vs_genome.bed    # reads 比对到基因组的位置
repeat.bed              # repeat 区域位置
```

### 情况 1：输出落在 repeat 区域的 reads

```
bedtools intersect \
  -a sample_vs_genome.bed \
  -b repeat.bed \
  -wa -u \
  > sample.repeat_reads.bed
```

输出文件 `sample.repeat_reads.bed` 内容类似：

```
chr1    10025   10046   read_00001_x25   255   +
chr3    50210   50231   read_00089_x7    255   -
```

含义是：

```
这些 reads 的基因组位置与 repeat.bed 有重叠
所以这些 reads 被注释为 repeat-related reads
```

------

### 情况 2：输出没有落在 repeat 区域的 reads

```
bedtools intersect \
  -a sample_vs_genome.bed \
  -b repeat.bed \
  -wa -v \
  > sample.non_repeat_reads.bed
```

输出文件 `sample.non_repeat_reads.bed` 就是：

```
没有和 repeat 区域重叠的 reads
```

这个可以继续用于后续 novel miRNA 分析。

------

### 情况 3：输出 reads 对应的 repeat 类型

如果你想知道 reads 落在哪类 repeat 上，用：

```
bedtools intersect \
  -a sample_vs_genome.bed \
  -b repeat.bed \
  -wa -wb \
  > sample.repeat_annotated.bed
```

输出会包含两部分：

```
read坐标信息 + repeat坐标信息
```

例如：

```
chr1 10025 10046 read_00001_x25 255 + chr1 10000 10500 Gypsy|LTR|Gypsy 0 +
```

这样就可以统计：

```
LINE
SINE
LTR
DNA transposon
Simple_repeat
Low_complexity
Satellite
Unknown
```

------

## 2. 能不能和原来达到相同效果？

### 如果你们原来的目的只是：

```
把 repeat 相关 reads 去掉
```

那么 **可以达到相似效果，而且更快、更适合批量样本流程**。

原来：

```
unmapping.fa → RepeatMasker + Dfam → repeat reads / non-repeat reads
```

改成：

```
reads 比对 genome → 得到 reads 坐标
repeat.gff3 / repeat.bed
bedtools intersect → repeat reads / non-repeat reads
```

效果上都是为了区分：

```
repeat-derived reads
non-repeat reads
```