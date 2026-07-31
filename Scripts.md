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
library(scales)


a2_1 <- read.table("a2_1_mapped_sort.txt", header = FALSE, col.names = c("length", "a2_1"))
a2_2 <- read.table("a2_2_mapped_sort.txt", header = FALSE, col.names = c("length", "a2_2"))
a2_3 <- read.table("a2_3_mapped_sort.txt", header = FALSE, col.names = c("length", "a2_3"))
a7_1 <- read.table("a7_1_mapped_sort.txt", header = FALSE, col.names = c("length", "a7_1"))
a7_2 <- read.table("a7_2_mapped_sort.txt", header = FALSE, col.names = c("length", "a7_2"))
a7_3 <- read.table("a7_3_mapped_sort.txt", header = FALSE, col.names = c("length", "a7_3"))
W82_1 <- read.table("W82_1_mapped_sort.txt", header = FALSE, col.names = c("length", "W82_1"))
W82_2 <- read.table("W82_2_mapped_sort.txt", header = FALSE, col.names = c("length", "W82_2"))
W82_3 <- read.table("W82_3_mapped_sort.txt", header = FALSE, col.names = c("length", "W82_3"))

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

write.csv(full, "all_miRNA.csv", row.names = FALSE)

a2_W82_average_28bp <- select(full, length, a2, W82) %>%
  filter(length <= 28 & length >= 18)

dat_long <- pivot_longer(a2_W82_average_28bp,
                         cols = -length,
                         names_to = "Group",
                         values_to = "Counts")

p <- ggplot(dat_long, aes(x=length, y=Counts, color=Group)) +
  geom_line(linewidth=0.5) +
  geom_point(size=1) +
  theme_bw() +
  scale_x_continuous(
    breaks = c(18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28),
    labels = ~ paste0(.x, "nt")
  ) +
  theme(
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 16),
    plot.title = element_text(size = 20),
  ) +
  theme(
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 16)
  ) +
  labs(x="Length", y="Counts", title="Distribution of small RNA Reads Counts")

ggsave("a2_vs_W82_reads_28bp.pdf", p, device = "pdf")
ggsave("a2_vs_W82_reads_28bp.png", p, dpi = 300)


a7_W82_average_28bp <- select(full, length, a7, W82) %>%
  filter(length <= 28 & length >= 18)

dat_long <- pivot_longer(a7_W82_average_28bp,
                         cols = -length,
                         names_to = "Group",
                         values_to = "Counts")

p <- ggplot(dat_long, aes(x=length, y=Counts, color=Group)) +
  geom_line(linewidth=0.5) +
  geom_point(size=1) +
  theme_bw() +
  scale_x_continuous(
    breaks = c(18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28),
    labels = ~ paste0(.x, "nt")
  ) +
  theme(
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 16),
    plot.title = element_text(size = 20),
  ) +
  theme(
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 16)
  ) +
  labs(x="Length", y="Counts", title="Distribution of small RNA Reads Counts")

ggsave("a7_vs_W82_reads_28bp.pdf", p, device = "pdf")
ggsave("a7_vs_W82_reads_28bp.png", p, dpi = 300)
~~~

### 统计质控后碱基分布及平均碱基质量

~~~bash
library(jsonlite)
library(tidyverse)

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

### 宏基因组丰度循环优化

~~~R
library(tidyverse)

args <- commandArgs(T)

# 数据准备
df <- read.table("species_abundance.txt",
                 sep = "\t",
                 quote = "",
                 comment.char = "",
                 check.names = FALSE,
                 header = TRUE)

uniq_df <- data.frame(sample = colnames(df)[2:ncol(df)])
uniq_species <- unique(df$Species)

for (i in uniq_species) {
  sample_species <- df[df$Species == i,  2:ncol(df)]
  uniq_df[1:nrow(uniq_df), i] <- colSums(sample_species)
}

tra_uniq_df <- as.data.frame(t(uniq_df)) %>%
  rownames_to_column(var = "species")

#colnames(tra_uniq_df) <- tra_uniq_df[1,1:ncol(tra_uniq_df)]
#tra_uniq_df <- tra_uniq_df[-1,]
#tra_uniq_df <- arrange(tra_uniq_df, tra_uniq_df[,2])

write.table(x = tra_uniq_df,
            file = "hehe.txt",
            sep = "\t",
            quote = FALSE,
            col.names = FALSE,
            row.names = FALSE)
~~~

### 柱状图

~~~R
# ============================================================
# 根据 qc.txt 绘制测序 reads 柱状图
# 比较组合：W82 vs a2、W82 vs a7
# 数据类型：Raw、Clean（共输出 4 张 PNG）
# ============================================================

# 如尚未安装 ggplot2，请先运行：
# install.packages("ggplot2")
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("缺少 R 包 ggplot2，请先运行 install.packages('ggplot2')")
}

library(ggplot2)

# 输入文件。脚本默认读取用户提供的 qc.txt；如文件移动，请修改此处。
input_file <- "C:/Users/zxj/Desktop/Rstudio/20260716_郭娜售后/qc.txt"

# 图片保存到 qc.txt 所在目录下的 qc_barplots 文件夹。
output_dir <- file.path(dirname(input_file), "qc_barplots")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# 读取并检查数据。
qc <- read.delim(
  input_file,
  header = TRUE,
  sep = "\t",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

required_columns <- c("Group", "Raw_Total_Reads", "Clean_Total_Reads")
missing_columns <- setdiff(required_columns, names(qc))
if (length(missing_columns) > 0) {
  stop("qc.txt 缺少字段：", paste(missing_columns, collapse = ", "))
}

required_groups <- c("W82", "a2", "a7")
missing_groups <- setdiff(required_groups, qc$Group)
if (length(missing_groups) > 0) {
  stop("qc.txt 缺少 Group：", paste(missing_groups, collapse = ", "))
}

# 纵轴刻度显示成 10 的幂，例如 10^7、10^8。
power_of_ten_labels <- function(x) {
  parse(text = paste0("10^", round(log10(x))))
}

plot_one_comparison <- function(group_pair, value_column, type_label) {
  dat <- qc[match(group_pair, qc$Group), c("Group", value_column)]
  names(dat)[2] <- "Reads"
  dat$Group <- factor(dat$Group, levels = group_pair)
  
  # 只设置覆盖当前数据范围的 10^n 主刻度。
  min_power <- floor(log10(min(dat$Reads, na.rm = TRUE)))
  max_power <- ceiling(log10(max(dat$Reads, na.rm = TRUE)))
  axis_breaks <- 10^(1:max_power)
  
  ggplot(dat, aes(x = Group, y = Reads, fill = Group)) +
    geom_col(width = 0.62, show.legend = FALSE) +
    geom_text(
      aes(label = format(Reads, big.mark = ",", scientific = FALSE)),
      vjust = -0.45,
      size = 4
    ) +
    scale_fill_manual(values = c("W82" = "#4C78A8", "a2" = "#F58518", "a7" = "#54A24B")) +
    scale_y_log10(
      breaks = axis_breaks,
      labels = power_of_ten_labels,
      expand = expansion(mult = c(0, 0.16))
    ) +
    labs(
      title = paste(type_label, "Total Reads:", paste(group_pair, collapse = "_vs_")),
      x = "Group",
      y = "Reads"
    ) +
    theme_classic(base_size = 14) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      axis.text.x = element_text(face = "bold"),
      axis.line = element_line(linewidth = 0.6)
    )
}

comparisons <- list(c("W82", "a2"), c("W82", "a7"))
read_types <- list(
  Raw = "Raw_Total_Reads",
  Clean = "Clean_Total_Reads"
)

for (group_pair in comparisons) {
  comparison_name <- paste(group_pair, collapse = "_vs_")
  
  for (type_label in names(read_types)) {
    p <- plot_one_comparison(
      group_pair = group_pair,
      value_column = read_types[[type_label]],
      type_label = type_label
    )
    
    output_file <- file.path(
      output_dir,
      paste0(comparison_name, "_", tolower(type_label), ".png")
    )
    
    ggsave(
      filename = output_file,
      plot = p,
      width = 6.5,
      height = 5.2,
      units = "in",
      dpi = 300,
      bg = "white")
      
      output_file <- file.path(
        output_dir,
        paste0(comparison_name, "_", tolower(type_label), ".pdf")
      )
      
      ggsave(
        filename = output_file,
        plot = p,
        width = 6.5,
        height = 5.2,
        units = "in",
        bg = "white"
    )
  }
}

message("绘图完成，图片保存在：", normalizePath(output_dir, winslash = "/"))
~~~

### 比例分布图

~~~R
a7_W82_average_28bp <- select(full, c(length, a7, W82)) %>%
  filter(length <= 28 & length >= 18)

a7_W82_average_28bp <- mutate(a7_W82_average_28bp,
                              a7_fraction = round(a7_W82_average_28bp$a7 / sum(a7_W82_average_28bp$a7), digits = 4) * 100) %>%
  mutate(W82_fraction = round(a7_W82_average_28bp$W82 / sum(a7_W82_average_28bp$W82), digits = 4) * 100)

a7_W82_average_28bp_fraction <- select(a7_W82_average_28bp,
                                       length,
                                       a7_fraction,
                                       W82_fraction)

colnames(a7_W82_average_28bp_fraction) <- c("length", "a7", "W82")
dat_long <- pivot_longer(a7_W82_average_28bp_fraction,
                         cols = -length,
                         names_to = "Group",
                         values_to = "Percent")

p <- ggplot(dat_long, aes(x=length, y=Percent, color=Group)) +
  geom_line(linewidth=0.5) +
  geom_point(size=1) +
  theme_bw() +
  scale_x_continuous(
    breaks = c(18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28),
    labels = ~ paste0(.x, "nt")) +
  scale_y_continuous(
    breaks = c(5, 10, 15, 20, 25),
    labels = ~ paste0(.x, "%")) +
  theme(
    axis.text = element_text(size = 20),
    axis.title = element_text(size = 24),
    plot.title = element_text(size = 30),
  ) +
  theme(
    legend.text = element_text(size = 20),
    legend.title = element_text(size = 24)
  ) +
  labs(x="Length", y="Percent of Counts", title="Percent of small RNA reads length distribution")
p
ggsave("a7_vs_W82_reads_28bp_Percent.pdf", p, device = "pdf")
ggsave("a7_vs_W82_reads_28bp_Percent.png", p, dpi = 300)
~~~

