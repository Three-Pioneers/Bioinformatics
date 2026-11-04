#!/usr/bin/env python3
import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import pandas as pd


def remove_cache(path, outdir, temporary_name=None):
    # 仅删除本次输出目录中的已知缓存，拒绝符号链接和越界路径。
    if path.is_symlink() or path.resolve().parent != outdir:
        raise ValueError('拒绝清理输出目录以外的缓存：' + str(path))
    if path.name not in ('tmp', temporary_name):
        raise ValueError('拒绝清理未知目录：' + str(path))
    if path.exists():
        shutil.rmtree(path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('rmats')
    parser.add_argument('--od', required=True)
    args, _ = parser.parse_known_args()
    parameters = sys.argv[2:]
    options = pd.Series(parameters, dtype='string')
    if (options.eq('--tmp') | options.str.startswith('--tmp=')).any():
        parser.error('--tmp 由脚本自动设置，不需要传入')
    outdir = Path(args.od).resolve()
    if outdir == Path(outdir.anchor):
        parser.error('--od 不能是文件系统根目录')
    for directory in reversed([outdir, *outdir.parents]):
        if not directory.exists():
            directory.mkdir(exist_ok=True)

    # 避免旧缓存混入本次分析，所有原有分析参数保持不变。
    remove_cache(outdir / 'tmp', outdir)
    temporary = Path(tempfile.mkdtemp(prefix='.rmats_tmp.', dir=outdir))
    result = subprocess.run([sys.executable, args.rmats, *parameters,
                             '--tmp', str(temporary)])
    if result.returncode:
        print('rMATS 运行失败，保留临时目录：' + str(temporary), file=sys.stderr)
        return result.returncode if result.returncode > 0 else 1

    # 仅成功后清理本次缓存；失败时保留文件供检查。
    remove_cache(temporary, outdir, temporary.name)
    remove_cache(outdir / 'tmp', outdir)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
