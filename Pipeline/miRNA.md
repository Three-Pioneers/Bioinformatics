## miRNA

miRNA 入手分析 small RNA：占比大；易建库；公共数据库维护好；生信分析快且容易

1. 质控：原始 fastq 数据
2. 去接头、质控
3. 筛选 18–30 nt 小 RNA
4. 去除 rRNA/tRNA/snRNA/snoRNA/repeat
5. 比对参考基因组
6. 已知 miRNA 鉴定
7. novel miRNA 预测
8. miRNA 表达量统计
9. 差异表达分析
10. 靶基因预测
11. GO/KEGG 富集
12. miRNA-target 调控网络



### miRDeep2

**mapper.pl**

成熟 miRNA 是 22nt，没有二级结构，要根据二级结构预测miRNA，就要找到有发夹结构的 miRNA 前体

**gfold**：广义 Fold Change 对 RNA-Seq 中的差异表达基因排序，无重复时尤其适合

**quafiler.pl**



### Basic

**small RNA（小 RNA）**：长度18-40 nt，起转录后调控作用的非编码 RNA

**3’UTR（3’ UnTranslated Region）**：成熟 mRNA 分子中在终止密码子后，PolyA 前的非翻译区

**HairPin（发夹结构）**：DNA、RNA中的单链核酸碱基配对部分形成 “茎”，没有配对部分形成 “环”

**mRNA（messenger RNA，信使 RNA）**：

**rRNA（ribosomal RNA，核糖体 RNA）**：

**tRNA（transfer RNA，转运 RNA）**：

**snRNA（small nuclear RNA，核小 RNA）**：负责 mRNA 前体的加工

**snoRNA（small nucleolar RNA，核仁小 RNA）**：指导 rRNA、tRNA、snRNA 的化学修饰

crRNA（）

**piRNA（）**：特异性 piwi 蛋白结合发挥作用



### Question

- [ ] 当前版本 miRNA 前提序列和成熟序列都太老旧，已知 miRNA 定量时 miRDeep2.pl 参数要加 -P，预测可以不用
  但是，第六步，加了 -P 后，将加 -P 前后的两个表合起来，总共470行，排序去重后，还有370行，说明有问题
- [x] gfold 运行报错：error while loading shared libraries: libgsl.so.0: cannot open shared object file: No such file or directory
  在环境目录下 lib 文件夹：ln libgsl.so.25.1.0* libgsl.so.0 即可成功，后续出问题需注意！
- [ ] conf 文件 DB_version Soybean 有好多个
- [ ] gene_descript 这个是啥，没查到
- [ ] 物种缩写之类的有官网查吗；物种的数字编号是啥，用脚本说模块没有，环境不对
- [ ] ncRNA_TargetGene_analysis = false 这步是默认非吗
- [ ] Step_4_RepeatMasker.sh 运行过慢
  该软件分两步，第一步比对，第二部整理结果；慢的是第二步，可拆分数据，分成多个小份，先串行跑比对，然后并行跑整理，最后合并结果
  拆分会造成重复序列出现在不同的小份数据中，整理后会出现同一序列出现多次在 repeat 的地方 
  搞不懂不去重跑一个样本，和分成小份有啥区别