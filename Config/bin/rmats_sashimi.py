import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import pandas as pd


def main():
    if len(sys.argv) != 3:
        raise SystemExit('用法：rmats_sashimi.py <rmats2sashimiplot> <比较目录>')
    software, directory = sys.argv[1:]
    folder = Path(directory).resolve(strict=True)
    if not folder.is_dir():
        raise NotADirectoryError(str(folder))

    # 只清理比较目录内本工具生成的旧图和索引，不跟随目录链接。
    def remove_output(path):
        if path.parent != folder or not (path.name == 'Sashimi_plot' or
                path.name == 'Sashimi_index' or path.name.startswith('Sashimi_index_')):
            raise ValueError('不能清理比较目录外的文件：' + str(path))
        if path.is_symlink() or path.is_file():
            path.unlink()
        elif path.is_dir():
            shutil.rmtree(path)

    events = folder / 'SE.sashimi.txt'
    with events.open() as handle:
        next(handle, None)
        event_rows = pd.Series(list(handle), dtype='string')
    event_count = int(event_rows.str.strip().ne('').sum())
    caches = list(folder.glob('Sashimi_index*'))
    caches = [path for path in caches if path.name == 'Sashimi_index' or
              path.name.startswith('Sashimi_index_')]
    if not event_count:
        for path in [folder / 'Sashimi_plot'] + caches:
            remove_output(path)
        print('没有可绘制的 SE 事件，跳过 Sashimi 图。')
        return

    # 样本数量和分组名称从现有输入读取，样式不需要在 sh 中逐项填写。
    groups = folder.name.split('_vs_', 1)
    if len(groups) != 2 or not all(groups):
        raise ValueError('比较目录名称应为：处理组_vs_对照组')
    bam_groups = []
    for name in ('treat.list', 'control.list'):
        bams = pd.Series((folder / name).read_text().split(','), dtype='string').str.strip()
        bam_groups.append(bams[bams.ne('')].tolist())
    if not all(bam_groups):
        raise ValueError('处理组和对照组都需要至少一个 BAM 文件。')
    sample_count = sum(map(len, bam_groups))
    colors = ['#D55E00'] * len(bam_groups[0]) + ['#0072B2'] * len(bam_groups[1])
    environment = os.environ.copy()
    environment['MATPLOTLIBRC'] = str(Path(__file__).resolve().parent / 'src/libs/matplotlibrc')

    # 独立缓存避免混用旧 BAM；绘图失败时保留原有正式图片。
    with tempfile.TemporaryDirectory(prefix='.sashimi_tmp.', dir=folder) as temporary:
        subprocess.run([software, '--b1', ','.join(bam_groups[0]),
                        '--b2', ','.join(bam_groups[1]), '--event-type', 'SE',
                        '-e', str(events), '--l1', groups[0], '--l2', groups[1],
                        '-o', temporary, '--font-size', '10', '--fig-width', '7.1',
                        '--fig-height', str(round(max(4.5, 1.4 + 0.75 * sample_count), 1)),
                        '--color', ','.join(colors)], env=environment, check=True)
        plots = Path(temporary) / 'Sashimi_plot'
        # 软件可能部分绘图失败却返回成功，逐个事件核对非空 PDF 后才替换旧图。
        pdf_count = sum(path.is_file() and path.stat().st_size > 0 for path in plots.glob('*.pdf'))
        if pdf_count != event_count:
            raise RuntimeError(f'Sashimi 图不完整：应有 {event_count} 张，实际 {pdf_count} 张；原有图片已保留。')
        remove_output(folder / 'Sashimi_plot')
        shutil.move(str(plots), str(folder / 'Sashimi_plot'))
    for path in caches:
        remove_output(path)


if __name__ == '__main__':
    main()
