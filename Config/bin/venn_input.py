import sys
from pathlib import Path

import pandas as pd

# 各比较保留原始基因 ID 和行序，组名取文件所在目录。
tables = []
for filename in sys.argv[1].split(","):
    source = Path(filename)
    table = pd.read_csv(source, sep="\t", dtype=str, keep_default_na=False)
    table = table.loc[table["id"].ne(""), ["id"]].copy()
    table["group"] = source.parent.name
    tables.append(table)

pd.concat(tables, ignore_index=True).to_csv(
    Path(sys.argv[2]) / "venn_input.txt", sep="\t", index=False, lineterminator="\n",
)
