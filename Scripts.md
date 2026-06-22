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

~~~python
import sys

Fastq = sys.argv[1]
out = Fastq.split(".")[0]+"_SequencingDepth.txt"

with open(Fastq, "r") as FR:
    fr = FR.read()
    A = fr.split("@")
    SUM = {}
    for i in A[1:]:
        B = i.split("\n")[1]
        if len(B) not in SUM.keys():
            SUM[len(B)] = 1
        else:
            SUM[len(B)] = SUM[len(B)] + 1

with open(out, "w") as FW:
    a = 0
    for i in SUM.keys():
        a = SUM[i] + a
        FW.write("len:"+str(i)+"\tnum:"+str(SUM[i])+"\n")
    print(a)
    print(SUM.keys())
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

