import argparse
import json
import sys
import pandas as pd
from pathlib import Path

if len(sys.argv) == 1:
    print("Usage: python fastp_stats.py -i <fastp.json目录> -o <输出目录>")
    sys.exit(0)

# 1. 获取输入、输出目录。
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_fastp_dir", required=True)
parser.add_argument("-o", "--stats_out_dir", required=True)
args = parser.parse_args()

input_dir = Path(args.input_fastp_dir)	# 将 str 转换成 pathlib.Path 对象，方便拼接字符串
output_dir = Path(args.stats_out_dir)	# 同上

# 2. 查找 fastp JSON 文件，按文件名排序。
json_files = sorted(input_dir.glob("*_fastp.json"))
if not json_files:	# input_dir.glob("*_fastp.json") 返回的是 generator 是 False，必须加个 sort() 或者 list()
	raise ValueError(f"未找到 fastp.json：{input_dir}")	# 需要测试路径对没文件和路径不对的情况

# 3. 每个样本保存为一个字典：键是列名，值是该列的数据。
records = []
for json_file in json_files:
	with json_file.open(encoding="utf-8") as input_file:
		data = json.load(input_file)

	sample_id = json_file.name.removesuffix("_fastp.json")
	raw_stats = data["summary"]["before_filtering"]
	clean_stats = data["summary"]["after_filtering"]
	filtering_result = data["filtering_result"]

	raw_total_reads = raw_stats["total_reads"]
	clean_total_reads = clean_stats["total_reads"]

	low_quality_reads = filtering_result["low_quality_reads"]
	too_many_n_reads = filtering_result["too_many_N_reads"]
	too_short_reads = filtering_result["too_short_reads"]

	# 直接计算占原始 reads 的比例
	clean_rate = f"{clean_total_reads / raw_total_reads:.2%}"
	low_quality_rate = f"{low_quality_reads / raw_total_reads:.2%}"
	too_many_n_rate = f"{too_many_n_reads / raw_total_reads:.2%}"
	too_short_rate = f"{too_short_reads / raw_total_reads:.2%}"

	# 数量用千分位且保留两位小数，由于格式化字符所以该表不可用于作图。
	records.append({
		"Sample_ID": sample_id,
		# 原始数据（Raw）
		"Raw_Total_Reads": f"{raw_total_reads:,}",
		"Raw_Total_Bases": f"{raw_stats['total_bases']:,}",
		"Raw_Q20_Bases": f"{raw_stats['q20_bases']:,} ({raw_stats['q20_rate']:.2%})",
		"Raw_Q30_Bases": f"{raw_stats['q30_bases']:,} ({raw_stats['q30_rate']:.2%})",
		"Raw_GC_Content": f"{raw_stats['gc_content']:.2%}",
		# 过滤后的数据（Clean）
		"Clean_Total_Reads": f"{clean_total_reads:,} ({clean_rate})",
		"Clean_Total_Bases": f"{clean_stats['total_bases']:,}",
		"Clean_Q20_Bases": f"{clean_stats['q20_bases']:,} ({clean_stats['q20_rate']:.2%})",
		"Clean_Q30_Bases": f"{clean_stats['q30_bases']:,} ({clean_stats['q30_rate']:.2%})",
		"Clean_GC_Content": f"{clean_stats['gc_content']:.2%}",
		# 被过滤的 reads；必要字段缺失时直接报 KeyError。
		"Low_Quality_Reads": f"{low_quality_reads:,} ({low_quality_rate})",
		"Too_Many_N_Reads": f"{too_many_n_reads:,} ({too_many_n_rate})",
		"Too_Short_Reads": f"{too_short_reads:,} ({too_short_rate})",
	})

# 4. 将所有样本转为 DataFrame，列表中的每个字典成为一行，字典的键成为列名。
stats = pd.DataFrame(records)
output_dir.mkdir(parents=True, exist_ok=True)
stats.to_csv(
	output_dir / "qc_stats.txt",
	sep="\t",
	index=False,  # 不输出 Pandas 自带的行号。
	encoding="utf-8",
	lineterminator="\n",
)