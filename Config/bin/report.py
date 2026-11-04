import re
import sys
from pathlib import Path

source, target = sys.argv[1:3]
# 报告阈值读取差异脚本开头的设置，不通过命令行重复传值。
settings = Path(__file__).with_name("diffExprGene.R").read_text(encoding="utf-8")
cutoff = re.search(r"^p_cutoff\s*<-\s*([\d.eE+-]+)", settings, re.M)[1]
log2fc = re.search(r"^lfc_cutoff\s*<-\s*([\d.eE+-]+)", settings, re.M)[1]

# 保留模板的换行，按原顺序替换脚本中固定的阈值占位符。
content = Path(source).read_text(encoding="utf-8")
for old, new in [
    ("DIFF_P_COLUMN", "padj"), ("DIFF_P_CUTOFF", cutoff),
    ("LOG2FC_CUTOFF", log2fc), ("ENRICH_P_COLUMN", "p.adjust"),
]:
    content = content.replace(old, new)
Path(target).write_text(content, encoding="utf-8")
