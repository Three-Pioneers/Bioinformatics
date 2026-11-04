import sys
import argparse
import pandas as pd
from pathlib import Path

if len(sys.argv) == 1:
	print("Usage: python gene_result_pandas.py -i <featureCounts.txt> -o <outdir> -p {true,false}")
	sys.exit(0)

# 1. 获取 featureCounts 结果文件和输出目录
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--count_file", required=True)
parser.add_argument("-o", "--out_dir", required=True)
parser.add_argument("-p", "--paired", required=True, choices=["true", "false"], help="双端测序则为 ture，单端测序则为 false")
args = parser.parse_args()

# 2. 读取计数和基因长度，样本名取 BAM 文件所在的目录名
data = pd.read_csv(args.count_file, sep="\t", comment="#", dtype={"Geneid": str})
gene_lengths = data["Length"]
counts = data.drop(columns=["Geneid", "Chr", "Start", "End", "Strand", "Length"])
counts.columns = [Path(column).parent.name for column in counts.columns]
paired = args.paired == "true"
normalization = "FPKM" if paired else "RPKM"
out_dir = Path(args.out_dir).expanduser().resolve()

# 必要数据无效时直接报错，避免输出缺失值或无穷大
if counts.empty:
    raise ValueError("featureCounts 结果没有基因或样本计数")
if data["Geneid"].isna().any():
    raise ValueError("Geneid 不能为空")
if "" in counts.columns or counts.columns.has_duplicates:
    raise ValueError("样本目录名不能为空或重复")
if gene_lengths.isna().any() or (gene_lengths <= 0).any():
    raise ValueError("Length 必须为非空正数")
if counts.isna().any().any() or (counts < 0).any().any():
    raise ValueError("样本计数必须为非空非负数")

total_counts = counts.sum()
if (total_counts == 0).any():
    raise ValueError("样本总计数不能为 0")

# 3. 按行除以基因长度，按列除以样本总量，计算整个矩阵
rpk = counts.div(gene_lengths, axis="index") * 1e3
per_million = rpk.div(total_counts, axis="columns") * 1e6
tpm = rpk.div(rpk.sum(), axis="columns") * 1e6

# 4. 添加首列 id 到三个计数矩阵的首列
out_dir.mkdir(parents=True, exist_ok=True)
for name, matrix in {"COUNT": counts, normalization: per_million, "TPM": tpm}.items():
    matrix.insert(0, "id", data["Geneid"])
    matrix.to_csv(
        out_dir / f"{name}.txt",
        sep="\t",
        index=False,
        encoding="utf-8",
        lineterminator="\n",
		float_format="%.6g",	# 输出六位有效数字，避免过小数字被错误认定为 0
    )