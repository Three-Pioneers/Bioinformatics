import sys
from contextlib import ExitStack
from pathlib import Path

import pandas as pd

folder, sample_file = map(Path, sys.argv[1:3])
comparisons = sys.argv[3].split(",")
samples = pd.read_csv(sample_file, sep="\t", dtype=str, keep_default_na=False)
samples = samples[["sample_id", "group"]]
if samples["sample_id"].duplicated().any() or samples.eq("").any().any():
    raise ValueError("样本 ID 不能重复，样本和分组不能为空")
fields = ["sample_id", "group", "CHROM", "POS", "REF", "ALT", "QUAL", "FILTER", "GT", "AD", "DP"]

# 数量汇总保留全部样本，包括没有通过过滤位点的样本。
counts = samples.set_index("sample_id").copy()
counts["SNP"] = 0
counts["InDel"] = 0
for kind, plural, count_column in [("snp", "snps", "SNP"), ("indel", "indels", "InDel")]:
    # 分块合并长表，样本较多时不把所有位点同时读入内存。
    with ExitStack() as stack:
        outputs = []
        for name in ["all_sample", *comparisons]:
            handle = stack.enter_context((folder / kind / (name + "_" + plural + "_stats.txt")).open("w", encoding="utf-8", newline=""))
            pd.DataFrame(columns=fields).to_csv(handle, sep="\t", index=False, lineterminator="\n")
            outputs.append(handle)
        for sample in samples.itertuples(index=False):
            source = folder / kind / (sample.sample_id + "_" + plural + "_stats.txt")
            chunks = pd.read_csv(source, sep="\t", dtype=str, keep_default_na=False, chunksize=50000)
            for chunk in chunks:
                # 同时接受 GT/AD/DP 和样本名前缀列；必要调用列缺失直接报错。
                rename = {
                    sample.sample_id + "." + field: field
                    for field in fields[2:] if field not in chunk.columns
                }
                result = chunk.rename(columns=rename)[fields[2:]].copy()
                result.insert(0, "group", sample.group)
                result.insert(0, "sample_id", sample.sample_id)
                counts.loc[sample.sample_id, count_column] += len(result)
                result.to_csv(outputs[0], sep="\t", header=False, index=False, lineterminator="\n")
                # 比较表只收集两组已调用结果，不填补缺失基因型或推断显著性。
                for name, handle in zip(comparisons, outputs[1:]):
                    if sample.group in name.split("_vs_"):
                        result.to_csv(handle, sep="\t", header=False, index=False, lineterminator="\n")

counts.reset_index().to_csv(folder / "variant_summary.txt", sep="\t", index=False, lineterminator="\n")
