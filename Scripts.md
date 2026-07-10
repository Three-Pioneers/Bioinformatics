### 提取基因组中常规染色体（人）

~~~python
with open("genome.fa", "r") as FR:
    fr = FR.readlines
# grep ">" genome.fa 可知 Y 染色体后第一条非常规染色体名字，并以此为切割点
A = fr.split(">MT")[0]
with open("test.fa", "w") as FW:
    fw = FW.write(A)
~~~

~~~bash
vi genome.fa	# /> 查找染色体，到达 >MT 行后，推出编辑模式
dG	# 此法慢
~~~

### 提取BED（AI 给的，有待学习）

~~~python
awk -F'\t' 'BEGIN{OFS="\t"} $0!~/^#/ && $3=="transcript"{gene="."; trans="."; attr=$9; split(attr,a,";"); for(i in a){gsub(/^ +| +$/,"",a[i]); if(a[i]~/^gene_id /){gene=a[i]; sub(/^gene_id "/,"",gene); sub(/"$/,"",gene); sub(/^gene:/,"",gene)}; if(a[i]~/^transcript_id /){trans=a[i]; sub(/^transcript_id "/,"",trans); sub(/"$/,"",trans); sub(/^transcript:/,"",trans)}} id=gene"|"trans; print $1,$4-1,$5,id,0,$7}' *.gtf | sort -k1,1V -k2,2n > gene_6col.bed
~~~

### 根据基因名称提取 BAM 文件信息重新生成 BAM 文件

~~~bash
gtf=genome.gtf
bam=sample.bam
gene_list=gene.list
out=target_genes

awk -v gene_list="$gene_list" 'BEGIN{
    while((getline line < gene_list) > 0){
        genes[line]=1
    }
}
$3=="gene"{
    gene_name=""
    if(match($0, /gene_name "([^"]+)"/, a)){
        gene_name=a[1]
    }
    if(gene_name in genes){
        start=$4-1
        if(start<0) start=0
        print $1"\t"start"\t"$5"\t"gene_name
    }
}' "$gtf" > ${out}.bed

samtools index "$bam"

samtools view -b -L ${out}.bed "$bam" > ${out}.unsorted.bam

samtools sort -o ${out}.bam ${out}.unsorted.bam

samtools index ${out}.bam

rm ${out}.unsorted.bam
~~~

### 提取转录本

脚本中是 gtf 文件，我们用的是 gff3 文件去除注释行后的文件

~~~bash
dict1 = {}
with open("genome.fa", "r") as file1:
    chr_name = None
    seq_list = []
    for line in file1:	#牛的哦，直接可以读取
        line = line.strip()
        if not line:
            continue
        if line.startswith(">"):
            # 如果已经有一个chr_name在进行累积，则先写入dict
            if chr_name is not None:
                dict1[chr_name] = "".join(seq_list)
            # 更新chr_name，并重置序列累积
            chr_name = line[1:].split()[0]
            seq_list = []
        else:
            seq_list.append(line)
    # 最后一条染色体序列也要记得放进dict
    if chr_name is not None:
        dict1[chr_name] = "".join(seq_list)

out1=open("gene.fa","w")

file2=open("gene.gtf","r")
lines2=file2.readlines()
for i in lines2:
    xx=i.split('\t')
    if xx[2] == 'gene':
        gene_id=xx[8].split(';')[0].split('"')[1]                       #修改
        all_seq=dict1[xx[0]]
        if int(xx[3]) > int(xx[4]):
            start=int(xx[4])-1
            end=int(xx[3])
        else:
            start=int(xx[3])-1
            end=int(xx[4])
        if xx[6]=='+':
            seq=all_seq[start:end]
        else:
            seq_part = all_seq[start:end]
            trans_table = str.maketrans("ACGTacgt", "TGCAtgca")
            seq= seq_part.translate(trans_table)[::-1]
        out1.write('>'+gene_id+'\n'+seq+'\n')
~~~

~~~bash
# 而且，将 GFF3 转换成 GTF 文件后，分别统计第三列 “mRNA” 和 “transcript” 统计数不一样；AI 说 gtf 转化后的 transcript，会过滤掉不完整的，同时会把如 ncRNA 都算在内，因此不一样：研究下哪个正确
gffread genome.gff3 -T -o gene.gtf

#! 要用 GTF 文件，因为 ncRNA 也会用到注释所以上面的是不对的
# 那么生产 bed 时，同样要把第三列范围扩大
awk '$3 == "transcript"' gene.gtf|awk -F'\t' '{print$1"\t"$4"\t"$5}' >gene.bed
~~~

### 提取 id_name 对应表

~~~python
FW = open("id_name.txt", "w")
# genome.gff3 是源文件去除 # 所在行得到
with open("genome.gff3", "r") as FR:
    fr = FR.readlines()
    for i in fr:
        A = i.strip().split("\t")[8] #第八列
        B = A.split(";")[0].split(":")
        C = A.split(";")[1].split("=")
        if B[0] == "ID=gene":
            if C[0] == "Name":
                FW.write(B[1]+"\t"+C[1]+"\n")
~~~

### 修改 PeakAnno.txt gene_id 列

~~~python
with open("A_PeakAnno.txt", "r") as FR:
    fr = FR.readlines()
FW = open ("A.PeekAnno.txt.bak", "w")
FW.write(fr[0])
for line in fr[1:] :
    A = line.rsplit("\t",3)
    if A[1][0] == "g":
        B = A[1].split(":")[1]
        FW.write(A[0]+"\t"+B+"\t"+A[2]+"\t"+A[3])
    else:
        FW.write(line)
~~~

### 统计测序数据的测序深度

统计 reads 长度时不要以 @ 为分割，因为碱基质量值中也可能出现 @；应先将 fq 转化为 fa，统计时也不要只统计 > 的下一行，因为有的序列会出现多行，需要将多行合并

`seqkit fq2fa W82_1.fq.gz -o W82_1.fa`

~~~python
import sys

Fasta = sys.argv[1]
out = Fasta.split(".")[0]+"_SequencingDepth.txt"

with open(Fasta, "r") as FR:
    fr = FR.read()
    A = fr.split(">")
    SUM = {}
    for i in A[1:]:
        B = i.split("\n")[1:]
        C = "".join(B)
        if len(C) not in SUM.keys():
            SUM[len(C)] = 1
        else:
            SUM[len(C)] = SUM[len(C)] + 1

with open(out, "w") as FW:
    for i in SUM.keys():
        FW.write(str(i)+"\t"+str(SUM[i])+"\n")
~~~

#### 绘制折线图

~~~R
library(tidyverse)
library(ggplot2)
library(sysfonts)
library(showtext)

font_add("yahei", "C:/Windows/Fonts/msyh.ttc")
showtext_auto()
showtext_opts(dpi = 300)

a2_1 <- read.table("clean_a2_1_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "a2_1"))
a2_2 <- read.table("clean_a2_2_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "a2_2"))
a2_3 <- read.table("clean_a2_3_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "a2_3"))
a7_1 <- read.table("clean_a7_1_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "a7_1"))
a7_2 <- read.table("clean_a7_2_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "a7_2"))
a7_3 <- read.table("clean_a7_3_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "a7_3"))
W82_1 <- read.table("clean_W82_1_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "W82_1"))
W82_2 <- read.table("clean_W82_2_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "W82_2"))
W82_3 <- read.table("clean_W82_3_R1_SequencingDepth.txt", header = FALSE, col.names = c("length", "W82_3"))

full <- full_join(a2_1, a2_2, by = "length") %>%
  full_join(a2_3, by = "length") %>%
  full_join(a7_1, by = "length") %>%
  full_join(a7_2, by = "length") %>%
  full_join(a7_3, by = "length") %>%
  full_join(W82_1, by = "length") %>%
  full_join(W82_2, by = "length") %>%
  full_join(W82_3, by = "length") %>%
  mutate(a2 = (a2_1 + a2_2 + a2_3) %/% 3) %>%
  mutate(a7 = (a7_1 + a7_2 + a7_3) %/% 3) %>%
  mutate(W82 = (W82_1 + W82_2 + W82_3) %/% 3) %>%
  arrange(length)

write.csv(full, "full.csv", row.names = FALSE)

# a2_vs_W82 35bp reads 分布折线图
a2_W82_average <- select(full, c(length, a2, W82))

a2_W82_average_35bp <- filter(a2_W82_average, length <= 35 & length >= 18)

dat_long <- pivot_longer(a2_W82_average_35bp,
                         cols = -length,
                         names_to = "Group",
                         values_to = "Counts")

p <- ggplot(dat_long, aes(x=length, y=Counts, color=Group)) +
  geom_line(linewidth=0.5) +
  geom_point(size=1) +
  theme_bw() +
  theme(text = element_text(family = "yahei")) +
  scale_x_continuous(
    breaks = c(18, 20, 22, 24, 26, 28, 30, 32, 34, 35),
    labels = ~ paste0(.x, "nt")
    ) +
  labs(x="Length", y="Counts", title="小RNA reads 分布")

ggsave("a2_vs_W82_reads_35bp.pdf", p, device = "pdf")
ggsave("a2_vs_W82_reads_35bp.png", p, dpi = 300)



# a2_vs_W82 28bp reads 分布折线图
a2_W82_average_28bp <- filter(a2_W82_average, length <= 28 & length >= 18)

dat_long <- pivot_longer(a2_W82_average_28bp,
                         cols = -length,
                         names_to = "Group",
                         values_to = "Counts")

p <- ggplot(dat_long, aes(x=length, y=Counts, color=Group)) +
  geom_line(linewidth=0.5) +
  geom_point(size=1) +
  theme_bw() +
  theme(text = element_text(family = "yahei")) +
  scale_x_continuous(
    breaks = c(18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28),
    labels = ~ paste0(.x, "nt")
  ) +
  labs(x="Length", y="Counts", title="小RNA reads 分布")

ggsave("a2_vs_W82_reads_28bp.pdf", p, device = "pdf")
ggsave("a2_vs_W82_reads_28bp.png", p, dpi = 300)


# a7_vs_W82 35bp reads 分布折线图
a7_W82_average <- select(full, c(length, a7, W82))

a7_W82_average_35bp <- filter(a7_W82_average, length <= 35 & length >= 18)

dat_long <- pivot_longer(a7_W82_average_35bp,
                         cols = -length,
                         names_to = "Group",
                         values_to = "Counts")

p <- ggplot(dat_long, aes(x=length, y=Counts, color=Group)) +
  geom_line(linewidth=0.5) +
  geom_point(size=1) +
  theme_bw() +
  theme(text = element_text(family = "yahei")) +
  scale_x_continuous(
    breaks = c(18, 20, 22, 24, 26, 28, 30, 32, 34, 35),
    labels = ~ paste0(.x, "nt")
  ) +
  labs(x="Length", y="Counts", title="小RNA reads 分布")

ggsave("a7_vs_W82_reads_35bp.pdf", p, device = "pdf")
ggsave("a7_vs_W82_reads_35bp.png", p, dpi = 300)


# a7_vs_W82 28bp reads 分布折线图
a7_W82_average_28bp <- filter(a7_W82_average, length <= 28 & length >= 18)

dat_long <- pivot_longer(a7_W82_average_28bp,
                         cols = -length,
                         names_to = "Group",
                         values_to = "Counts")

p <- ggplot(dat_long, aes(x=length, y=Counts, color=Group)) +
  geom_line(linewidth=0.5) +
  geom_point(size=1) +
  theme_bw() +
  theme(text = element_text(family = "yahei")) +
  scale_x_continuous(
    breaks = c(18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28),
    labels = ~ paste0(.x, "nt")
  ) +
  labs(x="Length", y="Counts", title="小RNA reads 分布")

ggsave("a7_vs_W82_reads_28bp.pdf", p, device = "pdf")
ggsave("a7_vs_W82_reads_28bp.png", p, dpi = 300)
~~~

### 统计质控后碱基分布及平均碱基质量

~~~bash
for (pkg in c("jsonlite", "tidyverse")) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
    require(pkg, character.only = TRUE)
  }
}

json <- fromJSON("WCB2024001_fastp.json")

# 每个位置碱基比例
r1 <- json$read1_after_filtering$content_curves
r2 <- json$read2_after_filtering$content_curves

df_R1 <- data.frame(
  Position = seq_along(r1$A),
  A = r1$A * 100,
  T = r1$T * 100,
  G = r1$G * 100,
  C = r1$C * 100,
  N = r1$N * 100
)

df_R2 <- data.frame(
  Position = seq_along(r2$A) + length(r1$A),
  A = r2$A * 100,
  T = r2$T * 100,
  G = r2$G * 100,
  C = r2$C * 100,
  N = r2$N * 100
)

df_all <- rbind(df_R1, df_R2)

dat_long <- pivot_longer(df_all,
                         cols = -Position,
                         names_to = "Base",
                         values_to = "Content"
                         )

Base_Distribution <- ggplot(data = dat_long,
       mapping = aes(x = Position, y = Content, color = Base)
  ) +
  geom_line(linewidth = 0.75) +
  geom_point(size = 0.75, show.legend = FALSE) +
  theme_classic() +
  scale_color_manual(
    name = NULL,
    values = c(
      A = "red",
      T = "blue",
      G = "purple",
      C = "green",
      N = "cyan"
      ),
    breaks = c("A", "T", "C", "G", "N"),
    labels = c("A%", "T%", "C%", "G%", "N%"),
    ) +
  geom_vline(xintercept = length(r1$A), linetype = "twodash") +
  labs(
    title = "Base Distribution of WCB2024001",
    x = "Position",
    y = "Percent(%)"
  ) +
  scale_x_continuous(
    limits = c(0, 300),
    breaks = seq(0, 300, 25)
  ) +
  scale_y_continuous(
    limits = c(0, 70),
    breaks = seq(0, 70, 10)
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    legend.position = c(0.85, 0.75)
    )

ggsave(
  filename = "Base Distribution of WCB2024001.pdf",
  plot = Base_Distribution,
  width = 8,
  height = 5
)

ggsave(
  filename = "Base Distribution of WCB2024001.png",
  plot = Base_Distribution,
  width = 8,
  height = 5,
  dpi = 600
)


# 每个位置碱基平均质量
r1_mean_quality <- json$read1_after_filtering$quality_curves$mean
r2_mean_quality <- json$read2_after_filtering$quality_curves$mean

r1_quality <- data.frame(
  Position = seq_along(r1_mean_quality),
  Quality = r1_mean_quality,
  Sample = "mean_quality"
)

r2_quality <- data.frame(
  Position = seq_along(r2_mean_quality) + length(r1_mean_quality),
  Quality = r2_mean_quality,
  Sample = "mean_quality"
)

quality <- rbind(r1_quality, r2_quality)

Mean_Quality <- ggplot(
  data = quality,
  mapping = aes(x = Position, y = Quality, color = Sample)
) +
  geom_vline(xintercept = length(r2_mean_quality), linetype = "twodash") +
  scale_color_manual(
    name = NULL,
    values = c("mean_quality" = "red")
    ) +
  geom_line(linewidth = 0.75) +
  theme_classic() +
  labs(
    x = "Position",
    y = "Quality",
    title = "Mean Quality Distribution of WCB2024001"
  ) +
  scale_x_continuous(
    limits = c(0, 300),
    breaks = seq(0, 300, 25)
  ) +
  scale_y_continuous(
    limits = c(0, 40),
    breaks = seq(0, 40, 10)
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    legend.position = c(0.85, 0.75)
  )

ggsave(
  filename = "Mean Quality Distribution of WCB2024001.pdf",
  plot = Mean_Quality,
  width = 8,
  height = 5
)

ggsave(
  filename = "Mean Quality Distribution of WCB2024001.png",
  plot = Mean_Quality,
  width = 8,
  height = 5,
  dpi = 600
)
~~~

### 两个表合并（分别 Python 循环和 R 表关联）

**Python**

~~~python
with open("A34F_PeakAnno.txt", "r") as FR1:
	fr1 = FR1.readlines()

with open("A34F_peaks_clean.xls", "r") as FR2:
	fr2 = FR2.readlines()

with open("final_txt", "w") as FW:
	header = fr1[0].split("\t")
	header.insert(8, "-log10(qvalue)")
	#print(header)
	#print("\t".join(header))
	FW.write("\t".join(header))
	
	dict1 = {}
	for j in fr2[1:] :
		B = j.rsplit("\t", 2)
		dict1[B[-1].strip()] = B[-2]
		#print(dict1.keys())
		#print(name)

	for i in fr1[1:] :
		A = i.split("\t", 8)
		peak_name = A[5]
		#print(dict1[peak_name])
		if dict1[peak_name] :
			A.insert(8, dict1[peak_name])
			#print(A)
			FW.write("\t".join(A))
			continue
		#print(peak_name)
~~~

**R**

~~~R
library(tidyverse)

# 注意 read.table() 函数要加 quote = ""，如果不加，碰到字段中含有单引号，会变成引用，从而大大减少行数
PeakAnno <- read.table("A34F_PeakAnno.txt", sep = "\t", header = TRUE, check.names = FALSE, quote = "")
nrow(PeakAnno)	# 108909
#PeakAnno1 <- read.table("A34F_PeakAnno.txt", sep = "\t", header = TRUE, check.names = FALSE)
#nrow(PeakAnno1)	# 53271

peaks <- read.table("A34F_peaks_clean.xls", sep = "\t", header = TRUE, check.names = FALSE, quote = "")
nrow(peaks)

final <- left_join(PeakAnno, peaks, by = c("peak_name" = "name")) %>%
  select(-c(18:25)) %>%
  select(c(1:8, 18, 9:17))
~~~

