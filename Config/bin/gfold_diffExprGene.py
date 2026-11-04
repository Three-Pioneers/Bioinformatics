import sys
from pathlib import Path

import pandas as pd

count_file, sample_file, treat, control, destination, length_file = sys.argv[1:7]
folder = Path(destination)
data = pd.read_table(count_file, dtype={"id": str})
samples = pd.read_table(sample_file, dtype=str).set_index("sample_id")
if treat == control or not {treat, control} <= set(data.columns) or not {treat, control} <= set(samples.index):
    raise ValueError("GFOLD 的两个样本与输入表不匹配")

# 按原始基因 ID 查找真实长度，保留 COUNT 中的名称注释和行序。
lengths = pd.read_table(length_file, dtype={"id": str}).set_index("id")["length"]
if not lengths.index.is_unique:
    raise ValueError("基因长度表的 id 不能重复")
gene_ids = data["id"].str.replace(r"\(.*$", "", regex=True)
data["_length"] = lengths.loc[gene_ids].to_numpy()
if data[["id", treat, control, "_length"]].isna().any().any() or (data["_length"] <= 0).any():
    raise ValueError("GFOLD 缺少计数或真实基因长度，请先运行第3步")
if samples.loc[[treat, control], "group"].isna().any():
    raise ValueError("GFOLD 样本缺少分组")

for label, name in [("treat", treat), ("control", control)]:
    # 五列依次为基因 ID、名称、计数、真实长度、RPKM。
    table = pd.DataFrame({
        "id": data["id"], "name": data["id"],
        "count": data[name], "length": data["_length"],
    })
    total = table["count"].sum()
    table["RPKM"] = table["count"] * 1e9 / (table["length"] * total) if total else 0.0
    table.to_csv(folder / (label + ".txt"), sep="\t", header=False, index=False)

data[["id", treat, control]].to_csv(folder / "COUNT.txt", sep="\t", index=False)
samples.loc[[treat, control], ["group"]].to_csv(folder / "sample_info.txt", sep="\t")
