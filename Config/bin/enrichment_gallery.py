#!/usr/bin/env python3
"""生成 GO/KEGG 单张图展示页；每类图仅使用一张 PNG。"""
import argparse
from html import escape
from pathlib import Path
from urllib.parse import quote

STEMS = ('GO_barplot', 'GO_dotplot', 'KEGG_barplot', 'KEGG_dotplot')
CAPTIONS = {
    'GO_barplot': 'BP、CC、MF 每类最多展示前 15 项，合并在一张图中。',
    'GO_dotplot': 'BP、CC、MF 每类最多展示前 15 项。',
    'KEGG_barplot': 'KEGG 最多展示排名前 20 项。',
    'KEGG_dotplot': 'KEGG 最多展示排名前 20 项。',
}
STYLE = '''
* { box-sizing: border-box; }
body { margin: 0; color: #263238; background: white; font-family: sans-serif; }
main { width: 100%; padding: 28px 24px; }
header { text-align: center; margin: 0 auto 24px; }
h1 { margin: 0 0 8px; font-size: 26px; }
p { line-height: 1.6; color: #56616b; } a { color: #2167a8; }
.plot-section { margin: 32px auto; text-align: center; }
.plot-section h2 { font-size: 22px; }
figure { margin: 16px auto; max-width: 1100px; }
figure img { display: block; width: 100%; height: auto; }
figcaption { margin: 12px 0; line-height: 1.6; }
'''


def document(title, body):
    return f'''<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{escape(title)}</title><style>{STYLE}</style>
</head><body><main>{body}</main></body></html>\n'''


def figure(folder, stem):
    title = stem.replace('_', ' ')
    image = quote(stem + '.png')
    pdf = stem + '.pdf'
    download = f' · <a href="{quote(pdf)}" target="_blank" rel="noopener">PDF</a>' if (folder/pdf).is_file() else ''
    return (f'<figure><a href="{image}" target="_blank" rel="noopener">'
            f'<img src="{image}" alt="{escape(title)}" decoding="async"></a>'
            f'<figcaption>{escape(CAPTIONS[stem])}{download}</figcaption></figure>')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path, help='单个比较的 GO/KEGG 富集结果目录')
    folder = parser.parse_args().directory.resolve()
    sections = []
    for stem in STEMS:
        target = folder/(stem + '_gallery.html')
        if not (folder/(stem + '.png')).is_file():
            target.unlink(missing_ok=True)
            continue
        title = stem.replace('_', ' ')
        content = figure(folder, stem)
        target.write_text(document(title,
            f'<header><h1>{escape(title)}</h1><p>{escape(folder.name)}</p>'
            '<a href="enrichment_gallery.html">图表总览</a></header>' + content), encoding='utf-8')
        sections.append(f'<section class="plot-section"><h2>{escape(title)}</h2>{content}</section>')
    if not sections:
        parser.error(f'没有找到 GO/KEGG barplot 或 dotplot 图片：{folder}')
    output = folder/'enrichment_gallery.html'
    output.write_text(document('GO / KEGG 富集图',
        f'<header><h1>GO / KEGG 富集图</h1><p>{escape(folder.name)}</p></header>'
        + ''.join(sections)), encoding='utf-8')
    print(output)


if __name__ == '__main__':
    main()
