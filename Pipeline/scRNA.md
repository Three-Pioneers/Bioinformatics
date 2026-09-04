# scRNA

---

[Cell Ranger](https://www.10xgenomics.com/support/software/cell-ranger/latest)



nFeature 代表每个细胞中总基因的数量，nCount 代表每个细胞中总的 UMI 即总转录本的数量，percent.MT 代表每个细胞中线粒体基因Counts 数占 all Counts 的比例，通过设定不同的阈值以过滤细胞（需研究官方文档查看阈值设定规范）





## Process

1. 质控：cellranger 将测序数据比对到 STAR 产生的索引上，输出 barcode 代表列名细胞；feature 代表行名基因名；matrix 代表表达量数据即 A 基因在 B 细胞中的表达量为 C
2. 聚类：PCA 选择维度应当根据拐点，以及 p-value 图来进行选择



## Basic

**UMI（Unique Molecular Indentifier）**：每个细胞中每个 mRNA 或反转录的 cDNA 带有的唯一碱基标识，可作为唯一转录本标记





## Prepare

### 1.Reference

1. 首先 gtf 要过滤
2. mkref 时不要设定输出目录带有 cellranger 的名称，不然会报不是流程目录的错误





### Step1.QC.sh

1. QC.R：nFeature 代表每个细胞中的基因数目，nCount 代表每个细胞中的转录本数量



## Question

- [x] 原始下机数据需符合 cellranger 命名规范
- [ ] web_summary 整个报告每个概念，图代表啥，重要指标都需要搞懂
- [ ] 两张相关性图是否表达基因数越多，转录本数越多；转录本数越少，线粒体 Count 占比越高
- [ ] Rscript 的 future 包并行运行对 cluster.R 脚本收益并不大，相反速度变慢的同时还爆内存