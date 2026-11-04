import sys
from pathlib import Path

import pandas as pd


# 按列名选取显著性最高的 50 个基因，输出顺序沿用 COUNT 矩阵。
folder = Path(sys.argv[1])
data = pd.read_table(folder / "Sig_genes_exprData.txt", dtype=str, keep_default_na=False)
if "GFOLD_score" in data.columns:
    scores = -pd.to_numeric(data["GFOLD_score"], errors="raise").abs()
    if scores.isna().any():
        raise ValueError("GFOLD_score 不能缺失")
else:
    column = "padj" if "padj" in data.columns else "E-FDR"
    # 无有效显著性数值的基因排在末尾，不影响有效数值的排序。
    scores = pd.to_numeric(data[column], errors="coerce").fillna(float("inf"))

selected = data.loc[scores.sort_values(kind="stable").index[:50], "id"]
counts = pd.read_table(folder / "COUNT.txt", dtype=str, keep_default_na=False)
counts.loc[counts.iloc[:, 0].isin(selected)].to_csv(folder / "heatmap_input.txt", sep="\t", index=False)
