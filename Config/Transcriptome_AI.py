import configparser
import argparse
import os
import re
import shlex
import shutil

parser = argparse.ArgumentParser(description='按固定格式生成 RNA-seq 分步脚本，不自动运行分析')
parser.add_argument("-c", "--conf", default="Transcriptome.conf", help="配置文件；相对路径以该文件所在目录为准")
args = parser.parse_args()
conf=args.conf

Config = configparser.ConfigParser(interpolation=None)
if not Config.read(conf, encoding="utf-8-sig"):
    parser.error("找不到配置文件：" + conf)
project_dir = os.path.dirname(os.path.abspath(conf))

# 输入路径相对于配置文件；bin 固定使用当前程序旁的文件夹。
def project_path(value):
    if value.lower() == 'none':
        return value
    return os.path.abspath(os.path.join(project_dir, os.path.expanduser(value)))

def software(name, default=None):
    value = Config.get('software', name, fallback=default)
    if not value:
        parser.error('[software] 缺少 ' + name)
    return project_path(value) if '/' in value else (shutil.which(value) or value)

# 所有分步脚本统一开启严格错误处理，管道任一端失败即停止。
def open_shell(path):
    handle = open(path, 'w', encoding='utf-8', newline='\n')
    handle.write('#!/usr/bin/env bash\nset -euo pipefail\n\n')
    return handle


def write_rush(shell, commands):
    # 仅用于 fastp、HISAT2、samtools 和 GATK；每行是一个独立样本任务。
    if not commands:
        return
    if any('\n' in command or command == 'RUSH_COMMANDS' for command in commands):
        raise ValueError('rush 每个样本任务必须为单行命令')
    shell.write("rush -j %d -e -k '{}' <<'RUSH_COMMANDS' || exit $?\n" % min(parallel_jobs, len(commands)))
    shell.write('\n'.join(commands) + '\nRUSH_COMMANDS\n\n')


datadir = project_path(Config.get('Data', 'DataDir'))
outdir = project_path(Config.get('Data', 'OutDir'))
rename = Config.get('Data', 'Rename')
renamefile = Config.get('Data', 'Renamefile', fallback='')

pe = Config.get('Data', 'PE')

version = Config.get('DB', 'version')
Genome_fa = project_path(Config.get('DB', 'Genome_fa'))
Genome_gft = project_path(Config.get('DB', 'Genome_gft'))  # 保留原配置键名，实际为 GTF。
Genome_annotation = project_path(Config.get('DB', 'Genome_annotation'))
Gene_id_name = project_path(Config.get('DB', 'Gene_id_name'))
gene_type = Config.get('DB', 'gene_type')
Species = Config.get('DB', 'Species')
vcf_known_sites = Config.get('DB', 'vcf_known_sites', fallback='none')


Group = Config.get('SampleInfo', 'Group')
DiffPeak_vs = Config.get('SampleInfo', 'DiffPeak_vs')


contract_Num = Config.get('ReportInfo', 'Contract_Num')
project_Name = Config.get('ReportInfo', 'Project_Name')
report_Time = Config.get('ReportInfo', 'Report_Time')
company_name = Config.get('ReportInfo', 'company_name')

Rscript = software('Rscript')
Python3 = software('Python3')
Fastp = software('Fastp')
rmats = software('rmats', 'rmats.py')
rmats2sashimiplot = software('rmats2sashimiplot', 'rmats2sashimiplot')
samtools = software('samtools')
featureCounts = software('featureCounts')
hisat2 = software('hisat2')
Multiqc = software('Multiqc', 'multiqc')
Gatk = software('Gatk', 'gatk')
Gfold = software('Gfold', 'gfold')
Pdftoppm = software('Pdftoppm', 'pdftoppm')
bin = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'bin')

# 运行设置在脚本内集中维护；40 个总线程按两个并行样本平分。
threads = 40
parallel_jobs = 2
job_threads = max(1, threads // parallel_jobs)
strand = 0  # 非链特异；比对、计数和剪接使用同一方向。
read_length = 150
run_wgcna = True
wgcna_power = 0
wgcna_max_genes = 5000
wgcna_traits = 'none'
run_rmats = True
run_variants = True
ploidy = 2
if gene_type not in ('SYMBOL', 'KEGG') or not re.fullmatch(r'[A-Za-z0-9]+', Species):
    parser.error('gene_type 使用 SYMBOL/KEGG；Species 填 KEGG 物种缩写或 ko')
analysis_dir=os.path.join(outdir, 'analysis')
work_sh=analysis_dir+'/work_sh/'
# 样本表和配置资料单独存放，work_sh只放可执行的sh脚本。
metadata_dir=analysis_dir+'/config'
sample_info_path=metadata_dir+'/sample_info.txt'
os.makedirs(metadata_dir,exist_ok=True)
qc_dir=analysis_dir+'/1.QC/'
raw_dir=analysis_dir+'/1.QC'+'/raw/'
fastp_dir=analysis_dir+'/1.QC'+'/fastp/'
clean_dir=analysis_dir+'/1.QC'+'/clean/'
qc_stats_dir=analysis_dir+'/1.QC'+'/stats/'
mapping_dir=analysis_dir+'/2.Mapping'
genesexpress_dir=analysis_dir+'/3.GenesExpress'
featureCounts_dir=analysis_dir+'/3.GenesExpress'+'/0.featureCounts'
Gene_id_dir=analysis_dir+'/3.GenesExpress'+'/1.Gene_id'
DiffGenes_dir=analysis_dir+'/4.DiffGenes'
Function_anno_dir=analysis_dir+'/5.Function_anno'
GO_KEGG_Enrichment_dir=analysis_dir+'/6.GO_KEGG_Enrichment'
GSEA_dir=analysis_dir+'/7.GSEA'
rMATS_dir=analysis_dir+'/8.rMATS'
Variance_Calling_dir=analysis_dir+'/9.Variance_Calling'


# 各步骤使用固定目录；只创建必要目录，不迁移或识别旧版结果。
for folder in (metadata_dir, work_sh, Variance_Calling_dir, rMATS_dir,
               Function_anno_dir, GSEA_dir, GO_KEGG_Enrichment_dir, DiffGenes_dir,
               featureCounts_dir, Gene_id_dir, raw_dir, fastp_dir, clean_dir,
               qc_stats_dir, mapping_dir):
    os.makedirs(folder, exist_ok=True)

# 输入固定为 <原样本名>_R1.fq.gz / _R2.fq.gz，样本及分组由配置直接给出。
group_dict = {name.strip(): samples.split()
              for name, samples in (item.split('=', 1) for item in Group.split(','))}
sample_id = sorted(sample for samples in group_dict.values() for sample in samples)
DiffPeak_vs = ','.join(item.strip() for item in DiffPeak_vs.split(','))
dict_rename = dict(item.split() for item in renamefile.split(',')) if rename.lower() == 'true' else {}
reverse_names = {new: old for old, new in dict_rename.items()}
with open_shell(work_sh + '/Step_0_rename.sh') as shell:
    shell.write('# 0. 按固定 FASTQ 文件名建立样本链接，不复制原始数据。\n')
    for name in sample_id:
        original = reverse_names.get(name, name)
        for mate in ('1', '2') if pe.lower() == 'true' else ('1',):
            source = os.path.join(datadir, original + '_R' + mate + '.fq.gz')
            target = raw_dir + name + '_R' + mate + '.fq.gz'
            source = os.path.relpath(source, os.path.dirname(target))
            shell.write('ln -sfn %s %s\n' % (shlex.quote(source), shlex.quote(target)))

# 生成阶段准备样本表，表达分析不再依赖先运行报告步骤。
with open(sample_info_path, 'w', encoding='utf-8', newline='\n') as handle:
    handle.write('sample_id\tgroup\tbyzh_id\n')
    reverse_names = {new: old for old, new in dict_rename.items()}
    for sample in sample_id:
        group = next(group for group, samples in group_dict.items() if sample in samples)
        handle.write('%s\t%s\t%s\n' % (sample, group, reverse_names.get(sample, sample)))


if Gene_id_name.lower() !='none':
    all_go_anno=Genome_annotation+'/2.GO/GO_function_id_name_all.txt'
    all_kegg_anno=Genome_annotation+'/3.KEGG/Enrichment_KEGG_id_name_all.txt'
else:
    all_go_anno=Genome_annotation+'/2.GO/GO_function_id.txt'
    all_kegg_anno=Genome_annotation+'/3.KEGG/Enrichment_KEGG_id.txt'


# 综合注释与 GO/KEGG 路径按既定参考资料目录使用。
stats_name = 'stats_id_name_all.txt' if Gene_id_name.lower() != 'none' else 'stats_id.txt'
function_stats = os.path.join(Genome_annotation, '12.stats', stats_name)

def Qc():
    # 1. 过滤测序数据中的接头和低质量序列，检查各样本数据质量。
    with open_shell(work_sh+'/Step_1_qc.sh') as shell:
        shell.write('# 1. 数据质控：使用 fastp 去除接头和低质量序列，输出 clean FASTQ。\n')
        shell.write('# 汇总各样本的数据量和质量指标，并生成 MultiQC 报告及 MD5 校验值。\n\n')
        commands = []
        fastp_threads = min(job_threads,16)
        thread_option = f' --thread {fastp_threads}' if fastp_threads!=3 else ''
        for name in sample_id:
            inputs = f'--in1 {raw_dir}{name}_R1.fq.gz --out1 {clean_dir}{name}_R1.fq.gz'
            if pe.lower() == 'true':
                inputs += f' --in2 {raw_dir}{name}_R2.fq.gz --out2 {clean_dir}{name}_R2.fq.gz --detect_adapter_for_pe'
            commands.append(f'{shlex.quote(Fastp)} {inputs} --json {fastp_dir}{name}_fastp.json --html {fastp_dir}{name}_fastp.html{thread_option}')
        write_rush(shell, commands)
        # 按目录匹配全部 .gz 文件，不切换当前工作目录。
        for folder, filename in [(raw_dir,'rawdata_md5.txt'),(clean_dir,'cleandata_md5.txt')]:
            shell.write(f'md5sum -- {shlex.quote(folder.rstrip("/"))}/*.gz > {shlex.quote(os.path.join(folder,filename))}\n')
        shell.write(f'{shlex.quote(Multiqc)} --force --outdir {qc_stats_dir} {fastp_dir}\n')
        shell.write(f'{shlex.quote(Python3)} {bin}/fastp_stats.py --input_fastp_dir {fastp_dir} --stats_out_dir {qc_stats_dir}\n')


def Mapping():
    # 2. 将质控后的序列定位到参考基因组，为表达、剪接和变异分析准备比对结果。
    with open_shell(work_sh+'/Step_2_mapping.sh') as shell:
        shell.write('# 2. 参考基因组比对：使用 HISAT2 定位 clean reads，samtools 整理比对结果。\n')
        shell.write('# 输出排序后的 BAM、BAM 索引和各样本的比对率汇总。\n\n')
        index = os.path.join(os.path.dirname(Genome_fa), 'index_hisat2', 'index')
        rna_strand = {0:'',1:'FR' if pe.lower()=='true' else 'F',2:'RF' if pe.lower()=='true' else 'R'}[strand]
        strand_option = f' --rna-strandness {rna_strand}' if rna_strand else ''
        commands = []
        # HISAT2 与排序同时运行，共用每个样本的线程预算。
        sort_threads = min(4, max(0, (job_threads - 2) // 3))
        align_threads = max(1, job_threads - sort_threads - 1)
        align_threads_option = f' -p {align_threads}' if align_threads != 1 else ''
        sort_threads_option = f' -@ {sort_threads}' if sort_threads else ''
        for name in sample_id:
            folder = mapping_dir + '/' + name
            os.makedirs(folder, exist_ok=True)
            bam = shlex.quote(folder + '/hisat2_sorted.bam')
            reads = (f'-1 {shlex.quote(clean_dir + name + "_R1.fq.gz")} '
                     f'-2 {shlex.quote(clean_dir + name + "_R2.fq.gz")}') if pe.lower() == 'true' else f'-U {shlex.quote(clean_dir + name + "_R1.fq.gz")}'
            pipeline = (f'{shlex.quote(hisat2)}{strand_option}{align_threads_option} '
                        f'-x {shlex.quote(index)} {reads} --new-summary '
                        f'--summary-file {shlex.quote(folder + "/summary.txt")} '
                        f'| {shlex.quote(samtools)} sort{sort_threads_option} '
                        f'-T {shlex.quote(folder + "/sort_tmp")} -o {bam} - '
                        f'&& {shlex.quote(samtools)} quickcheck -v {bam} '
                        f'&& {shlex.quote(samtools)} index{sort_threads_option} {bam}')
            # rush 的每条命令在独立 Bash 中开启 pipefail，避免只看到 sort 的退出码。
            commands.append('bash -euo pipefail -c ' + shlex.quote(pipeline))
        shell.write('# HISAT2 标准输出直接送入 samtools sort，随后检查 BAM 并建立索引。\n')
        write_rush(shell, commands)
        shell.write(f'{shlex.quote(Python3)} {shlex.quote(bin+"/mapping_stats.py")} {shlex.quote(mapping_dir)} {shlex.quote(mapping_dir)} || exit $?\n')


def GenesExpress():
    # 3. 统计各基因的表达量，并检查样本间的整体表达关系。
    with open_shell(work_sh+'/Step_3_GenesExpress.sh') as shell:
        shell.write('# 3. 基因表达定量：使用 featureCounts 统计每个样本分配到基因的 reads 或片段数。\n')
        shell.write('# 保留唯一比对且能明确分配的计数；双端数据按片段计数。\n\n')
        bams = ' '.join(mapping_dir+'/'+name+'/hisat2_sorted.bam' for name in sample_id)
        paired = '-p --countReadPairs' if pe.lower()=='true' else ''
        normalized = 'FPKM' if pe.lower()=='true' else 'RPKM'
        # 非链特异是默认值；其他建库方向才写入参数。
        strand_option = f' -s {strand}' if strand else ''
        threads_option = f' -T {threads}' if threads!=1 else ''
        shell.write(f'{shlex.quote(featureCounts)} -a {Genome_gft} -o {featureCounts_dir}/featureCounts.txt '
                    f'{threads_option}{strand_option} {paired} {bams}\n')
        shell.write(f'# 整理 COUNT、{normalized} 和 TPM 表达矩阵，汇总基因长度和计数分配率。\n')
        shell.write(f'{shlex.quote(Python3)} {bin}/gene_result_stas.py {featureCounts_dir}/featureCounts.txt {Gene_id_dir} {pe.lower()}\n')
        # 完整原始 ID 矩阵保留 PCA；各表达目录分别输出相关性和分布图。
        shell.write(f'{shlex.quote(Rscript)} {bin}/PCA.R {Gene_id_dir}/COUNT.txt {sample_info_path} {Gene_id_dir}\n')
        expression_folders = [Gene_id_dir]
        if Gene_id_name.lower() != 'none':
            # 最初版本目录：有名称的子集与完整名称矩阵都使用 id(name)。
            part_folder = genesexpress_dir + '/2.Gene_name_part'
            name_folder = genesexpress_dir + '/3.Gene_name_all'
            for folder in (part_folder, name_folder):
                os.makedirs(folder, exist_ok=True)
            shell.write('# 沿用旧版：part 只保留名称表可匹配的基因，all 保留全部基因。\n')
            shell.write(f'{shlex.quote(Python3)} {bin}/gene_name_result_stats_part.py '
                        f'{Gene_id_name} {Gene_id_dir} {part_folder} {pe.lower()}\n')
            shell.write(f'{shlex.quote(Python3)} {bin}/gene_name_result_stats_all.py '
                        f'{Gene_id_name} {Gene_id_dir} {name_folder} {pe.lower()}\n')
            expression_folders += [part_folder, name_folder]
        for folder in expression_folders:
            shell.write('# COUNT、标准化表达量和 TPM 分别绘制小提琴图及样本相关性图。\n')
            for label in ('COUNT', normalized, 'TPM'):
                shell.write(f'{shlex.quote(Rscript)} {bin}/violin.R {folder}/{label}.txt {sample_info_path} {folder}\n')
                shell.write(f'{shlex.quote(Rscript)} {bin}/cor.R {folder}/{label}.txt {folder}\n')


def DiffGenes():
    # 4. 按配置的比较方向筛选表达升高或降低的基因。
    DiffGenes_shell=work_sh+"/Step_4_DiffGenes.sh"
    shell=open_shell(DiffGenes_shell)
    shell.write('# 4. 差异表达分析：比较处理组与对照组，筛选表达上调和下调的候选基因。\n')
    shell.write('# 输出完整检验结果、差异基因表，以及表达变化和聚类图。\n')
    for vs in DiffPeak_vs.strip().split(','):
        shell.write('\n# 按配置指定的比较组进行分析。\n')
        vs_dir=DiffGenes_dir+'/'+vs
        if not os.path.exists(vs_dir):
            os.makedirs(vs_dir)
        treat=vs.strip().split('_vs_')[0]
        control=vs.strip().split('_vs_')[1]
        sample_sum=len(group_dict[treat])+len(group_dict[control])

        gene_order_py=bin+'/gene_order.py'
        diffExprGene_R=bin+'/diffExprGene.R'
        gfold_diffExprGene_py=bin+'/gfold_diffExprGene.py'
        volcano_R=bin+'/volcano.R'
        MA_R=bin+'/MA.R'
        gfold_trans_py=bin+'/gfold_trans.py'
        if sample_sum !=2:
            shell.write('# 使用 DESeq2 分析有生物学重复的比较，按校正后 P 值及表达变化幅度筛选。\n')
            if Gene_id_name.lower() !='none':
                cmd1=f'{shlex.quote(Python3)} %s %s/3.Gene_name_all/COUNT.txt  %s/config/sample_info.txt %s %s'%(gene_order_py,genesexpress_dir,analysis_dir,vs,vs_dir)
            else:
                cmd1=f'{shlex.quote(Python3)} %s %s/1.Gene_id/COUNT.txt  %s/config/sample_info.txt %s %s'%(gene_order_py,genesexpress_dir,analysis_dir,vs,vs_dir)
            cmd2='%s %s %s/COUNT.txt %s/sample_info.txt %s'%(shlex.quote(Rscript),diffExprGene_R,vs_dir,vs_dir,vs_dir)
            shell.write(cmd1+'\n'+cmd2+'\n')
            cmd4='%s %s %s/All_genes_exprData.txt %s' %(shlex.quote(Rscript),volcano_R,vs_dir,vs_dir)
        else:
            shell.write('# 两组各一个样本时使用 GFOLD，结果作为探索性候选，不提供重复样本的统计检验。\n')
            if Gene_id_name.lower() !='none':
                cmd1=f'{shlex.quote(Python3)} %s %s/3.Gene_name_all/COUNT.txt  %s/config/sample_info.txt %s %s  %s'%(gfold_diffExprGene_py,genesexpress_dir,analysis_dir,group_dict[treat][0],group_dict[control][0],vs_dir)
                # GFOLD 的方向为 s2/s1，与 Treat_vs_Control 保持一致。
                cmd2=f'{shlex.quote(Gfold)} diff -s1 %s/control -s2 %s/treat -suf .txt -o %s/gfold.diff'%(vs_dir,vs_dir,vs_dir)
            else:
                cmd1=f'{shlex.quote(Python3)} %s %s/1.Gene_id/COUNT.txt %s/config/sample_info.txt  %s %s %s'%(gfold_diffExprGene_py,genesexpress_dir,analysis_dir,group_dict[treat][0],group_dict[control][0],vs_dir)
                # GFOLD 的方向为 s2/s1，与 Treat_vs_Control 保持一致。
                cmd2=f'{shlex.quote(Gfold)} diff -s1 %s/control -s2 %s/treat -suf .txt -o %s/gfold.diff'%(vs_dir,vs_dir,vs_dir)
            cmd3=f'{shlex.quote(Python3)} %s %s/gfold.diff %s/COUNT.txt %s'%(gfold_trans_py,vs_dir,vs_dir,vs_dir)
            # GFOLD 使用第3步输出的真实基因长度，不再填常数1。
            cmd1 += f' {Gene_id_dir}/gene_lengths.txt'
            shell.write(cmd1+'\n'+cmd2+'\n'+cmd3+'\n')
            cmd4='%s %s %s/All_genes_exprData.txt %s' %(shlex.quote(Rscript),MA_R,vs_dir,vs_dir)
        shell.write(cmd4+'\n'+'\n')

        heatmap_R=bin+'/heatmap.R'
        # 依列名选择热图基因，支持空结果和不同差异分析方法。
        cmd4=f'{shlex.quote(Python3)} {bin}/heatmap_input.py {vs_dir}'
        cmd8='%s %s %s/heatmap_input.txt %s/sample_info.txt %s'%(shlex.quote(Rscript),heatmap_R,vs_dir,vs_dir,vs_dir)
        shell.write(cmd4+'\n'+cmd8+'\n\n')
    # 多个比较时，汇总差异基因的共同与特有部分。
    veen_input_py=bin+'/venn_input.py'
    veen_R=bin+'/venn.R'

    Sig_genes_exprData_str=''
    if len(DiffPeak_vs.strip().split(',')) > 1:
        for vs in DiffPeak_vs.strip().split(','):
            shell.write('\n# 按配置指定的比较组进行分析。\n')
            Sig_genes_exprData=DiffGenes_dir+'/'+vs+'/Sig_genes_exprData.txt'
            Sig_genes_exprData_str+=Sig_genes_exprData+','

        cmd10=f'{shlex.quote(Python3)} %s %s %s'%(veen_input_py,Sig_genes_exprData_str.strip(','),DiffGenes_dir)
        cmd11=f'{shlex.quote(Rscript)} %s %s/venn_input.txt %s {DiffPeak_vs}'%(veen_R,DiffGenes_dir,DiffGenes_dir)
        shell.write(cmd10+'\n'+cmd11+'\n')

    # 汇总各比较的上调、下调及差异基因总数。
    diffExprGene_stats_py=bin+'/diffExprGene_stats.py'
    diffExprGene_stats_R=bin+'/diffExprGene_stats.R'
    All_genes_exprData_str=''
    for vs in DiffPeak_vs.strip().split(','):
        shell.write('\n# 按配置指定的比较组进行分析。\n')
        All_genes_exprData=DiffGenes_dir+'/'+vs+'/All_genes_exprData.txt'
        All_genes_exprData_str+=All_genes_exprData+','
    cmd12=f'{shlex.quote(Python3)} %s %s %s '%(diffExprGene_stats_py,All_genes_exprData_str.strip(','),DiffGenes_dir)
    cmd13=f'{shlex.quote(Rscript)} %s %s/diffExprGene_stats_input.txt %s'%(diffExprGene_stats_R,DiffGenes_dir,DiffGenes_dir)
    shell.write(cmd12+'\n'+cmd13+'\n')
    shell.close()

def Function_anno():
    # 5. 将表达结果与预先准备的功能注释关联，方便解释候选基因。
    Function_anno_shell=work_sh+"Step_5_Function_anno.sh"
    shell=open_shell(Function_anno_shell)
    shell.write('# 5. 基因功能注释：将本物种的注释信息补充到完整结果和差异基因表中。\n')
    shell.write('# 输出带功能描述的结果表，便于查阅基因功能及后续生物学解释。\n\n')
    # 固定文件模式的复制由 Python 完成，步骤脚本只保留执行命令。
    command = [Python3, os.path.join(bin, 'prepare_annotation.py'),
               Genome_annotation, Function_anno_dir, str(Gene_id_name.lower() != 'none').lower()]
    shell.write(' '.join(shlex.quote(value) for value in command) + '\n')
    merge_py=bin+'/merge.py'
    for vs in DiffPeak_vs.strip().split(','):
        shell.write('\n# 按配置指定的比较组进行分析。\n')
        vs_dir=DiffGenes_dir+'/'+vs
        Sig_genes_exprData=vs_dir+'/Sig_genes_exprData.txt'
        All_genes_exprData=vs_dir+'/All_genes_exprData.txt'
        Sig_genes_exprData_merge=vs_dir+'/Sig_genes_exprData_merge.txt'
        All_genes_exprData_merge=vs_dir+'/All_genes_exprData_merge.txt'
        COUNT=vs_dir+'/COUNT.txt'
        stats_function = function_stats
        cmd2=f'{shlex.quote(Python3)} %s %s %s %s %s'%(merge_py,Sig_genes_exprData,Sig_genes_exprData_merge,COUNT,stats_function)
        cmd3=f'{shlex.quote(Python3)} %s %s %s %s %s'%(merge_py,All_genes_exprData,All_genes_exprData_merge,COUNT,stats_function)
        shell.write(cmd2+'\n'+cmd3+'\n')
    shell.close()


def GO_KEGG_Enrichment():
    # 6. 检查差异基因是否集中于特定功能或通路。
    GO_KEGG_Enrichment_shell=work_sh+"Step_6_GO_KEGG_Enrichment.sh"
    shell=open_shell(GO_KEGG_Enrichment_shell)
    shell.write('# 6. GO 和 KEGG 富集：以可检验且有注释的基因为背景，寻找差异基因集中的功能和通路。\n')
    shell.write('# 输出富集结果表、条形图和气泡图，并展示符合条件的通路及 GO 关系图。\n')
    shell.write('set -euo pipefail\n')
    GO_KEGG_Enrichment_R=bin+'/GO_KEGG_Enrichment.R'
    pathview_R=bin+'/pathview.R'
    circlize_input_py=bin+'/circlize_input.py'
    circlize_R=bin+'/circlize.R'
    for vs in DiffPeak_vs.strip().split(','):
        shell.write('\n# 按配置指定的比较组进行分析。\n')
        vs_dir=GO_KEGG_Enrichment_dir+'/'+vs
        if not os.path.exists(vs_dir):
            os.makedirs(vs_dir)
        Pathway_dir=vs_dir+'/Pathway'
        if not os.path.exists(Pathway_dir):
            os.makedirs(Pathway_dir)
        shell.write('mkdir -p '+shlex.quote(Pathway_dir)+'\n')
        Sig_genes_exprData=DiffGenes_dir+'/'+vs+'/Sig_genes_exprData.txt'
        cmd1=f'{shlex.quote(Rscript)} %s %s %s %s %s {DiffGenes_dir}/{vs}/All_genes_exprData.txt'%(GO_KEGG_Enrichment_R,Sig_genes_exprData,all_go_anno,all_kegg_anno,vs_dir)
        gallery=' '.join(shlex.quote(value) for value in [Python3, os.path.join(bin, 'enrichment_gallery.py'), vs_dir])
        cmd2=f'{shlex.quote(Rscript)} %s %s %s/Sig_KEGG_Enrichment.txt %s %s %s %s'%(pathview_R,Sig_genes_exprData,vs_dir,all_kegg_anno,gene_type,Species,Pathway_dir)
        
        
        cmd5=f'{shlex.quote(Python3)} %s  %s/Sig_GO_Enrichment.txt %s %s'%(circlize_input_py,vs_dir,Sig_genes_exprData,vs_dir)
        cmd6=f'{shlex.quote(Rscript)} %s %s/GO_circlize_input.txt %s '%(circlize_R,vs_dir,vs_dir)
        # 绘图脚本直接导出 PNG 和矢量 PDF，无需再次转换。
        
        shell.write(cmd1+'\n'+gallery+'\n'+cmd2+'\n'+cmd5+'\n'+cmd6+'\n\n')
    shell.close()


def GSEA():
    # 7. 使用全基因的表达变化排序，观察功能基因集的整体变化趋势。
    GSEA_shell=work_sh+"Step_7_GSEA.sh"
    shell=open_shell(GSEA_shell)
    shell.write('# 7. GSEA：按全基因的表达变化排序，评估 GO 和 KEGG 基因集是否集中在排序的一端。\n')
    shell.write('# 输出基因集富集结果及富集曲线，补充差异基因筛选之外的整体变化信息。\n')

    GSEA_R=bin+'/GSEA.R'
    for vs in DiffPeak_vs.strip().split(','):
        shell.write('\n# 按配置指定的比较组进行分析。\n')
        vs_dir=GSEA_dir+'/'+vs
        if not os.path.exists(vs_dir):
            os.makedirs(vs_dir)
        GO=vs_dir+'/GO'
        KEGG=vs_dir+'/KEGG'
        if not os.path.exists(GO):
            os.makedirs(GO)
        if not os.path.exists(KEGG):
            os.makedirs(KEGG)
        All_genes_exprData=DiffGenes_dir+'/'+vs+'/All_genes_exprData.txt'
        cmd1=f'{shlex.quote(Rscript)} %s %s %s %s %s'%(GSEA_R,All_genes_exprData,all_go_anno,all_kegg_anno,vs_dir)
        shell.write(cmd1+'\n'+'\n')
    shell.close()
    


def rMATS():
    # 8. 比较两组剪接事件的使用比例，发现表达总量之外的转录本变化。
    rMATS_shell=work_sh+"Step_8_rMATS.sh"
    shell=open_shell(rMATS_shell)
    shell.write('# 8. 可变剪接分析：使用 rMATS 比较两组的外显子和剪接位点使用情况。\n')
    shell.write('# 汇总五类剪接事件及显著变化，并为代表性外显子跳跃事件绘制 Sashimi 图。\n')
    for vs in DiffPeak_vs.strip().split(','):
        shell.write('\n# 按配置指定的比较组进行分析。\n')
        vs_dir=os.path.join(rMATS_dir,vs)
        if not os.path.exists(vs_dir):
            os.makedirs(vs_dir)

        treat=vs.strip().split('_vs_')[0]
        control=vs.strip().split('_vs_')[1]
        treat_str=''
        for i in group_dict[treat]:
            bam_dir=mapping_dir+'/'+i+'/hisat2_sorted.bam'
            treat_str+=bam_dir+','
        control_str=''
        for i in group_dict[control]:
            bam_dir=mapping_dir+'/'+i+'/hisat2_sorted.bam'
            control_str+=bam_dir+','
        cmd1='echo %s > %s'%(shlex.quote(treat_str.strip(',')),shlex.quote(vs_dir+'/treat.list'))
        cmd2='echo %s > %s'%(shlex.quote(control_str.strip(',')),shlex.quote(vs_dir+'/control.list'))

        # paired 和 fr-unstranded 是默认值，仅在配置不同时写出。
        readtype_option = ' -t single' if pe.lower()=='false' else ''
        # 允许 fastp 剪切后的变长 reads；链方向与比对/计数保持一致。
        libtype = {0: 'fr-unstranded', 1: 'fr-secondstrand', 2: 'fr-firststrand'}[strand]
        libtype_option = f' --libType {libtype}' if strand else ''
        threads_option = f' --nthread {threads}' if threads!=1 else ''
        # 缓存由 Python 脚本管理，sh 只保留 rMATS 的分析参数。
        cmd3=f'%s %s %s --b1 %s --b2 %s --gtf %s --od %s{readtype_option} --readLength {read_length} --variable-read-length{libtype_option}{threads_option}'%(shlex.quote(Python3),shlex.quote(os.path.join(bin,'run_rmats.py')),shlex.quote(rmats),shlex.quote(vs_dir+'/treat.list'),shlex.quote(vs_dir+'/control.list'),shlex.quote(Genome_gft),shlex.quote(vs_dir))
        shell.write(cmd1+'\n'+cmd2+'\n'+cmd3+' || exit $?\n')
        # 汇总五类剪接事件；筛选 FDR<0.05 且 |ΔPSI|>=0.1 的 SE 示例。
        shell.write('# 汇总剪接事件，再绘制有显著变化的代表性事件。\n')
        shell.write(f'{shlex.quote(Python3)} {shlex.quote(os.path.join(bin,"rmats_summary.py"))} {shlex.quote(vs_dir)} || exit $?\n')
        # 样本列表、分组标签、绘图样式及空结果判断均在绘图脚本中处理。
        shell.write(f'{shlex.quote(Python3)} {shlex.quote(os.path.join(bin,"rmats_sashimi.py"))} {shlex.quote(rmats2sashimiplot)} {shlex.quote(vs_dir)} || exit $?\n')
    shell.close()


def Variance_Calling():
    # 9. 从各样本的转录组比对结果中识别并整理 SNP 和 InDel 候选位点。
    folder = Variance_Calling_dir
    # 直接调用配置指定的 GATK，继承当前运行环境。
    gatk_command = shlex.quote(Gatk)
    dictionary = re.sub(r'\.(?:fa|fasta|fna)(?:\.gz)?$', '', Genome_fa) + '.dict'
    with open_shell(work_sh+'/Step_9_Variance_Calling.sh') as shell:
        shell.write('# 9. RNA 变异检测：使用 GATK 整理 RNA 比对数据，逐样本识别候选变异。\n')
        shell.write('# 依次完成 0–3 子步骤，再过滤并输出 SNP、InDel 位点及数量汇总。\n\n')
        shell.write(f'if [[ ! -s {Genome_fa}.fai || {Genome_fa} -nt {Genome_fa}.fai ]]; then {shlex.quote(samtools)} faidx {Genome_fa} || exit $?; fi\n')
        shell.write(f'if [[ ! -s {dictionary} || {Genome_fa} -nt {dictionary} ]]; then rm -f {dictionary}; {gatk_command} CreateSequenceDictionary -R {Genome_fa} -O {dictionary} || exit $?; fi\n\n')
        phase_commands = [[] for _ in range(4)]
        notes = ['0. 补充样本信息：为 BAM 添加样本和测序平台标识，供后续变异检测使用。',
                 '1. 标记重复序列：标识可能来自扩增的重复比对，保留原始 reads 并输出重复率记录。',
                 '2. 整理 RNA 比对：拆分跨内含子的比对；配置已知变异位点时进一步校正碱基质量。',
                 '3. 检测候选变异：逐样本调用 SNP 和 InDel，输出待过滤的原始 VCF。']
        # 默认按二倍体调用；倍性在脚本内部统一设置。
        ploidy_option = f' --sample-ploidy {ploidy}' if ploidy!=2 else ''
        hmm_threads_option = f' --native-pair-hmm-threads {job_threads}' if job_threads!=4 else ''
        for name in sample_id:
            base = folder+'/bam/'+name
            os.makedirs(base+'/tmp',exist_ok=True)
            for kind in ('snp','indel'): os.makedirs(folder+'/'+kind,exist_ok=True)
            gatk = f'{gatk_command} --java-options "-Xmx4g -Djava.io.tmpdir={base}/tmp"'
            phase_commands[0].append(f'{gatk} AddOrReplaceReadGroups -I {mapping_dir}/{name}/hisat2_sorted.bam -O {base}/0.hisat2_sorted_with_RG.bam --RGID {name} --RGLB {name} --RGPL ILLUMINA --RGPU {name} --RGSM {name}')
            phase_commands[1].append(f'{gatk} MarkDuplicates -I {base}/0.hisat2_sorted_with_RG.bam -O {base}/1.marked_duplicates.bam -M {base}/1.marked_dup_metrics.txt --CREATE_INDEX true')
            split_commands = [f'{gatk} SplitNCigarReads -R {Genome_fa} -I {base}/1.marked_duplicates.bam -O {base}/2.SplitNCigarReads.bam']
            bam = base+'/2.SplitNCigarReads.bam'
            if vcf_known_sites.lower() != 'none':
                sites = ' '.join('--known-sites '+shlex.quote(project_path(site.strip())) for site in vcf_known_sites.split(','))
                split_commands.append(f'{gatk} BaseRecalibrator -R {Genome_fa} -I {bam} {sites} -O {base}/3.recal_data.table')
                split_commands.append(f'{gatk} ApplyBQSR -R {Genome_fa} -I {bam} --bqsr-recal-file {base}/3.recal_data.table -O {base}/4.recalibrated.bam')
                bam = base+'/4.recalibrated.bam'
            phase_commands[2].append(' && '.join(split_commands))
            phase_commands[3].append(f'{gatk} HaplotypeCaller -R {Genome_fa} -I {bam} -O {base}/5.raw_variants.vcf.gz --standard-min-confidence-threshold-for-calling 20 --min-base-quality-score 20 --dont-use-soft-clipped-bases true{ploidy_option}{hmm_threads_option}')
        for i, commands in enumerate(phase_commands):
            with open_shell(work_sh+f'/Step_9_Variance_Calling_test{i}.sh') as phase:
                phase.write('# '+notes[i]+'\n')
                write_rush(phase, commands)
            shell.write(f'bash {work_sh}/Step_9_Variance_Calling_test{i}.sh || exit $?\n')
        shell.write('\n# 根据变异质量过滤候选位点，分别导出通过过滤的 SNP、InDel 及基因型信息。\n')
        commands = []
        for name in sample_id:
            base = folder+'/bam/'+name
            sample_commands = [f"{gatk_command} VariantFiltration -R {Genome_fa} -V {base}/5.raw_variants.vcf.gz --cluster-window-size 35 --filter-expression 'QD < 2.0' --filter-name LowQD --filter-expression 'FS > 30.0' --filter-name HighFS -O {base}/filtered_variants.vcf.gz"]
            for kind,plural,variant_type in [('snp','snps','SNP'),('indel','indels','INDEL')]:
                target = folder+'/'+kind+'/'+name+'_'+plural
                sample_commands.append(f'{gatk_command} SelectVariants -R {Genome_fa} -V {base}/filtered_variants.vcf.gz --exclude-filtered true --exclude-non-variants true --select-type-to-include {variant_type} -O {target}.vcf.gz')
                sample_commands.append(f'{gatk_command} VariantsToTable -V {target}.vcf.gz -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER -GF GT -GF AD -GF DP -O {target}_stats.txt')
            commands.append(' && '.join(sample_commands))
        write_rush(shell, commands)
        shell.write(f'{shlex.quote(Python3)} {bin}/variant_summary.py {folder} {sample_info_path} {DiffPeak_vs}\n')


def WGCNA():
    # 10. 按表达变化的相似性聚合基因，寻找与分组或表型相关的共表达模块。
    folder = analysis_dir + '/10.WGCNA'
    os.makedirs(folder, exist_ok=True)
    with open_shell(work_sh + '/Step_10_WGCNA.sh') as shell:
        shell.write('# 10. 共表达网络分析：使用 WGCNA 将表达趋势相近的基因划为模块，评估模块与分组或表型的关系。\n')
        shell.write('# 输出模块、关联结果和候选核心基因；6–14 个样本采用探索模式，少于 6 个样本跳过。\n\n')
        shell.write('%s %s/WGCNA.R %s/COUNT.txt %s %s %s %s %s %s\n' %
                    (shlex.quote(Rscript), bin, Gene_id_dir, sample_info_path, folder,
                     threads, wgcna_power, shlex.quote(wgcna_traits), wgcna_max_genes))


def Report():
    # 11. 汇集各分析步骤的结果，生成便于阅读和查阅的项目报告。
    with open(metadata_dir+'/project_info.txt','w',encoding='utf-8',newline='\n') as handle:
        for key,value in [('合同编号',contract_Num),('项目名称',project_Name),('分析单位',company_name),('报告时间',report_Time),('参考版本',version)]:
            handle.write(key+'\t'+str(value)+'\n')
    report=analysis_dir+'/report'
    with open_shell(work_sh+'/Step_11_Report.sh') as shell:
        shell.write('# 11. 生成分析报告：汇集已有图表和结果，说明各步骤的目的及结果含义。\n')
        shell.write('# 输出 HTML 报告及配套展示文件，本步骤不重新进行统计分析。\n\n')
        shell.write(f'{shlex.quote(Python3)} {bin}/prepare_report.py {analysis_dir} {bin} {shlex.quote(Pdftoppm)} {function_stats}\n')
        shell.write(f'{shlex.quote(Python3)} {bin}/report.py {bin}/report.Rmd {report}/report.Rmd\n')
        shell.write(f'{shlex.quote(Rscript)} {bin}/rmarkdown.R --infile {report}/report.Rmd --outfile {report}/report.html\n')


def Result():
    # 12. 整理可交付的分析文件和表格，方便查阅及复制整个项目。
    with open_shell(work_sh+'/Step_12_Result.sh') as shell:
        shell.write('# 12. 整理交付结果：建立结果目录的相对链接，并将更新的多列表格转换为 Excel。\n\n')
        shell.write(f'{shlex.quote(Python3)} {bin}/collect_result.py {analysis_dir} {str(run_rmats).lower()} {str(run_variants).lower()} {str(run_wgcna).lower()}\n')
        shell.write(f'{shlex.quote(Python3)} {bin}/txt2xlsx.py {analysis_dir}\n')


def RunAll():
    # 可单步运行；run_all 只是按依赖顺序调用既有 Step 脚本。
    steps = ['Step_0_rename.sh', 'Step_1_qc.sh', 'Step_2_mapping.sh', 'Step_3_GenesExpress.sh',
             'Step_4_DiffGenes.sh', 'Step_5_Function_anno.sh', 'Step_6_GO_KEGG_Enrichment.sh']
    steps.append('Step_7_GSEA.sh')
    if run_rmats:
        steps.append('Step_8_rMATS.sh')
    if run_variants:
        steps.append('Step_9_Variance_Calling.sh')
    if run_wgcna:
        steps.append('Step_10_WGCNA.sh')
    steps += ['Step_11_Report.sh', 'Step_12_Result.sh']
    with open_shell(work_sh + '/run_all.sh') as shell:
        shell.write('# 按顺序运行；删除或注释某一步的 bash 行即可跳过该步。\n')
        shell.write('set -e\n\n')
        for step in steps:
            shell.write('bash ' + shlex.quote(os.path.join(work_sh, step)) + '\n')
    with open(metadata_dir + '/Transcriptome.used.conf', 'w', encoding='utf-8', newline='\n') as handle:
        Config.write(handle)
    print('已生成脚本：' + work_sh)
    print('请检查脚本后按需运行各 Step；完整执行：bash ' + os.path.join(work_sh, 'run_all.sh'))


def disabled_step(filename, label):
    # 关闭可选分析时覆盖旧脚本为说明，避免误跑旧配置生成的命令。
    with open_shell(work_sh + '/' + filename) as shell:
        shell.write('echo "SKIPPED: ' + label + ' is disabled by internal settings"\n')


if __name__=='__main__':
    Qc()
    Mapping()
    GenesExpress()
    DiffGenes()
    Function_anno()
    GO_KEGG_Enrichment()
    GSEA()
    if run_rmats:
        rMATS()
    else:
        disabled_step("Step_8_rMATS.sh", "rMATS")
    if run_variants:
        Variance_Calling()
    else:
        disabled_step("Step_9_Variance_Calling.sh", "Variant calling")
        for phase in range(4):
            disabled_step(f"Step_9_Variance_Calling_test{phase}.sh", "Variant calling")
    if run_wgcna:
        WGCNA()
    else:
        disabled_step("Step_10_WGCNA.sh", "WGCNA")
    Report()
    Result()
    RunAll()

    
