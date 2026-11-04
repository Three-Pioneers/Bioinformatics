import configparser
import pandas as pd
import shutil
import subprocess
import sys
from pathlib import Path

analysis,bindir = map(Path,sys.argv[1:3])
converter = sys.argv[3]
annotation_source = Path(sys.argv[4])
report = analysis/'report'
src = report/'src'
metadata=analysis/'config'
config = configparser.ConfigParser(interpolation=None)
config.read(metadata/'Transcriptome.used.conf',encoding='utf-8-sig')
comparisons = [value.strip() for value in config.get('SampleInfo','DiffPeak_vs').split(',')]
# 各分析步骤按脚本内部默认启用，配置文件不再提供 Parameters 区块。
rmats = variants = wgcna = True
report.mkdir(exist_ok=True)
src.mkdir(exist_ok=True)
for name in ('table','image','libs','comparisons','wgcna','qc'):
    (src/name).mkdir(exist_ok=True)
(metadata/'comparisons.txt').write_text('\n'.join(comparisons)+'\n',encoding='utf-8')
parameters = pd.DataFrame([('PE', config.get('Data', 'PE'))], columns=['parameter', 'value'])
parameters.to_csv(metadata/'parameters.tsv', sep='\t', index=False, encoding='utf-8', lineterminator='\n')

# 未运行/无文件时清掉同名旧材料，避免把旧图误作本次结果。
def copy(source,destination):
    destination.parent.mkdir(parents=True,exist_ok=True)
    if source is not None and source.is_file():
        shutil.copy2(source,destination)
    elif destination.is_file():
        destination.unlink()


def copy_plot(folder,stem,destination):
    for suffix in ('.png','.pdf'):
        copy(folder/(stem+suffix) if folder else None,destination/(stem+suffix))
    copy(None,destination/(stem+'_pages.txt'))
    for old in destination.glob(stem+'_page*.png'):
        old.unlink()
    if folder:
        for page in folder.glob(stem+'_page*.png'):
            copy(page,destination/page.name)


copy(metadata/'sample_info.txt',src/'table/sample_info.txt')
# MultiQC是正式质控报告，仅复制自包含HTML，不带入运行缓存。
copy(analysis/'1.QC/stats/multiqc_report.html',src/'qc/multiqc_report.html')
for source,target in [('1.QC/stats/qc_stats.txt','qc_stats.txt'),
                       ('4.DiffGenes/diffExprGene_stats.txt','diffExprGene_stats.txt'),
                       ('3.GenesExpress/1.Gene_id/assignment_stats.txt','assignment_stats.txt')]:
    copy(analysis/source,src/'table'/target)
# 清理旧版 HISAT2 汇总表副本。
copy(None,src/'table/mapping_stats.txt')
copy(annotation_source,src/'table/annotation_stats.txt')
expression=analysis/'3.GenesExpress/1.Gene_id'
# 双端按片段数使用FPKM，单端按读段数使用RPKM，报告只保留当前模式。
expression_unit='FPKM' if config.getboolean('Data','PE') else 'RPKM'
copy(None,src/'table'/('RPKM.txt' if expression_unit=='FPKM' else 'FPKM.txt'))
for matrix in ('COUNT',expression_unit,'TPM'):
    copy(expression/(matrix+'.txt'),src/'table'/(matrix+'.txt'))
for name in ('COUNT_PCA','COUNT_cor','TPM_violin'):
    copy_plot(expression,name,src/'image')
copy(expression/'COUNT_PCA_scores.txt',src/'table/COUNT_PCA_scores.txt')
copy_plot(analysis/'4.DiffGenes','diffExprGene_stats',src/'image')
copy_plot(analysis/'4.DiffGenes' if len(comparisons)>1 else None,'venn',src/'image')
copy(analysis/'4.DiffGenes/venn_membership.txt' if len(comparisons)>1 else None,src/'table/venn_membership.txt')
for name in ('header.html','report.css','report.js','plot_carousel.css','plot_carousel.js'):
    copy(bindir/'src/libs'/name,src/'libs'/name)

# 每个比较独立存放完整表、摘要表和图；下载提供原始精度数据。
for name in comparisons:
    target=src/'comparisons'/name
    target.mkdir(exist_ok=True)
    diff=analysis/'4.DiffGenes'/name
    for filename in ('All_genes_exprData.txt','Sig_genes_exprData.txt','analysis_parameters.tsv'):
        copy(diff/filename,target/filename)
    for stem in ('volcano','heatmap'):
        copy_plot(diff,stem,target)
    enrichment=analysis/'6.GO_KEGG_Enrichment'/name
    copy(enrichment/'enrichment_parameters.tsv',target/'enrichment_parameters.tsv')
    # 各类图使用独立展示页；与原 PNG/PDF 放在同目录，保留相对链接。
    copy(enrichment/'enrichment_gallery.html',target/'enrichment_gallery.html')
    gsea=analysis/'7.GSEA'/name
    copy(gsea/'GSEA_parameters.tsv',target/'GSEA_parameters.tsv')
    for label in ('GO','KEGG'):
        for prefix in ('All','Sig'):
            filename=prefix+'_'+label+'_Enrichment.txt'
            copy(enrichment/filename,target/filename)
        for stem in (label+'_barplot',label+'_dotplot'):
            copy_plot(enrichment,stem,target)
            copy(enrichment/(stem+'_gallery.html'),target/(stem+'_gallery.html'))
        copy_plot(gsea,label+'_GSEA_top10',target)
        copy(gsea/(label+'_GSEA_all.txt'),target/(label+'_GSEA_all.txt'))
        # 原生单通路曲线全部保留，在报告的通路下拉框内查看。
        curve_target=target/label
        curve_target.mkdir(exist_ok=True)
        current={path.name for path in (gsea/label).glob('*') if path.suffix in ('.png','.pdf')}
        for old in curve_target.iterdir():
            if old.is_file() and old.name not in current: old.unlink()
        for filename in current: copy(gsea/label/filename,curve_target/filename)
    copy_plot(enrichment,'GO_circlize',target)
    pathways=sorted((enrichment/'Pathway').glob('*pathway.png'))
    copy(pathways[0] if pathways else None,target/'pathway.png')
    copy(enrichment/'Pathway/pathview_skipped.txt',target/'pathview_skipped.txt')
    splicing=analysis/'8.rMATS'/name
    for filename in ('SE.MATS.JC.txt','SE.significant.txt','splicing_summary.txt'):
        copy(splicing/filename if rmats else None,target/filename)
    sashimi=sorted((splicing/'Sashimi_plot').glob('*.pdf')) if rmats else []
    copy(sashimi[0] if sashimi else None,target/'sashimi.pdf')
    if sashimi:
        subprocess.run([converter,'-png','-singlefile','-r','600',str(target/'sashimi.pdf'),str(target/'sashimi')],check=True)
    else:
        copy(None,target/'sashimi.png')

# WGCNA 的大型RDS留在分析目录；报告提供关键图、模块/关联表下载。
status_path=analysis/'10.WGCNA/WGCNA_status.txt'
status=status_path.read_text() if wgcna and status_path.is_file() else ''
completed=status.startswith('COMPLETED')
associations_ready=completed and 'all genes are grey' not in status
for filename in ('WGCNA_status.txt','analysis_mode.txt','power_selection.txt','gene_modules.txt','module_membership.txt',
                 'module_trait_association.txt','candidate_hub_genes.txt','leave_one_out_association.txt'):
    enabled=wgcna if filename=='WGCNA_status.txt' else completed
    if filename in ('module_membership.txt','module_trait_association.txt','candidate_hub_genes.txt','leave_one_out_association.txt'):
        enabled=associations_ready
    copy(analysis/'10.WGCNA'/filename if enabled else None,src/'wgcna'/filename)
copy(None,src/'wgcna/sessionInfo.txt')
for stem in ('sample_clustering','soft_threshold','gene_dendrogram_modules','module_trait_heatmap','leave_one_out_association'):
    enabled=associations_ready if stem in ('module_trait_heatmap','leave_one_out_association') else completed
    copy_plot(analysis/'10.WGCNA' if enabled else None,stem,src/'wgcna')
copy(analysis/'9.Variance_Calling/variant_summary.txt' if variants else None,src/'table/variant_summary.txt')
for label in ('snps','indels'):
    folder='snp' if label=='snps' else 'indel'
    filename='all_sample_'+label+'_stats.txt'
    copy(analysis/'9.Variance_Calling'/folder/filename if variants else None,src/'table'/filename)
