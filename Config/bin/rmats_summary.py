import sys
from pathlib import Path

import pandas as pd

folder = Path(sys.argv[1])
summary = []
# 逐类读取 JC 事件，未能计算统计量的 NA 不计入 tested。
for event in ("SE", "A5SS", "A3SS", "MXE", "RI"):
    path = folder / (event + ".MATS.JC.txt")
    if not path.is_file():
        raise FileNotFoundError("rMATS 输出不完整：" + str(path))
    table = pd.read_table(path)
    fdr = pd.to_numeric(table["FDR"], errors="raise")
    change = pd.to_numeric(table["IncLevelDifference"], errors="raise")

    # 显著条件沿用 FDR < 0.05 且包含水平变化绝对值 >= 0.1。
    selected = table.loc[(fdr < 0.05) & (change.abs() >= 0.1)].copy()
    selected["FDR"] = fdr.loc[selected.index]
    selected = selected.sort_values("FDR")
    selected.to_csv(folder / (event + ".significant.txt"), sep="\t", index=False)
    summary.append({
        "event": event, "tested": int(fdr.notna().sum()), "significant": len(selected),
        "increased_inclusion": int((change.loc[selected.index] > 0).sum()),
        "decreased_inclusion": int((change.loc[selected.index] < 0).sum()),
    })
    if event == "SE":
        selected.head(10).to_csv(folder / "SE.sashimi.txt", sep="\t", index=False)

pd.DataFrame(summary).to_csv(folder / "splicing_summary.txt", sep="\t", index=False)
