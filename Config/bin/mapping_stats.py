import sys
import argparse
import pandas as pd
from pathlib import Path

if len(sys.argv) == 1:
	print("Usage: python mapping_stats.py -i <summary.txt1,summary.txt2> -o <outdir>")
	sys.exit(0)


# 1. 获取输入文件列表和输出目录
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--summary_list", required=True)
parser.add_argument("-o", "--out_dir", required=True)
args = parser.parse_args()

# 2. 逐个读取汇总文件，每行按第一个冒号拆成字段名和字段值。
records = []
for file_path in args.summary_list.split(","):
	summary_file = Path(file_path.strip()).resolve()
	summary = {}
	with summary_file.open(encoding="utf-8") as input_file:
		for line in input_file:
			if ":" in line[1:]:
				name, value = line.split(":", 1)
				summary[name.strip()] = value.strip()

	# 保留旧版计数口径：双端为 read pairs 数，单端为 reads 数。
	# Total unpaired reads 是未成对比对的 mates，不加入输入总数。
	if "Total pairs" in summary:
		input_reads = int(summary["Total pairs"])
	else:
		input_reads = int(summary["Total reads"])

	# 必要字段直接读取；缺失时抛出 KeyError，不补默认值。
	records.append({
		"sample_id": summary_file.parent.name,
		"total_pairs": input_reads,
		"aligned_1_time_pairs": summary["Aligned concordantly 1 time"],
		"unaligned_reads": summary["Aligned 0 time"].split(" ")[0],
		"overall_rate": summary["Overall alignment rate"],
	})

# 3. 一个字典对应一行，字典的键作为列名，统一导出制表符分隔表。
stats = pd.DataFrame(records)
output_dir = Path(args.out_dir)
output_dir.mkdir(parents=True, exist_ok=True)
stats.to_csv(
	output_dir / "mapping_stats.txt",
	sep="\t",
	index=False,
	encoding="utf-8",
	lineterminator="\n",
)