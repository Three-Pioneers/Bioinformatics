# scRNA

**bulk RNA-Seq** 中 bulk 表示大部分、主体也就是以细胞群、组织为整体研究，得到的是样本（组织，细胞系）中所有混合细胞的平均基因表达水平。个人认为**主要用于**快速找到整体水平显著变化的差异基因和富集通路。**缺陷**是无法知道基因差异变化是由哪一种细胞类型引起的，同时某些细胞类型中基因差异变化可能会被整体表达水平中和[^1]，比如 10 3 2 和 5 5 5 的表达量是相同的，但是就会平均掉 10 的差异

单细胞原始下机数据也是 Illumina 测序仪测的，其中 **barcode**（每个细胞唯一的表示条带） 和 **UMI**（Unique Molecular Indentifier：每个细胞中每个 mRNA 或反转录的 cDNA 带有的唯一碱基标识，可作为唯一转录本标记）都是一段 cDNA 序列，而不属于 Fastq 的第一行（要理解这些还是应该把单细胞测序的实验流程，建库流程看一下）[^2]

[Cell Ranger](https://www.10xgenomics.com/support/software/cell-ranger/latest)：nFeature 代表每个细胞中总基因的数量，nCount 代表每个细胞中总的 UMI 即总转录本的数量，percent.mt 代表每个细胞中线粒体基因 Counts 数占 all Counts 的比例，通过设定不同的阈值以过滤细胞（需研究官方文档查看阈值设定规范）

极低 mRNA 捕获率可能导致基因表达计数为 0，可进行软件补值；同时不同样本间会出现批次效应[^3]，通过 Seurat 软件的 CCA 和 Harmony 可进行消除。CCA 通过找到样本之间相同的“锚点”，Harmony 通过 PCA 的降维结果整合



**Import**

1. 更新下流程，了解 scRNA 中 Cellchat 2.x 版本和 Seurat 新版本官方文档，将旧有流程的函数和包全部更新替换
2. 此流程必须要重新搭建，还需要运行 Rstudio server 在本地时刻关注参数、图片、包等信息
3. cellranger 的 outdir 必须是不存在的，而 Snakemake 会自动创建目录，需在命令之初就删除目录后由 cellranger 创建
4. CellChat 内存和线程占用多，注意资源管理
5. monicle3 单个任务线程数大概为 10，
6. cellranger 版本最好能更新到 10.1，还增加了模型注释，优点大幅提高了运行速度

---

## Prepare

### cellranger

1. 自己创建单细胞索引时 GTF 需要过滤
2. 建立索引时设定输出目录不能带有 cellranger



### install package

~~~R
# Step1.QC.sh
## 安装最新版本 scDBlFinder，为啥
BiocManager::install("plger/scDblFinder")

# Step8.CellChat.sh
## 安装 CellChat 2.x 版本，不同于服务器的 CellChat 1.6.1 版本，也不是最新的 CellChatV3，最新只在空间转录组可用
pak::pak("jinworks/CellChat")

pak::pak('immunogenomics/presto')
~~~

---

## Step1.Quality Control

cellranger 将下机数据比对到 STAR 索引上，输出 barcode 即列名细胞；feature 即行名基因名；matrix 即表达量矩阵即 A 基因在 B 细胞中的表达量为 C

质控的目的就是去除空液滴、死亡细胞、双细胞以及多细胞，判断阈值需要根据细胞类型[^11]、组织类型[^12]、物种[^13]、建库方法[^14]

如果细胞类型数单一，则由此判断阈值有效；若多类型细胞则阈值没法单一判断，多数情况下不知道包含细胞类型，设定阈值会只保留阈值匹配的细胞类型，对于在阈值之外的数据可能含有高度差异表达的细胞，所以阈值是判断有限范围内或者说大多数的细胞的细胞表达，对极端表达细胞并不友好。**因此我认为在指标或者说阈值选择上，应保留绝大部分的细胞**

去除双细胞使用的软件包 DoubletFinder 或 scDblFinder，通过随机挑选细胞模拟双细胞集，将双细胞集与原始数据合并降维聚类，根据与双细胞的距离判断双细胞。注：scDblFinder 由于随机挑选所以每次的运行结果都不相同，同时其挑选比例随细胞数增加而增大，好像是每一万个细胞就增加百分之八，也就是三万个细胞百分之二十四的双细胞

---

## Step2.Cluster

标准化去除了测序深度对细胞的基因表达影响

聚类：PCA 选择维度应当根据拐点，以及 p-value 图来进行选择

---

## Step4.Annotation

自动注释需要使用 SingleR 软件

---

## Step_7_monocle.sh

**细胞发育轨迹判断**：单细胞测序捕获了单细胞静态下 RNA 的丰度信息，为了分析细胞特征随时间的动态变化过程，得到细胞发育轨迹，开发了根据基因表达模式相似性对细胞排序的拟时序分析

---

## Question

1. cellranger 强制减少大量细胞数，警告 Low Fraction Reads in Cells

大量细胞被去除导致许多 reads 不能比对到 cell 里，从而导致细胞中 read 比例于警告阈值；强制减少细胞，不会改变原有细胞中的 reads 数和 UMI 数量，只是根据 UMI counts 的数量剔除掉在设置的阈值之后的排序的细胞；barcodes 是细胞数，纵坐标 UMI Counts 是转录本数，或者说 mRNA 数，而 feature counts 就是比对将 UMI 归到基因里

2. 酶将油包水结构中的细胞解离然后凝珠上 PolydT 和 mRNA 的 PolyA 尾结合，在 PCR 仪上逆转录成 cDNA 后再扩增，由扩增后 reads 比对到 gene 上的 UMI 种类数量来判断转录本的数量



3. 思考：如果细胞类型数单一，则由此判断阈值有效；若多类型细胞则阈值没法单一判断，多数情况下不知道包含细胞类型，设定阈值会只保留阈值匹配的细胞类型，对于在阈值之外的数据可能含有高度差异表达的细胞，所以阈值是判断有限范围内或者说大多数的细胞的细胞表达，对极端表达细胞并不友好

---

## ToDo

- [ ] 原始下机数据需符合 cellranger 命名规范
- [ ] web_summary 整个报告每个概念，图代表啥，重要指标都需要搞懂
- [ ] 两张相关性图是否表达基因数越多，转录本数越多；转录本数越少，线粒体 Count 占比越高
- [ ] Rscript 的 future 包并行运行对 cluster.R 脚本收益并不大，相反速度变慢的同时还爆内存
- [ ] 将所有 R 加载包函数 library() 改为 suppressMessages(library()) 即加载包时不产生过多信息
- [ ] 将脚本包所有的对象重新命名，并且将所有的函数认真解析，最终目标是写解释流程
- [x] 原流程里 --expect-cells 会对细胞数量产生大概 0.01% 的影响，后续就不加了
- [ ] 为啥要过滤两遍双细胞，也就是 scDefinder 和手动过滤阈值
- [ ] cellranger 的输出报告如何根据指标判断好坏

---

## Reference

[^1]:https://zhuanlan.zhihu.com/p/2020798579149684921
[^2]:https://zhuanlan.zhihu.com/p/584186874
[^11]:神经元细胞、癌细胞、T 细胞不同类型的：基因数，转录本数、线粒体 UMI 比例差异明显
[^12]:不同组织所含有细胞类型、处理方式、筛选阈值都不同
[^13]:不同物种参考基因组线粒体 UMI 比例及基因组注释层级和注释质量、参考基因组版本影响不小
[^14]:测序建库包括：DNA 的提取和质控、片段化 DNA、末端修复加 PolyA 尾巴、加接头、PCR 扩增、磁珠纯化和 qPCR 定量，对于单细胞测序，还包括细胞捕获，所以不同单细胞检测方法产生的数据分布不同
[^3]:样本、时间、测序平台、实验条件等的差异都可能导致批次效应（batch effect）
