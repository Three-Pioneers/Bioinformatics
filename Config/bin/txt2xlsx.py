import csv
import math
import re
import sys
from pathlib import Path

from openpyxl import Workbook
from openpyxl.cell import WriteOnlyCell

illegal = re.compile(r"[\x00-\x08\x0B\x0C\x0E-\x1F]")
number = re.compile(r"^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$")
analysis = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "analysis"
skip = {"8.rMATS", "9.Variance_Calling", "result", "work_sh", "config", "report", "validation"}

def convert(source, target):
    workbook = Workbook(write_only=True)
    sheet = workbook.create_sheet("Sheet1")
    rows = 0
    truncated = 0

    # 单个源字段可以超过 CSV 默认上限；Excel 长度限制仍在下方处理。
    field_limit = sys.maxsize
    while True:
        try:
            csv.field_size_limit(field_limit)
            break
        except OverflowError:
            field_limit //= 10
    # 流式读取变长 TSV，保留每行的全部字段、空字段与空行，不跳过不规则行。
    with source.open(encoding="utf-8-sig", newline="") as handle:
        for row_number, row in enumerate(csv.reader(handle, delimiter="\t")):
            # 超过 Excel 单页行上限时续表，源 TSV 始终保留完整内容。
            if rows >= 1048576:
                sheet = workbook.create_sheet()
                rows = 0
            cells = []
            for column, value in enumerate(row):
                value = illegal.sub("", value).strip()
                if len(value) > 32767:
                    value = value[:32764] + "..."
                    truncated += 1
                # 第一列保留 ID；数据区仅转换明确、有限且不会损失整数精度的数值。
                if column > 0 and row_number > 0 and number.fullmatch(value):
                    parsed = float(value)
                    if math.isfinite(parsed) and (not parsed.is_integer() or abs(parsed) < 1e15):
                        cells.append(int(parsed) if parsed.is_integer() else parsed)
                        continue
                cell = WriteOnlyCell(sheet, value=value)
                cell.data_type = "s"
                cells.append(cell)
            sheet.append(cells)
            rows += 1
    temporary = target.with_name(target.stem + ".writing.xlsx")
    workbook.save(temporary)
    temporary.replace(target)
    if truncated:
        print("WARN", source, f"{truncated} cells exceeded Excel length limit; complete data retained in TSV")

# 跳过重复展示目录、符号链接和已更新的 Excel 文件。
failures = []
pending = [analysis]
while pending:
    folder = pending.pop()
    entries = sorted(folder.iterdir(), key=lambda path: path.name)
    directories = [
        path for path in entries
        if not path.is_symlink() and path.is_dir()
        and path.name not in skip and not path.name.startswith("result.previous_")
    ]
    pending.extend(reversed(directories))
    for source in entries:
        if not source.is_file():
            continue
        if source.suffix.lower() != ".txt" or source.is_symlink():
            continue
        with source.open(encoding="utf-8-sig") as handle:
            if "\t" not in handle.readline():
                continue
        target = source.with_suffix(".xlsx")
        if target.is_file() and target.stat().st_mtime >= source.stat().st_mtime:
            continue
        try:
            convert(source, target)
            print("OK", source)
        except Exception as error:
            failures.append(str(source))
            print("ERROR", source, error, file=sys.stderr)
if failures:
    raise SystemExit(1)
