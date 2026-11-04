import sys
from pathlib import Path

import pandas as pd


diff_file, output, counts_file, annotation_file = map(Path, sys.argv[1:5])
data = pd.read_table(diff_file, dtype={"id": str})
counts = pd.read_table(counts_file, dtype={"id": str})
if data["id"].duplicated().any() or counts["id"].duplicated().any():
    raise ValueError("差异表或计数矩阵存在重复 ID")
if not data["id"].isin(counts["id"]).all():
    raise ValueError("计数矩阵缺少差异表中的基因 ID")

# 计数为必要数据，注释文件可选；保持差异表原来的行顺序。
data = data.merge(counts, how="left", on="id", validate="one_to_one", sort=False)
if annotation_file.is_file():
    annotation = pd.read_table(annotation_file, dtype=str).fillna("--")
    annotation = annotation.rename(columns={annotation.columns[0]: "_raw_id"})
    annotation["_raw_id"] = annotation["_raw_id"].str.replace(r"\(.*$", "", regex=True)
    # 一对多功能合入同一单元格，不扩增差异表行数。
    annotation = annotation.groupby("_raw_id", sort=False).agg(
        lambda values: " | ".join(values.drop_duplicates())
    )
    data["_raw_id"] = data["id"].str.replace(r"\(.*$", "", regex=True)
    data = data.join(annotation, on="_raw_id", rsuffix="_annotation").drop(columns="_raw_id")

data.fillna("--").to_csv(output, sep="\t", index=False)
