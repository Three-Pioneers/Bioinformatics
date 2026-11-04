import sys
from pathlib import Path

import pandas as pd

analysis = Path(sys.argv[1]).resolve()
result = analysis/'result'
run_rmats, run_variants, run_wgcna = (value == 'true' for value in sys.argv[2:5])


def link(source, target):
    """相对软链接随整个项目移动；不覆盖已经存在的实体文件/目录。"""
    if not source.exists():
        return
    target.parent.mkdir(exist_ok=True)
    if target.is_symlink():
        target.unlink()
    if not target.exists():
        depth = len(target.parent.relative_to(analysis).parts)
        relative_source = Path(*(['..'] * depth)) / source.relative_to(analysis)
        target.symlink_to(relative_source, target_is_directory=source.is_dir())
    else:
        raise FileExistsError('不覆盖实体交付文件，请先检查：' + str(target))


# 按固定步骤编号整理交付目录；关闭的可选步骤移除对应链接。
result.mkdir(exist_ok=True)
deliveries = pd.DataFrame([
    ('1.QC', True), ('3.GenesExpress', True), ('4.DiffGenes', True),
    ('5.Function_anno', True), ('6.GO_KEGG_Enrichment', True), ('7.GSEA', True),
    ('report', True), ('8.rMATS', run_rmats),
    ('9.Variance_Calling', run_variants), ('10.WGCNA', run_wgcna),
], columns=['directory', 'enabled'])
for item in deliveries.itertuples(index=False):
    target = result / item.directory
    if item.enabled:
        link(analysis / item.directory, target)
    elif target.is_symlink():
        target.unlink()
# 按固定样本表和文件名交付原始 BAM，不扫描其他目录。
samples = pd.read_table(analysis/'config/sample_info.txt', dtype=str)
for sample in samples['sample_id']:
    bam = analysis/'2.Mapping'/sample/'hisat2_sorted.bam'
    link(bam, result/'2.Mapping'/(sample+'.bam'))
    link(Path(str(bam)+'.bai'), result/'2.Mapping'/(sample+'.bam.bai'))
link(analysis/'2.Mapping/mapping_stats.txt', result/'2.Mapping/mapping_stats.txt')
