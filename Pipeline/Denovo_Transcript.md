## 无参转录组分析（芍药为例）

`/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome`

对于没有高质量参考基因组的物种，无参转录组组装通过对 RNA-Seq reads 进行图结构重建、直接恢复转录本，获得完整的转录本集合，芍药（凤丹 Paeonia ostii）的同属不同种 2025 年发布了参考基因组

0. 改名：测序名称 → 样本名称
1. 质控：**fastq** 过滤低质量 reads 和测序接头
2. 组装：**Trinity** **分别合并**样本的单端数据，构建 contig、生成结构图、最终生成新的**转录本**及基因和转录本**映射表**
3. 预测：**TransDecoder** 预测**最长开放阅读框**，将预测的蛋白 blastp Uniprot 数据库输出**比对信息表**，重新预测生成最终注释、蛋白和编码序列，根据最终注释文件过滤 Trinity 生成的转录本文件
4. 比对



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



### Question

- [ ] Step1.QC.smk：fastp 过滤啥东西

- [x] Step4.Mapping.sh：bowtie2 log 报错：[WARNING] Failed to launch x86-64-v3 version, staying with default
  修改总结脚本，其他流程若有要类似修改

- [ ] 第二步 Trinity 组装，如果要输入有改变，则需要删除 Trinity 已有结果的文件夹

- [ ] 第三步 TransDecoder 模块，如果输入有改变，也需要删除 TransDecoder 已有结果文件夹