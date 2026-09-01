## ATAC



### 原理

**染色质与染色体结构**：8个由 DNA 缠绕的组蛋白形成约 147 bp 的串珠状的核小体，同一条 DNA 上的核小体经过折叠、聚合在其他架构蛋白的帮助下形成染色体

**开放染色质与染色质可及性**：基因转录时，染色体通过组蛋白修饰（乙酰化）将待转录区域打开，打开后的区域就叫开放染色质；染色质打开后就允许一些调控蛋白（如转录因子）与之结合，称为染色质可及性，这反映了调控蛋白与染色质结合的状态，与转录调控密切相关

[ATAC-Seq（Assay for Transposase-Accessible Chromatin with high throughput Sequencing）](https://zhuanlan.zhihu.com/p/512163334)对携带NGS接头的转座酶剪切后的样本进行测序就知道哪些序列

根据转座酶容易结合开放染色质的特性，人为的将 NGS 标签连接到 Tn5 上，携带接头的 Tn5 进入细胞核后，在开放染色质随意切割并将接头插入到切割位点，这样开放染色质区域就包含大量的NGS 接头，把细胞破碎后提取 DNA 然后根据已知 NGS 接头进行测序，就可以知道哪些开放染色质区域容易结合调控蛋白

https://www.jianshu.com/p/e8f236a98613



### Basic

**TSS（Transcription Start Sites，转录起始位点）**：DNA 链上与 RNA 链第一个核苷酸对应的碱基

**TES（Transcription End Sites，转录终止位点）**：

**DNA 转座**：由 DNA 转座酶介导的将 DNA 序列从染色体的一个区域插入到另一个区域的现象

~~~bash
/data3/Data_all/Software/miniconda3/bin/computeMatrix scale-regions -S Z733-2_bowtie2_sort.bigwig Z733-1_bowtie2_sort.bigwig  -R /data3/2026_05/XuTuo_2_MaGuZi_ATAC/ref/gene.bed -b 3000 -a 3000 -out Matrix.txt.gz --binSize 150 --regionBodyLength 4500 -p 40 --missingDataAsZero --metagene
/data3/Data_all/Software/miniconda3/bin/plotHeatmap -m Matrix.txt.gz --samplesLabel Z733-2 Z733-1  -out TSS_Heatmap.png --heatmapHeight 12 --heatmapWidth 5 --regionsLabel 'Genes' --startLabel TSS --endLabel TES --yAxisLabel 'ATAC signal' --colorMap YlGnBu --plotTitle 'Genes' --dpi 300
~~~



### Question

- [x] 若热图相关性图需**规定样本顺序**，必须在 .conf 中确认重命名，无重命名后面跟本身即可，然后按所需顺序填写
- [x] bw 生成 Matrix 的步骤，小于 bin size 的会过滤掉，现有信号图曲线会不平滑，考虑 bin size 设置大一点 1000；或者干脆不要过滤
  不要先默认 10 就可以

- [x] 拿 GTF 文件来做 computeMatrix
  拿 gene.bed 做，因为 GTF 包含 exon、gene、CDS 等，==ATAC 是关于基因的？==
- [x] ATAC 第三步 read_distribution.sh 不可以同时运行，他们会争抢阅读 tmp 和 基因组文件