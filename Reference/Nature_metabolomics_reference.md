# Nature 代谢组学经典论文推荐

## 1. 推荐论文

### Human metabolic individuality in biomedical and pharmaceutical research

中文可译为：**《生物医学与药物研究中的人类代谢个体差异》**

| 项目 | 信息 |
|---|---|
| **期刊** | **Nature 主刊** |
| **作者** | Karsten Suhre 等 |
| **发表时间** | 2011 年 8 月 31 日 |
| **卷页** | Nature **477**, 54–60 |
| **DOI** | `10.1038/nature10354` |

论文官网：

https://www.nature.com/articles/nature10354

DOI：

https://doi.org/10.1038/nature10354

这是一篇非常经典的代谢组学研究。论文将 **2,820 人的非靶向代谢组学数据与全基因组关联分析（GWAS）结合**，研究遗传差异怎样与血液代谢物水平相关，并识别出多个与代谢物变化显著相关的遗传位点。

它更偏向于：

- 非靶向代谢组学
- 人群代谢差异
- 代谢物定量/相对丰度
- GWAS 与代谢组联合分析
- 代谢物质量控制
- 代谢物注释与分类
- 统计关联分析

而不是单纯的“处理组 vs 对照组差异代谢物分析”。

---

# 2. 最值得下载的补充材料

论文网页下方有 **Supplementary Information** 和 **Supplementary Data**。

## Supplementary Information

这是一个大约 **100 页的 PDF**，非常适合作为代谢组学分析报告和补充材料格式的参考。

下载链接：

https://media.springernature.com/original/springer-static/esm/art%3A10.1038%2Fnature10354/MediaObjects/41586_2011_BFnature10354_MOESM279_ESM.pdf

其中包括：

- 代谢物列表
- 代谢物分类
- 代谢通路
- 检测平台信息
- 样本中代谢物检出情况
- 质量控制
- QC 样本的变异系数
- 统计分析说明
- 关联分析结果
- 研究设计
- 分析流程图
- Supplemental Tables
- Supplemental Figures

如果你的目的是参考“代谢分析报告应该包含哪些内容”，建议优先看这个 PDF。

---

# 3. Supplementary Data

论文还有 Supplementary Data，通常以 ZIP 或表格形式提供。

其中主要包括：

- KORA 队列结果
- TwinsUK 队列结果
- GWAS 与代谢物关联结果
- 不同代谢物对应的遗传关联信息
- 补充统计表

需要注意：

**这些数据不是典型的逐样本原始代谢物丰度矩阵。**

也就是说，不一定是这种形式：

| Sample | Metabolite_1 | Metabolite_2 | Metabolite_3 |
|---|---:|---:|---:|
| S1 | 123 | 52 | 99 |
| S2 | 150 | 61 | 88 |
| S3 | 132 | 45 | 102 |

它更偏向于已经整理过的统计分析结果和遗传关联结果。

---

# 4. 最值得参考的表格

建议重点查看 Supplementary PDF 中的：

## Supplemental Table 1

这张表比较适合参考代谢物数据库和代谢分析结果的组织方式。

其中包含的信息包括：

- Metabolite name
- Metabolite class
- Metabolic pathway
- Detection platform
- 样本中的检出数量
- QC 相关信息
- 变异系数
- 化合物身份确认信息

部分代谢物使用星号等符号标记，表示其身份可能依赖：

- MS/MS 碎片谱
- 标准品
- 保留时间
- 数据库匹配
- 推定鉴定

因此这篇文章也比较适合参考：

**“代谢物鉴定可信度应该怎样在结果中表示”。**

---

# 5. 对联合代谢物数据库的参考价值

如果你正在建立联合代谢物数据库，这篇文章可以参考它的代谢物信息组织方式。

例如可以设计为：

| compound_id | compound_name | class | pathway | HMDB | KEGG | PubChem | ChEBI | InChIKey |
|---|---|---|---|---|---|---|---|---|

对于多个数据库 ID，可以进一步增加链接。

例如：

| Compound | HMDB | KEGG | PubChem |
|---|---|---|---|
| Glucose | [HMDB0000122](https://hmdb.ca/metabolites/HMDB0000122) | [C00031](https://www.genome.jp/entry/C00031) | [5793](https://pubchem.ncbi.nlm.nih.gov/compound/5793) |

这样在 Markdown、HTML 或 Excel 中都可以实现点击数据库 ID 跳转到对应数据库。

---

# 6. 建议联合数据库保存的信息

推荐数据库内部至少保存：

```text
internal_compound_id
preferred_name
synonyms
molecular_formula
exact_mass
monoisotopic_mass
SMILES
canonical_SMILES
isomeric_SMILES
InChI
InChIKey
HMDB_ID
KEGG_ID
PubChem_CID
ChEBI_ID
LIPID_MAPS_ID
MetaCyc_ID
CAS_Number
database_source
source_url
identification_level
```

其中尤其推荐使用：

- **InChIKey**
- **InChI**
- **Isomeric SMILES**

来辅助跨数据库去重。

因为：

**化合物名称不是可靠的唯一标识。**

同一个代谢物可能存在：

- 系统名称
- 常用名称
- 传统名称
- 数据库别名
- 盐形式名称
- 水合物名称
- 不同立体异构体名称

因此做联合数据库时，不建议只根据名字合并。

---

# 7. 关于代谢物“唯一性”

例如：

```text
2-amino-3-(1-methyl-1H-imidazol-4-yl)propanoic acid hydrate
```

和：

```text
4-methyl-histidine hydrate
```

可能在某些数据库中作为同一个 compound 条目的不同名称字段出现。

但：

**名称本身不能保证绝对唯一。**

需要继续核对：

- 分子式
- InChI
- InChIKey
- SMILES
- 立体构型
- 盐型
- 水合物状态

尤其是 `hydrate` 这种写法，如果没有说明：

```text
monohydrate
dihydrate
```

或者明确化学计量比，就可能不能完整限定水合物组成。

---

# 8. 联合数据库推荐的数据结构

更推荐将“化合物”和“外部数据库 ID”拆开保存。

例如主表：

```text
compound
------------------------
compound_id
preferred_name
formula
exact_mass
inchi
inchikey
smiles
```

外部数据库映射表：

```text
compound_xref
------------------------
compound_id
database
external_id
external_url
```

例如：

```text
CMP000001    HMDB       HMDB0000122
CMP000001    KEGG       C00031
CMP000001    PubChem    5793
CMP000001    ChEBI      CHEBI:17234
```

这样一个 compound 可以对应多个数据库。

优点：

1. 不需要为每一个数据库增加一列。
2. 后面增加新的数据库非常方便。
3. 同一个数据库存在多个 ID 时也可以保存。
4. 更容易生成 Markdown、HTML 和 Excel 超链接。
5. 更适合程序自动维护。

---

# 9. 数据库链接展示

## Markdown

```markdown
[HMDB0000122](https://hmdb.ca/metabolites/HMDB0000122)
```

显示为：

[HMDB0000122](https://hmdb.ca/metabolites/HMDB0000122)

---

## HTML

```html
<a href="https://hmdb.ca/metabolites/HMDB0000122">HMDB0000122</a>
```

---

## Excel

可以使用：

```excel
=HYPERLINK("https://hmdb.ca/metabolites/"&A2,A2)
```

或者在生成 `.xlsx` 时直接给单元格绑定 hyperlink。

---

# 10. CSV / TSV 的限制

CSV 和 TSV 本质上是纯文本。

可以保存：

```text
HMDB_ID    HMDB_URL
HMDB0000122    https://hmdb.ca/metabolites/HMDB0000122
```

但文件本身没有真正意义上的“超链接对象”。

是否能够点击，取决于：

- Excel
- LibreOffice
- 数据查看软件
- 网页界面

是否自动把网址识别为链接。

因此：

**如果目标是让用户直接点击数据库 ID，优先推荐 `.xlsx` 或 HTML。**

Markdown 也可以，但不是唯一方式。

---

# 11. 最终建议

如果要建立一个长期使用的联合代谢物数据库，推荐：

```text
原始数据库
   ↓
统一 compound
   ↓
结构标准化
   ↓
InChIKey / SMILES 去重
   ↓
维护 compound ↔ database ID 映射
   ↓
输出
   ├── TSV/CSV：用于分析
   ├── XLSX：用于人工查看和点击链接
   ├── Markdown：用于文档和 GitHub
   └── HTML：用于真正的数据库浏览页面
```

其中：

**底层数据库不要直接保存 Markdown 链接格式。**

推荐保存：

```text
database = HMDB
external_id = HMDB0000122
external_url = https://hmdb.ca/metabolites/HMDB0000122
```

展示时再转换成 Markdown / HTML / Excel hyperlink。

这样最稳定，也最适合后续扩展。

---

# 参考链接

Nature 论文：

https://www.nature.com/articles/nature10354

DOI：

https://doi.org/10.1038/nature10354

Supplementary Information PDF：

https://media.springernature.com/original/springer-static/esm/art%3A10.1038%2Fnature10354/MediaObjects/41586_2011_BFnature10354_MOESM279_ESM.pdf
