import argparse
import pandas as pd
from pathlib import Path


parser = argparse.ArgumentParser(description="按比较组整理原始计数和样本信息")
parser.add_argument("counts_file")
parser.add_argument("samples_file")
parser.add_argument("comparison")
parser.add_argument("destination")
args = parser.parse_args()
counts_file, samples_file = args.counts_file, args.samples_file
comparison, destination = args.comparison, args.destination
treat, control = comparison.split("_vs_")

# 样本表和计数矩阵都按 ID 选择，避免样本与分组错位。
samples = pd.read_table(samples_file, dtype=str)
counts = pd.read_table(counts_file, dtype={"id": str})
# 固定样本表输出两列，后续 DESeq2 仅使用 group 进行两组比较。
columns = ["sample_id", "group"]

# 两组先处理后对照，每组保留原样本表中的顺序。
selected = pd.concat([
    samples.loc[samples["group"].eq(group), columns]
    for group in (treat, control)
])
folder = Path(destination)
folder.mkdir(parents=True, exist_ok=True)
selected.to_csv(folder / "sample_info.txt", sep="\t", index=False)
counts.loc[:, ["id", *selected["sample_id"]]].to_csv(folder / "COUNT.txt", sep="\t", index=False)
