## Metagene

0. 改名：下机名称 → 样本名称
1. 质控：**fastq** 过滤低质量 reads 和测序接头；**kneaddata** 过滤重复序列
2. 组装：**megahit** 组装经过滤及去重后的测序文件，输出 **fasta** 文件；**quast** 评估组装结果
3. 预测：**prodigal** 通过起始密码子和终止密码子预测**开放阅读框**，进而反向从 fasta 文件中寻找可能 DNA 和蛋白质
4. 聚类：**mmseqs** 对上述预测的 **DNA** 进行聚类，输出有不同类中有代表的基因，再关联4中预测的 DNA 和蛋白以备后续分析输入
5. 丰度：**metaphlan** 将**质控过滤去重后的序列**比对到数据库，输出所有样本界门纲目科属种的丰度表
6. 功能：**diamond** 将蛋白质或基因 **blast** 到不同数据库，输出 outfmt 6，注释含有什么不同的功能
7. 量化：**salmon** 对**质控去重的测序数据**进行量化输出基因表达表；再进行 α-多样性和 β-多样性（PCA分析）以及后续的 GO、KEGG富集分析



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

**为什么要组装**

|            | 不组装                | 组装                                       |
| ---------- | --------------------- | ------------------------------------------ |
| 数据库比对 | 150bp，不能精确到物种 | 长片段，可精确比对                         |
| 聚类分析   | 各自为阵，没法看联系  | 联合分析同一类细菌的某个共同基因作用       |
| 完整性     | 基因片段              | 包含起始和终止密码子的完整基因，可分析功能 |

### 2.Megahit

~~~bash
# megahit
## k-mer 从一条 DNA 片段中连续截取的, 长度为 k 的核苷酸子序列
## --presets meta-large 参数设置后, --k-list, --k-step 都被固定, 即使后面再加参数也不能修改
## --no-mercy <do not add mercy kmers> 舍弃因低丰度而被过滤 k-mer, 严格执行固定的频率, 同时丢失部分错误过滤的基因组
~~~

**quast(quality assessment tool for genome assemblies)**

### 3.ORF_Prediction

~~~bash
# 预测的核苷酸和蛋白质序列终止位置不一定时终止密码子, 其允许预测未组装完整的基因序列
~~~

**MMseqs2: ultra fast and sensitive sequence search and clustering suite**

**metaphlan: metagenomic phylogenetic analysis for metagenomic taxonomic profiling**

### 6.Functional_Annotation

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



### Basic

**Gene**：携带遗传物质的 DNA 或 RNA



### Question

- [ ] awk 挑选在排序相比于 csvtk cut + awk 分别负责挑选和排序慢很多

~~~bash
awk -F "\t" '{print$2"\t"$1"\t"$3"\t"$4}' 1.txt > 2.txt
csvtk cut -t -f 1.2.3.4 1.txt | awk -F "\t" '{print$2"\t"$1"\t"$3"\t"$4}' > 2.txt
~~~

- [ ] megahit 对同意测序文件组装的同一个基因起始不同

~~~bash
# --presets meta-large 定制了一系列参数，会使自定义 --k-skip 等参数失效
megahit --presets meta-large 
~~~

- [ ] kneaddata 新版本将重复序列也去除了，而且它再一次去除了接头和低质量 reads

- [ ] sort 的排序问题需要加 -s，不然 -k 1 后还会默认按后续列继续排序

- [ ] alpha_diversity 没有 Richness 的图

- [ ] 失败，本地电脑不好搞宏基因组组装
  服务器也是一天一个样本