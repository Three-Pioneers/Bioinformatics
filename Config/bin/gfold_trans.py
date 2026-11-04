import sys
from pathlib import Path

import pandas as pd


source, counts_file, destination = map(Path, sys.argv[1:4])
counts = pd.read_table(counts_file, dtype={"id": str}).set_index("id")
if counts.index.duplicated().any() or counts.isna().any().any() or counts.shape[1] < 2:
    raise ValueError("COUNT 矩阵存在重复 ID、缺失计数或缺少比较样本")
means = counts.mean(axis=1)

# GFOLD 注释行以 # 开头；每个数据行至少包含 7 列。
try:
    rows = pd.read_table(
        source, comment="#", header=None, usecols=range(7),
        dtype=str, keep_default_na=False, engine="python",
    )
except pd.errors.EmptyDataError:
    rows = pd.DataFrame(columns=range(7))
if rows.isna().any().any() or not rows[0].isin(means.index).all():
    raise ValueError("GFOLD 输出行不完整或基因不匹配")

# GFOLD 分数决定方向，原始 log2FC 单独保存。
data = pd.DataFrame({
    "id": rows[0],
    "baseMean": rows[0].map(means),
    "log2FoldChange": rows[4].astype(float),
    "GFOLD_score": rows[2].astype(float),
    "E-FDR": rows[3].astype(float),
})
data["Direction"] = "No"
data.loc[data["GFOLD_score"].gt(0), "Direction"] = "Up"
data.loc[data["GFOLD_score"].lt(0), "Direction"] = "Down"

data.to_csv(destination / "All_genes_exprData.txt", sep="\t", index=False)
data.loc[data["Direction"].ne("No")].to_csv(destination / "Sig_genes_exprData.txt", sep="\t", index=False)
pd.DataFrame({
    "parameter": ["method", "contrast", "criterion"],
    "value": ["GFOLD", counts.columns[0] + " vs " + counts.columns[1],
              "GFOLD score != 0; no biological replication"],
}).to_csv(destination / "analysis_parameters.tsv", sep="\t", index=False)
