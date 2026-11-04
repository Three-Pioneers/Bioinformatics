import sys
from pathlib import Path

import pandas as pd

# 每个比较统计 Up、Down、No，未出现的方向计数为 0。
records = []
for filename in sys.argv[1].split(","):
    source = Path(filename)
    table = pd.read_csv(source, sep="\t", dtype=str, keep_default_na=False)
    direction = table["Direction"]
    if not direction.isin(["Up", "Down", "No"]).all():
        raise ValueError("差异方向存在未知值：" + filename)
    counts = direction.value_counts().reindex(["Up", "Down", "No"], fill_value=0)
    records.append({
        "group": source.parent.name,
        "Up": counts["Up"], "Down": counts["Down"], "No": counts["No"],
        "Total": len(table),
    })

# 宽表用于报告，长表按每个比较的 Up、Down、No 顺序用于绘图。
result = pd.DataFrame(records, columns=["group", "Up", "Down", "No", "Total"])
long = result.set_index("group")[["Up", "Down", "No"]].rename_axis(columns="direction")
long = long.stack().rename("sum").reset_index()
folder = Path(sys.argv[2])
result.to_csv(folder / "diffExprGene_stats.txt", sep="\t", index=False, lineterminator="\n")
long.to_csv(folder / "diffExprGene_stats_input.txt", sep="\t", index=False, lineterminator="\n")
