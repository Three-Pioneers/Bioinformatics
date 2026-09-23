# scRNA

单细胞原始下机数据也是 Illumina 测序仪测的，其中 **barcode**（每个细胞唯一的表示条带） 和 **UMI**（Unique Molecular Indentifier：每个细胞中每个 mRNA 或反转录的 cDNA 带有的唯一碱基标识，可作为唯一转录本标记）都是一段 cDNA 序列，而不属于 Fastq 的第一行（要理解这些还是应该把单细胞测序的实验流程，建库流程看一下）

[Cell Ranger](https://www.10xgenomics.com/support/software/cell-ranger/latest)：nFeature 代表每个细胞中总基因的数量，nCount 代表每个细胞中总的 UMI 即总转录本的数量，percent.mt 代表每个细胞中线粒体基因 Counts 数占 all Counts 的比例，通过设定不同的阈值以过滤细胞（需研究官方文档查看阈值设定规范）



**重要**：

1. 更新下流程，了解 scRNA 中 Cellchat 2.x 版本和 Seurat 新版本官方文档，将旧有流程的函数和包全部更新替换
2. 此流程必须要重新搭建，还需要运行 Rstudio server 在本地时刻关注参数、图片、包等信息
3. cellranger 的 outdir 必须是不存在的，而 Snakemake 会自动创建目录，需在命令之初就删除目录后由 cellranger 创建
4. CellChat 内存和线程占用多，注意资源管理
5. monicle3 单个任务线程数大概为 10，

---

## Process

1. 质控：cellranger 将测序数据比对到 STAR 产生的索引上，输出 barcode 代表列名细胞；feature 代表行名基因名；matrix 代表表达量数据即 A 基因在 B 细胞中的表达量为 C
2. 聚类：PCA 选择维度应当根据拐点，以及 p-value 图来进行选择



### Step1.QC.sh

1. QC.R：nFeature 代表每个细胞中的基因数目，nCount 代表每个细胞中的转录本数量

---

## Prepare

### 1.install package

~~~R
# Step1.QC.sh
## 安装最新版本 scDBlFinder，为啥
BiocManager::install("plger/scDblFinder")

# Step8.CellChat.sh
## 安装 CellChat 2.x 版本，不同于服务器的 CellChat 1.6.1 版本，也不是最新的 CellChatV3，最新只在空间转录组可用
pak::pak("jinworks/CellChat")

pak::pak('immunogenomics/presto')
~~~



### 2.Load Data

1. 首先 gtf 要过滤
2. mkref 时不要设定输出目录带有 cellranger 的名称，不然会报不是流程目录的错误

---

## Question

- [x] 原始下机数据需符合 cellranger 命名规范
- [ ] web_summary 整个报告每个概念，图代表啥，重要指标都需要搞懂
- [ ] 两张相关性图是否表达基因数越多，转录本数越多；转录本数越少，线粒体 Count 占比越高
- [ ] Rscript 的 future 包并行运行对 cluster.R 脚本收益并不大，相反速度变慢的同时还爆内存
- [ ] 将所有 R 加载包函数 library() 改为 suppressMessages(library()) 即加载包时不产生过多信息
- [ ] 将脚本包所有的对象重新命名，并且将所有的函数认真解析，最终目标是写解释流程
- [x] 原流程里 --expect-cells 会对细胞数量产生大概 0.01% 的影响，后续就不加了
- [ ] 为啥要过滤两遍双细胞？