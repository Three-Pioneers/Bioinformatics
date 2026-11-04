import math
import sys
from pathlib import Path

import pandas as pd

# 按基因 ID 读取差异方向，去掉名称注释，重复 ID 沿用最后一条记录。
expression = pd.read_csv(sys.argv[2], sep="\t", dtype=str, keep_default_na=False)
expression["id"] = expression["id"].str.replace(r"\(.*$", "", regex=True)
directions = expression.drop_duplicates("id", keep="last").set_index("id")["Direction"]

classes = {
    "biological_process": "BP", "cellular_component": "CC",
    "molecular_function": "MF", "BP": "BP", "CC": "CC", "MF": "MF",
}
terms = pd.read_csv(sys.argv[1], sep="\t", dtype=str, keep_default_na=False)
terms = terms.loc[terms["class"].isin(classes)].copy()

# BgRatio 的分子是该功能的背景基因数，p.adjust 用于计算富集得分。
background = pd.to_numeric(terms["BgRatio"].str.split("/").str[0]).astype(int)
count = pd.to_numeric(terms["Count"]).astype(int)
adjusted = pd.to_numeric(terms["p.adjust"])
if (background <= 0).any() or adjusted.isna().any():
    raise ValueError("GO 背景基因数必须大于 0，p.adjust 不能为空")

# 一个富集条目可包含多个基因；缺少基因方向时直接报错。
genes = terms["geneID"].str.split("/").explode()
regulation = directions.loc[genes].set_axis(genes.index)
up = regulation.eq("Up").groupby(level=0, sort=False).sum().reindex(terms.index)
down = regulation.eq("Down").groupby(level=0, sort=False).sum().reindex(terms.index)

result = pd.DataFrame({
    "id": terms["ID"],
    "category": terms["class"].map(classes),
    "background": background,
    "Count": count,
    "score": adjusted.clip(lower=sys.float_info.min).map(lambda value: -math.log10(value)),
    "Up": up,
    "Down": down,
    "RichFactor": count / background,
})
result.to_csv(Path(sys.argv[3]) / "GO_circlize_input.txt", sep="\t", index=False, lineterminator="\n")
