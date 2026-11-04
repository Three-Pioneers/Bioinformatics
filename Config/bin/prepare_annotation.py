"""第五步：按固定文件模式整理参考功能注释，不展开 shell 复制循环。"""
import shutil
import sys
from glob import escape, glob
from pathlib import Path

annotation_dir, output_dir = map(Path, sys.argv[1:3])
with_names = sys.argv[3].lower() == 'true'
output_dir.mkdir(parents=True, exist_ok=True)
patterns = ['*/*function_id.txt', '*/stats*.txt']
if with_names:
    patterns.append('*/*function_id_name_all.txt')
for pattern in patterns:
    for source in sorted(glob(escape(str(annotation_dir)) + '/' + pattern)):
        shutil.copyfile(source, output_dir / Path(source).name)
