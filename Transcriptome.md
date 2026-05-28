## 有参转录组分析（小鼠为例）

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

**小鼠 GTF 注释文件**

一个基因可含有多个转录本

| seqname | source | feature    | start    | end      | score | strand | frame | attributes                                                   |
| ------- | ------ | ---------- | -------- | -------- | ----- | ------ | ----- | ------------------------------------------------------------ |
| 1       | havana | gene       | 43781121 | 43783055 | .     | -      | .     | gene_id "ENSMUSG00000100764"; gene_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; |
| 1       | havana | transcript | 43781121 | 43783055 | .     | -      | .     | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | exon       | 43782986 | 43783055 | .     | -      | .     | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; exon_number "1"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001334242"; exon_version "2"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | exon       | 43781121 | 43781266 | .     | -      | .     | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000186289"; transcript_version "2"; exon_number "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-202"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001327336"; exon_version "2"; tag "gencode_basic"; tag "gencode_primary"; tag "Ensembl_canonical"; transcript_support_level "5 (assigned to previous version 1)"; |
| 1       | havana | transcript | 43782744 | 43783012 | .     | -      | .     | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000185910"; transcript_version "2"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-201"; transcript_source "havana"; transcript_biotype "lncRNA"; tag "gencode_basic"; transcript_support_level "NA (assigned to previous version 1)"; |
| 1       | havana | exon       | 43782744 | 43783012 | .     | -      | .     | gene_id "ENSMUSG00000100764"; gene_version "2"; transcript_id "ENSMUST00000185910"; transcript_version "2"; exon_number "1"; gene_name "Gm29155"; gene_source "havana"; gene_biotype "lncRNA"; transcript_name "Gm29155-201"; transcript_source "havana"; transcript_biotype "lncRNA"; exon_id "ENSMUSE00001328607"; exon_version "2"; tag "gencode_basic"; transcript_support_level "NA (assigned to previous version 1)"; |

featureCounts -t 选第三列中某个特征进行定量 -g 选第九列某个特征进行定量(张老师？)

**可变剪切**

|      |                           |                |
| ---- | ------------------------- | -------------- |
| SE   | Skippedexon               | 外显子跳跃     |
| A5SS | Alternative5' splice site | 5’端可变剪切   |
| A3SS | Alternative3' splice site | 3’端可变剪切   |
| MXE  | Mutually exclusive exons  | 互斥可变外显子 |
| RT   | Retainedintron            | 内含子保留     |