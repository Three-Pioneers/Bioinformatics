import glob
import os
import sys

# 查找所有 mapping_count.txt 文件
mapping_count_dir=sys.argv[1]+'/*mapping_count.txt'
files = glob.glob(mapping_count_dir)

data = {}      # 用于存储 { id: { sample: count, ... }, ... }
samples = []   # 记录样本名称

for f in files:
    sample = os.path.basename(f).replace('_mapping_count.txt', '')
    samples.append(sample)
    with open(f) as infile:
        for line in infile:
            parts = line.strip().split('\t')
            if len(parts) < 3:
                continue
            ref_id, mapped = parts[0], parts[2]
            if ref_id == "*":  # 跳过 id 为 "*" 的行
                continue
            if ref_id not in data:
                data[ref_id] = {}
            data[ref_id][sample] = mapped

# 排序样本名称和 id
samples.sort()
ids = sorted(data.keys())

out_file=sys.argv[2]+'/count.txt'
with open(out_file, 'w') as out:
    # 输出表头
    out.write("ID\t" + "\t".join(samples) + "\n")
    for ref_id in ids:
        counts = [data[ref_id].get(s, "0") for s in samples]
        out.write(ref_id + "\t" + "\t".join(counts) + "\n")