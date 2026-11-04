import sys
import pandas as pd
from pathlib import Path

if len(sys.argv) == 1:
	print("Usage: python gene_name_result_stats.py <gene_name.txt> <input_dir>")
	sys.exit(0)

mapping_file, input_dir = map(Path, sys.argv[1:])
input_dir = input_dir.resolve()
names = (
    pd.read_csv(mapping_file, sep="\t", header=None, dtype=str, na_filter=False, quoting=3)	# 保留原来的缺失值，不加则转换为 NA；保留引号不要进行解析
    .drop_duplicates(0, keep="last")	# 相同 id 只保留最后一条
    .set_index(0)[1]	# 以第 0 列为键，第 1 列为值
)

for filename in ("COUNT.txt", "FPKM.txt", "RPKM.txt", "TPM.txt"):
    path = input_dir / filename
    if not path.is_file():
        continue
    with path.open(encoding="utf-8") as source:
        header = source.readline()
        data = pd.read_csv(source, sep="\t", header=None, dtype=str, na_filter=False, quoting=3)

    gene_names = data[0].map(names).astype("string")	# data[0] 去匹配 name 里的 id 索引，返回 gene_name 的值，匹配失败则是 NA，string 类型下 NAN 等都变成 NA
    data[0] += ("(" + gene_names + ")").fillna("")	# NA 加上任何字符串都是 NA，再把 NA 填充成 ""

    for label, result in (("2.Gene_name_part", data.loc[gene_names.notna()]),
                          ("3.Gene_name_all", data)):
        directory = input_dir.parent / label
        directory.mkdir(parents=True, exist_ok=True)
        with (directory / filename).open("w", encoding="utf-8", newline="") as output:	# newline="" 使得文件在 Linux 和 Windows 都保持 Linux 风格
            output.write(header)
            result.to_csv(output, sep="\t", index=False, header=False, quoting=3, lineterminator="\n")