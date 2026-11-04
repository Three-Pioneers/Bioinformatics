from genericpath import exists
from re import S
import sys
import configparser
import argparse
import os
from xmlrpc.client import FastParser



parser = argparse.ArgumentParser()
parser.add_argument("-c", "--conf",help="conf")
args = parser.parse_args()
conf=args.conf

Config = configparser.ConfigParser()
Config.read(conf)    #读取配置文件

"""
print( Config.sections() )  #['SampleInfo']
print( Config.options('Data') )  #['DataDir', 'OutPut']
print( Config.items('Data') )  #[('DataDir','  '),('OutPut','   ')]
DataDir = Config.get('Data', 'DataDir')
print(value)
"""
datadir = Config.get('Data', 'DataDir')
outdir = Config.get('Data', 'OutDir')
rename = Config.get('Data', 'Rename')
renamefile = Config.get('Data', 'Renamefile')

pe = Config.get('Data', 'PE')

version = Config.get('DB', 'version')
Genome_fa = Config.get('DB', 'Genome_fa')
Genome_gft = Config.get('DB', 'Genome_gft')
Genome_annotation = Config.get('DB', 'Genome_annotation')
Gene_id_name = Config.get('DB', 'Gene_id_name')
taxonomy = Config.get('DB', 'taxonomy')
gene_type = Config.get('DB', 'gene_type')
Species = Config.get('DB', 'Species')
vcf_known_sites = Config.get('DB', 'vcf_known_sites')
dbsnp = Config.get('DB', 'dbsnp')


Group = Config.get('SampleInfo', 'Group')
DiffPeak_vs = Config.get('SampleInfo', 'DiffPeak_vs')
Demo_sample = Config.get('SampleInfo', 'Demo_sample')
Demo_group = Config.get('SampleInfo', 'Demo_group')


contract_Num = Config.get('ReportInfo', 'Contract_Num')
project_Name = Config.get('ReportInfo', 'Project_Name')
report_Time = Config.get('ReportInfo', 'Report_Time')
company_name = Config.get('ReportInfo', 'company_name')

Kneaddata = Config.get('software', 'Kneaddata')
Kneaddata_build_database = Config.get('software', 'Kneaddata_build_database')
Bowtie2_build = Config.get('software', 'Bowtie2-build')
Trimmomatic = Config.get('software', 'Trimmomatic')
Fasta_seq_length_pl = Config.get('software', 'Fasta_seq_length_pl')
Rscript = Config.get('software', 'Rscript')
CD_HIT_EST = Config.get('software', 'CD_HIT_EST')
MetaPhlAn2 = Config.get('software', 'MetaPhlAn2')
Python2 = Config.get('software', 'Python2')
Python3 = Config.get('software', 'Python3')
eggNOG_mapper = Config.get('software', 'eggNOG_mapper')
Run_dbcan = Config.get('software', 'Run_dbcan')
Fastp = Config.get('software', 'Fastp')
rmats = Config.get('software', 'rmats')
rmats2sashimiplot = Config.get('software', 'rmats2sashimiplot')
samtools = Config.get('software', 'samtools')
featureCounts = Config.get('software', 'featureCounts')
hisat2 = Config.get('software', 'hisat2')


bin = Config.get('software', 'bin')

datalist=os.listdir(datadir)



analysis_dir=outdir+"/analysis/"
work_sh=analysis_dir+'/work_sh/'
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
Function_anno_dir=analysis_dir+'5.Function_anno'
GO_KEGG_Enrichment_dir=analysis_dir+'6.GO_KEGG_Enrichment'
PPI_dir=analysis_dir+'7.PPI'
GSEA_dir=analysis_dir+'8.GSEA'
rMATS_dir=analysis_dir+'9.rMATS'
Variance_Calling_dir=analysis_dir+'10.Variance_Calling'


if not os.path.exists(Variance_Calling_dir):
    os.makedirs(Variance_Calling_dir)
if not os.path.exists(rMATS_dir):
    os.makedirs(rMATS_dir)
if not os.path.exists(PPI_dir):
    os.makedirs(PPI_dir)
if not os.path.exists(Function_anno_dir):
    os.makedirs(Function_anno_dir)
if not os.path.exists(GSEA_dir):
    os.makedirs(GSEA_dir)
if not os.path.exists(GO_KEGG_Enrichment_dir):
    os.makedirs(GO_KEGG_Enrichment_dir)
if not os.path.exists(DiffGenes_dir):
    os.makedirs(DiffGenes_dir)
if not os.path.exists(featureCounts_dir):
    os.makedirs(featureCounts_dir)
if not os.path.exists(Gene_id_dir):
    os.makedirs(Gene_id_dir)
if not os.path.exists(analysis_dir):
    os.makedirs(analysis_dir) 
if not os.path.exists(qc_dir):
    os.makedirs(qc_dir)
if not os.path.exists(raw_dir):
    os.makedirs(raw_dir)
if not os.path.exists(fastp_dir):
    os.makedirs(fastp_dir)   
if not os.path.exists(clean_dir):
    os.makedirs(clean_dir) 
if not os.path.exists(qc_stats_dir):
    os.makedirs(qc_stats_dir)
if not os.path.exists(mapping_dir):
    os.makedirs(mapping_dir)
if not os.path.exists(genesexpress_dir):
    os.makedirs(genesexpress_dir) 
if not os.path.exists(work_sh):
    os.makedirs(work_sh)

################ Rename
rename_shell=work_sh+"/Step_0_rename.sh"
shell=open(rename_shell,"w")
dict_rename={}
sample_id=[]   
sample_id_str=''                                         #样本id
if rename.lower() == 'true':
    for i in renamefile.split(","):
        xx=i.split(" ")
        dict_rename[xx[0]]=xx[1]
        if xx[1] not in sample_id:
            sample_id.append(xx[1])
            sample_id_str+=xx[1]+" "                        
    for j in datalist:
        yy=j.split("_R",1)
        after = datadir+'/'+j
        late = raw_dir+dict_rename[yy[0]]+'_R'+yy[1]
        cmd="ln -s  %s  %s" %(after,late)
        shell.write(cmd+"\n")
else:
    for i in datalist:
        if i.rsplit("_R")[1]=='1.fq.gz':
            if i.split("_R1")[0] not in sample_id:
                sample_id.append(i.split("_R1")[0])
                sample_id_str+=i.split("_R1")[0]+" "
        after = datadir+'/'+i
        late = raw_dir+i
        cmd="ln -s  %s  %s " %(after,late)
        shell.write(cmd+"\n")

group_dict={}
for i in Group.strip().split(","):
    xx=i.split("=")
    list_test=[]
    for j in xx[1].split(" "):
        list_test.append(j)
    group_dict[xx[0]]=list_test
###############

###############

if Gene_id_name.lower() !='none':
    all_go_anno=Genome_annotation+'/2.GO/GO_function_id_name_all.txt'
    all_kegg_anno=Genome_annotation+'/3.KEGG/Enrichment_KEGG_id_name_all.txt'
else:
    all_go_anno=Genome_annotation+'/2.GO/GO_function_id.txt'
    all_kegg_anno=Genome_annotation+'/3.KEGG/Enrichment_KEGG_id.txt'





###############

def Qc():
    qc_shell=work_sh+"Step_1_qc.sh"
    shell=open(qc_shell,"w")

    if pe.lower() == 'true':
        for id in sample_id:
            raw_data_R1=raw_dir+id+"_R1.fq.gz"
            raw_data_R2=raw_dir+id+"_R2.fq.gz"
            clean_data_R1=clean_dir+id+"_R1.fq.gz"
            clean_data_R2=clean_dir+id+"_R2.fq.gz"
            fastp_json=fastp_dir+id+"_fastp.json"
            fastp_html=fastp_dir+id+"_fastp.html"
            cmd1='%s  --in1 %s --in2 %s --out1 %s --out2 %s --detect_adapter_for_pe   --json %s --html %s --thread 20'%(Fastp,raw_data_R1,raw_data_R2,clean_data_R1,clean_data_R2,fastp_json,fastp_html)
            shell.write(cmd1+"\n")

    else:
        for id in sample_id:
            raw_data_R1=raw_dir+id+"_R1.fq.gz"
            clean_data_R1=clean_dir+id+".fq.gz"
            fastp_json=fastp_dir+id+"_fastp.json"
            fastp_html=fastp_dir+id+"_fastp.html"
            cmd1='%s --in1 %s --out1 %s --detect_adapter_for_pe   --json %s --html %s --thread 20'%(Fastp,raw_data_R1,clean_data_R1,fastp_json,fastp_html)
            shell.write(cmd1+"\n")

    
    raw_md5=raw_dir+'rawdata_md5.txt'
    clean_md5=clean_dir+'cleandata_md5.txt'
    raw_file=raw_dir+"*gz"
    clean_file=clean_dir+"*gz"
    cmd3=' md5sum %s|awk -F\'/\' \'{print$1,$NF}\'|awk -F\' \' \'{print$1,$NF}\' > %s' %(raw_file,raw_md5)
    cmd2=' md5sum %s|awk -F\'/\' \'{print$1,$NF}\'|awk -F\' \' \'{print$1,$NF}\' > %s' %(clean_file,clean_md5)
    shell.write(cmd3+"\n"+cmd2+'\n')

    cmd4='multiqc --outdir  %s  %s' %(qc_stats_dir,fastp_dir)
    shell.write(cmd4+"\n")

    fastp_stats_py=bin+'/fastp_stats.py'
    cmd5='%s %s --input_fastp_dir %s --stats_out_dir %s'%(Python3,fastp_stats_py,fastp_dir,qc_stats_dir)
    shell.write(cmd5+"\n")

def Mapping():
    mapping_shell=work_sh+"Step_2_mapping.sh"
    shell=open(mapping_shell,"w")
    index=Genome_fa.rsplit('/',1)[0]+'/index_hisat2/index'
    summary_str=''
    for id in sample_id:
        sample_mapping_dir=mapping_dir+'/'+id
        if not os.path.exists(sample_mapping_dir):
            os.makedirs(sample_mapping_dir)
        
        if pe.lower() == 'true':
            clean_data_R1=clean_dir+id+"_R1.fq.gz"
            clean_data_R2=clean_dir+id+"_R2.fq.gz"
            cmd1='hisat2 --dta -p 20 -x %s -1 %s -2 %s -S %s/hisat2.sam --summary-file %s/summary.txt'%(index,clean_data_R1,clean_data_R2,sample_mapping_dir,sample_mapping_dir)
        else:
            clean_data_R1=clean_dir+id+".fq.gz"
            cmd1='hisat2 --dta -p 20 -x %s -U %s -S %s/hisat2.sam  --summary-file %s/summary.txt '%(index,clean_data_R1,sample_mapping_dir,sample_mapping_dir)
        shell.write(cmd1+'\n')

        cmd2='%s view -@ 4 -Sb %s/hisat2.sam | %s sort -@ 4 -o %s/hisat2_sorted.bam && %s index %s/hisat2_sorted.bam'%(samtools,sample_mapping_dir,samtools,sample_mapping_dir,samtools,sample_mapping_dir)
        cmd2_1='rm -rf %s/hisat2.sam'%(sample_mapping_dir)
        shell.write(cmd2+'\n'+cmd2_1+'\n')

        summary_str+=sample_mapping_dir+'/summary.txt'+','
    mapping_stats_py=bin+'mapping_stats.py'
    cmd3='python %s %s %s '%(mapping_stats_py,summary_str.strip(','),mapping_dir)
    shell.write(cmd3+'\n')


def GenesExpress():
    GenesExpress_shell=work_sh+"/Step_3_GenesExpress.sh"
    shell=open(GenesExpress_shell,"w")

    all_bam=''
    for id in sample_id:
        bam=mapping_dir+'/'+id+"/hisat2_sorted.bam"
        all_bam+=bam+' '
    cmd1='%s -a %s -o %s/featureCounts.txt -T 40 -g gene_id  -t  exon  -p %s'%(featureCounts,Genome_gft,featureCounts_dir,all_bam)
    shell.write(cmd1+'\n')


    gene_result_stas_py=bin+'/gene_result_stas.py'
    cmd2='python %s %s/featureCounts.txt %s'%(gene_result_stas_py,featureCounts_dir,Gene_id_dir)
    shell.write(cmd2+'\n')

    #PCA
    PCA_R=bin+'/PCA.R'
#    cmd3='Rscript %s %s/COUNT.txt %s/report/src/table/sample_info.txt %s COUNT'%(PCA_R,Gene_id_dir,analysis_dir,Gene_id_dir)
#    cmd4='Rscript %s %s/FPKM.txt %s/report/src/table/sample_info.txt %s FPKM'%(PCA_R,Gene_id_dir,analysis_dir,Gene_id_dir)
#    cmd5='Rscript %s %s/TPM.txt %s/report/src/table/sample_info.txt %s TPM'%(PCA_R,Gene_id_dir,analysis_dir,Gene_id_dir)

#    shell.write(cmd3+'\n'+cmd4+'\n'+cmd5+'\n')

    #violin
    violin_R=bin+'/violin.R'
    cmd6='Rscript %s %s/COUNT.txt %s/report/src/table/sample_info.txt %s COUNT'%(violin_R,Gene_id_dir,analysis_dir,Gene_id_dir)
    cmd7='Rscript %s %s/FPKM.txt %s/report/src/table/sample_info.txt %s FPKM'%(violin_R,Gene_id_dir,analysis_dir,Gene_id_dir)
    cmd8='Rscript %s %s/TPM.txt %s/report/src/table/sample_info.txt %s TPM'%(violin_R,Gene_id_dir,analysis_dir,Gene_id_dir)

    shell.write(cmd6+'\n'+cmd7+'\n'+cmd8+'\n')

    #cor
    cor_R=bin+'/cor.R'
    cmd9='Rscript %s %s/COUNT.txt  %s COUNT'%(cor_R,Gene_id_dir,Gene_id_dir)
    cmd10='Rscript %s %s/FPKM.txt  %s FPKM'%(cor_R,Gene_id_dir,Gene_id_dir)
    cmd11='Rscript %s %s/TPM.txt  %s TPM'%(cor_R,Gene_id_dir,Gene_id_dir)
    shell.write(cmd9+'\n'+cmd10+'\n'+cmd11+'\n')

    if Gene_id_name.lower() !='none':
        Gene_name_dir=genesexpress_dir+'/2.Gene_name_part'
        if not os.path.exists(Gene_name_dir):
            os.makedirs(Gene_name_dir)

        gene_name_result_stats_part_py=bin+'gene_name_result_stats_part.py'
        cmd16='python %s %s %s %s' %(gene_name_result_stats_part_py,Gene_id_name,Gene_id_dir,Gene_name_dir)
        #cmd17='Rscript %s %s/COUNT.txt %s/report/src/table/sample_info.txt %s COUNT'%(PCA_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        #cmd18='Rscript %s %s/FPKM.txt %s/report/src/table/sample_info.txt %s FPKM'%(PCA_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        #cmd19='Rscript %s %s/TPM.txt %s/report/src/table/sample_info.txt %s TPM'%(PCA_R,Gene_name_dir,analysis_dir,Gene_name_dir)

        cmd20='Rscript %s %s/COUNT.txt %s/report/src/table/sample_info.txt %s COUNT'%(violin_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        cmd21='Rscript %s %s/FPKM.txt %s/report/src/table/sample_info.txt %s FPKM'%(violin_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        cmd22='Rscript %s %s/TPM.txt %s/report/src/table/sample_info.txt %s TPM'%(violin_R,Gene_name_dir,analysis_dir,Gene_name_dir)

        cmd23='Rscript %s %s/COUNT.txt  %s COUNT'%(cor_R,Gene_name_dir,Gene_name_dir)
        cmd24='Rscript %s %s/FPKM.txt  %s FPKM'%(cor_R,Gene_name_dir,Gene_name_dir)
        cmd25='Rscript %s %s/TPM.txt  %s TPM'%(cor_R,Gene_name_dir,Gene_name_dir)

        #shell.write(cmd16+'\n'+cmd17+'\n'+cmd18+'\n'+cmd19+'\n'+cmd20+'\n'+cmd21+'\n'+cmd22+'\n'+cmd23+'\n'+cmd24+'\n'+cmd25+'\n')
        shell.write(cmd16+'\n'+cmd20+'\n'+cmd21+'\n'+cmd22+'\n'+cmd23+'\n'+cmd24+'\n'+cmd25+'\n')


    if Gene_id_name.lower() !='none':
        Gene_name_dir=genesexpress_dir+'/3.Gene_name_all'
        if not os.path.exists(Gene_name_dir):
            os.makedirs(Gene_name_dir)

        gene_name_result_stats_all_py=bin+'gene_name_result_stats_all.py'
        cmd16='python %s %s %s %s' %(gene_name_result_stats_all_py,Gene_id_name,Gene_id_dir,Gene_name_dir)
        #cmd17='Rscript %s %s/COUNT.txt %s/report/src/table/sample_info.txt %s COUNT'%(PCA_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        #cmd18='Rscript %s %s/FPKM.txt %s/report/src/table/sample_info.txt %s FPKM'%(PCA_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        #cmd19='Rscript %s %s/TPM.txt %s/report/src/table/sample_info.txt %s TPM'%(PCA_R,Gene_name_dir,analysis_dir,Gene_name_dir)

        cmd20='Rscript %s %s/COUNT.txt %s/report/src/table/sample_info.txt %s COUNT'%(violin_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        cmd21='Rscript %s %s/FPKM.txt %s/report/src/table/sample_info.txt %s FPKM'%(violin_R,Gene_name_dir,analysis_dir,Gene_name_dir)
        cmd22='Rscript %s %s/TPM.txt %s/report/src/table/sample_info.txt %s TPM'%(violin_R,Gene_name_dir,analysis_dir,Gene_name_dir)

        cmd23='Rscript %s %s/COUNT.txt  %s COUNT'%(cor_R,Gene_name_dir,Gene_name_dir)
        cmd24='Rscript %s %s/FPKM.txt  %s FPKM'%(cor_R,Gene_name_dir,Gene_name_dir)
        cmd25='Rscript %s %s/TPM.txt  %s TPM'%(cor_R,Gene_name_dir,Gene_name_dir)

        #shell.write(cmd16+'\n'+cmd17+'\n'+cmd18+'\n'+cmd19+'\n'+cmd20+'\n'+cmd21+'\n'+cmd22+'\n'+cmd23+'\n'+cmd24+'\n'+cmd25+'\n')
        shell.write(cmd16+'\n'+cmd20+'\n'+cmd21+'\n'+cmd22+'\n'+cmd23+'\n'+cmd24+'\n'+cmd25+'\n')





def DiffGenes():
    DiffGenes_shell=work_sh+"/Step_4_DiffGenes.sh"
    shell=open(DiffGenes_shell,"w")

    for vs in DiffPeak_vs.strip().split(','):
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
            if Gene_id_name.lower() !='none':
                cmd1='python %s %s/3.Gene_name_all/COUNT.txt  %s/report/src/table/sample_info.txt %s %s'%(gene_order_py,genesexpress_dir,analysis_dir,vs,vs_dir)
            else:
                cmd1='python %s %s/1.Gene_id/COUNT.txt  %s/report/src/table/sample_info.txt %s %s'%(gene_order_py,genesexpress_dir,analysis_dir,vs,vs_dir)
            cmd2='%s %s %s/COUNT.txt %s/sample_info.txt %s'%(Rscript,diffExprGene_R,vs_dir,vs_dir,vs_dir)
            shell.write(cmd1+'\n'+cmd2+'\n')
            cmd4='%s %s %s/All_genes_exprData.txt %s' %(Rscript,volcano_R,vs_dir,vs_dir)
        else:
            if Gene_id_name.lower() !='none':
                cmd1='python %s %s/3.Gene_name_all/COUNT.txt  %s/report/src/table/sample_info.txt %s %s  %s'%(gfold_diffExprGene_py,genesexpress_dir,analysis_dir,group_dict[treat][0],group_dict[control][0],vs_dir)
                cmd2='gfold diff -s1 %s/treat.txt -s2 %s/control.txt -o %s/gfold.diff'%(vs_dir,vs_dir,vs_dir)
            else:
                cmd1='python %s %s/1.Gene_id/COUNT.txt %s/report/src/table/sample_info.txt  %s %s %s'%(gfold_diffExprGene_py,genesexpress_dir,analysis_dir,group_dict[treat][0],group_dict[control][0],vs_dir)
                cmd2='gfold diff -s1 %s/treat.txt -s2 %s/control.txt -o %s/gfold.diff'%(vs_dir,vs_dir,vs_dir)
            cmd3='python %s %s/gfold.diff %s/COUNT.txt %s'%(gfold_trans_py,vs_dir,vs_dir,vs_dir)
            shell.write(cmd1+'\n'+cmd2+'\n'+cmd3+'\n')
            cmd4='%s %s %s/All_genes_exprData.txt %s' %(Rscript,MA_R,vs_dir,vs_dir)
        shell.write(cmd4+'\n'+'\n')

        heatmap_R=bin+'/heatmap.R'
        cmd4="sed '1d' %s/Sig_genes_exprData.txt | sort -g -k 4  |cut -f 1 |head -n 50 |sort -k 1 > %s/tmp_top50.id  "%(vs_dir,vs_dir)
        cmd5="sed '1d' %s/COUNT.txt |sort -k 1 > %s/tmp_COUNT.txt"%(vs_dir,vs_dir)
        cmd6='cat %s/COUNT.txt|head -n 1 > %s/heatmap_input.txt'%(vs_dir,vs_dir)
        cmd7="join --nocheck-order  -t $'\\t' -1 1 -2 1  %s/tmp_top50.id %s/tmp_COUNT.txt  >> %s/heatmap_input.txt"%(vs_dir,vs_dir,vs_dir)
        cmd8='%s %s %s/heatmap_input.txt %s/sample_info.txt %s'%(Rscript,heatmap_R,vs_dir,vs_dir,vs_dir)
        shell.write(cmd4+'\n'+cmd5+'\n'+cmd6+'\n'+cmd7+'\n'+cmd8+'\n'+'\n')

    #veen
    veen_input_py=bin+'/venn_input.py'
    veen_R=bin+'/venn.R'

    Sig_genes_exprData_str=''
    if len(DiffPeak_vs.strip().split(',')) > 1:
        for vs in DiffPeak_vs.strip().split(','):
            Sig_genes_exprData=DiffGenes_dir+'/'+vs+'/Sig_genes_exprData.txt'
            Sig_genes_exprData_str+=Sig_genes_exprData+','

        cmd10='python %s %s %s'%(veen_input_py,Sig_genes_exprData_str.strip(','),DiffGenes_dir)
        cmd11='Rscript %s %s/venn_input.txt %s '%(veen_R,DiffGenes_dir,DiffGenes_dir)
        shell.write(cmd10+'\n'+cmd11+'\n')

    #stats
    diffExprGene_stats_py=bin+'diffExprGene_stats.py'
    diffExprGene_stats_R=bin+'diffExprGene_stats.R'
    All_genes_exprData_str=''
    for vs in DiffPeak_vs.strip().split(','):
        All_genes_exprData=DiffGenes_dir+'/'+vs+'/All_genes_exprData.txt'
        All_genes_exprData_str+=All_genes_exprData+','
    cmd12='python %s %s %s '%(diffExprGene_stats_py,All_genes_exprData_str.strip(','),DiffGenes_dir)
    cmd13='Rscript %s %s/diffExprGene_stats_input.txt %s'%(diffExprGene_stats_R,DiffGenes_dir,DiffGenes_dir)
    shell.write(cmd12+'\n'+cmd13+'\n')

def Function_anno():
    Function_anno_shell=work_sh+"Step_5_Function_anno.sh"
    shell=open(Function_anno_shell,"w")
    if Gene_id_name.lower() !='none':
        cmd1='cp -rf %s/*/*function_id.txt %s/*/stats*.txt %s/*/*function_id_name_all.txt  %s'%(Genome_annotation,Genome_annotation,Genome_annotation,Function_anno_dir)
    else:
        cmd1='cp -rf %s/*/*function_id.txt %s/*/stats*.txt   %s'%(Genome_annotation,Genome_annotation,Function_anno_dir)
    shell.write(cmd1+'\n'+'\n')

    merge_py=bin+'/merge.py'
    for vs in DiffPeak_vs.strip().split(','):
        vs_dir=DiffGenes_dir+'/'+vs
        Sig_genes_exprData=vs_dir+'/Sig_genes_exprData.txt'
        All_genes_exprData=vs_dir+'/All_genes_exprData.txt'
        Sig_genes_exprData_merge=vs_dir+'/Sig_genes_exprData_merge.txt'
        All_genes_exprData_merge=vs_dir+'/All_genes_exprData_merge.txt'
        COUNT=vs_dir+'/COUNT.txt'
        if Gene_id_name.lower() !='none':
            stats_function=Function_anno_dir+'/stats_id_name_all.txt'
        else:
            stats_function=Function_anno_dir+'/stats_id.txt'
        cmd2='python %s %s %s %s %s'%(merge_py,Sig_genes_exprData,Sig_genes_exprData_merge,COUNT,stats_function)
        cmd3='python %s %s %s %s %s'%(merge_py,All_genes_exprData,All_genes_exprData_merge,COUNT,stats_function)
        shell.write(cmd2+'\n'+cmd3+'\n')


def GO_KEGG_Enrichment():
    GO_KEGG_Enrichment_shell=work_sh+"Step_6_GO_KEGG_Enrichment.sh"
    shell=open(GO_KEGG_Enrichment_shell,"w")
    GO_KEGG_Enrichment_R=bin+'/GO_KEGG_Enrichment.R'
    pathview_R=bin+'/pathview.R'
    GOChord_input_py=bin+'/GOChord_input.py'
    GOChord_R=bin+'/GOChord.R'
    circlize_input_py=bin+'/circlize_input.py'
    circlize_R=bin+'/circlize.R'
    for vs in DiffPeak_vs.strip().split(','):
        vs_dir=GO_KEGG_Enrichment_dir+'/'+vs
        if not os.path.exists(vs_dir):
            os.makedirs(vs_dir)
        Pathway_dir=vs_dir+'/Pathway'
        if not os.path.exists(Pathway_dir):
            os.makedirs(Pathway_dir)
        Sig_genes_exprData=DiffGenes_dir+'/'+vs+'/Sig_genes_exprData.txt'
        cmd1='Rscript %s %s %s %s %s'%(GO_KEGG_Enrichment_R,Sig_genes_exprData,all_go_anno,all_kegg_anno,vs_dir)
        cmd2='Rscript %s %s %s/Sig_KEGG_Enrichment.txt %s %s %s %s'%(pathview_R,Sig_genes_exprData,vs_dir,all_kegg_anno,gene_type,Species,Pathway_dir)
        
        #cmd3='python %s %s/Sig_GO_Enrichment.txt %s %s'%(GOChord_input_py,vs_dir,Sig_genes_exprData,vs_dir)
        #cmd4='Rscript %s %s/GOChord_input.txt %s'%(GOChord_R,vs_dir,vs_dir)
        
        cmd5='python %s  %s/Sig_GO_Enrichment.txt %s %s'%(circlize_input_py,vs_dir,Sig_genes_exprData,vs_dir)
        cmd6='Rscript %s %s/GO_circlize_input.txt %s '%(circlize_R,vs_dir,vs_dir)
        cmd7='pdftoppm -png %s/GO_circlize.pdf %s/GO_circlize && mv %s/GO_circlize-1.png %s/GO_circlize.png '%(vs_dir,vs_dir,vs_dir,vs_dir)
        
        shell.write(cmd1+'\n'+cmd2+'\n'+cmd5+'\n'+cmd6+'\n'+cmd7+'\n'+'\n')


def PPI():
    PPI_shell=work_sh+"Step_7_PPI.sh"
    shell=open(PPI_shell,"w")

    for vs in DiffPeak_vs.strip().split(','):
        vs_dir=PPI_dir+'/'+vs
        if not os.path.exists(vs_dir):
            os.makedirs(vs_dir)
        Sig_genes_exprData=DiffGenes_dir+'/'+vs+'/Sig_genes_exprData.txt'
        if Gene_id_name.lower() !='none':
            cmd1="cat %s |awk -F'(' '{print$1\"\\t\"$2}' |awk -F'\\t' '{print$1\"\\t\"$4\"\\t\"$5}'|awk -F'\\t' '$2 > 2 && $3 < 0.1 {print$0}' |sed '1d' |sed '1i\\id\\tlog2FC\\tpvalue'  > %s/ppi_input.txt "%(Sig_genes_exprData,vs_dir)  
        else:
            cmd1="cat %s |awk -F'\\t' '{print$1\"\\t\"$4\"\\t\"$5}'|awk -F'\\t' ' $3 < 0.05 {print$0}' |sed '1d' |sed '1i\\id\\tlog2FC\\tpvalue'   > %s/ppi_input.txt "%(Sig_genes_exprData,vs_dir)  
        shell.write(cmd1+'\n')

        PPI_R=bin+'PPI.R'
        cmd2='Rscript  %s   %s/ppi_input.txt  %s   %s ' %(PPI_R,vs_dir,taxonomy,vs_dir)
        shell.write(cmd2+'\n')



def GSEA():
    GSEA_shell=work_sh+"Step_8_GSEA.sh"
    shell=open(GSEA_shell,"w")

    GSEA_R=bin+'/GSEA.R'
    for vs in DiffPeak_vs.strip().split(','):
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
        cmd1='Rscript %s %s %s %s %s'%(GSEA_R,All_genes_exprData,all_go_anno,all_kegg_anno,vs_dir)
        shell.write(cmd1+'\n'+'\n')
    



def rMATS():
    rMATS_shell=work_sh+"Step_9_rMATS.sh"
    shell=open(rMATS_shell,"w")
    for vs in DiffPeak_vs.strip().split(','):
        vs_dir=rMATS_dir+'/'+vs+'/'
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
        cmd1="echo '%s' > %s/treat.list"%(treat_str.strip(','),vs_dir)
        cmd2="echo '%s' > %s/control.list"%(control_str.strip(','),vs_dir)

        if pe.lower() == 'true':
            readtype='paired'
        else:
            readtype='single'
        cmd3='%s %s --b1 %s/treat.list --b2 %s/control.list --gtf %s --od %s -t %s  --readLength 150 --nthread 20 --variable-read-length --tmp %s/tmp '%(Python3,rmats,vs_dir,vs_dir,Genome_gft,vs_dir,readtype,vs_dir)
        cmd4=" awk -F \"\\t\" 'NR==1 || ($20 < 0.05 && ($23 > 0.1 || $23 < -0.1))' %s/SE.MATS.JC.txt | sort -k20,20n | awk -F \"\\t\" 'NR < 22' > %s/Sig_SE.MATS.JC.txt   "%(vs_dir,vs_dir)
        cmd5='%s --b1 %s --b2 %s -t SE -e %s/Sig_SE.MATS.JC.txt --l1 %s --l2 %s -o %s'%(rmats2sashimiplot,treat_str.strip(','),control_str.strip(','),vs_dir,treat,control,vs_dir)
        shell.write(cmd1+'\n'+cmd2+'\n'+cmd3+'\n'+cmd4+'\n'+cmd5+'\n')


def Variance_Calling():
    Variance_Calling_shell=work_sh+"/Step_10_Variance_Calling.sh"
    shell=open(Variance_Calling_shell,"w")

    Variance_Calling_shell0=work_sh+"/Step_10_Variance_Calling_test0.sh"
    shell0=open(Variance_Calling_shell0,"w")
    Variance_Calling_shell1=work_sh+"/Step_10_Variance_Calling_test1.sh"
    shell1=open(Variance_Calling_shell1,"w")
    Variance_Calling_shell2=work_sh+"/Step_10_Variance_Calling_test2.sh"
    shell2=open(Variance_Calling_shell2,"w")
    Variance_Calling_shell3=work_sh+"/Step_10_Variance_Calling_test3.sh"
    shell3=open(Variance_Calling_shell3,"w")



    Variance_Calling_bam_dir=Variance_Calling_dir+'/bam'
    if not os.path.exists(Variance_Calling_bam_dir):
            os.makedirs(Variance_Calling_bam_dir)

    Variance_Calling_snp_dir=Variance_Calling_dir+'/snp'
    if not os.path.exists(Variance_Calling_snp_dir):
            os.makedirs(Variance_Calling_snp_dir)

    Variance_Calling_indel_dir=Variance_Calling_dir+'/indel'
    if not os.path.exists(Variance_Calling_indel_dir):
            os.makedirs(Variance_Calling_indel_dir)

    variant_str=''
    for id in sample_id:
        Variance_Calling_sample_mapping_dir=Variance_Calling_bam_dir+'/'+id
        if not os.path.exists(Variance_Calling_sample_mapping_dir):
            os.makedirs(Variance_Calling_sample_mapping_dir)
        
        mapping_bam=mapping_dir+'/'+id+"/hisat2_sorted.bam"
        cmd0='gatk --java-options "-Djava.io.tmpdir=%s/tmp" AddOrReplaceReadGroups -I %s -O %s/0.hisat2_sorted_with_RG.bam --RGID %s --RGLB %s --RGPL ILLUMINA --RGPU %s --RGSM %s'%(Variance_Calling_sample_mapping_dir,mapping_bam,Variance_Calling_sample_mapping_dir,id,id,id,id)
        cmd1='gatk --java-options "-Djava.io.tmpdir=%s/tmp" MarkDuplicates -I %s/0.hisat2_sorted_with_RG.bam -O %s/1.marked_duplicates.bam  -M %s/1.marked_dup_metrics.txt --REMOVE_DUPLICATES true'%(Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir)
        cmd2='gatk --java-options "-Djava.io.tmpdir=%s/tmp" SplitNCigarReads -R %s -I %s/1.marked_duplicates.bam -O %s/2.SplitNCigarReads.bam'%(Variance_Calling_sample_mapping_dir,Genome_fa,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir)

        if dbsnp.lower() != 'none':
            cmd5='gatk --java-options "-Djava.io.tmpdir=%s/tmp" HaplotypeCaller -R %s -I %s/2.SplitNCigarReads.bam -O %s/5.raw_variants.g.vcf.gz --dbsnp %s -ERC GVCF  --min-base-quality-score 20 --standard-min-confidence-threshold-for-calling 20 '%(Variance_Calling_sample_mapping_dir,Genome_fa,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir,dbsnp)
        else:
            cmd5='gatk --java-options "-Djava.io.tmpdir=%s/tmp" HaplotypeCaller -R %s -I %s/2.SplitNCigarReads.bam -O %s/5.raw_variants.g.vcf.gz            -ERC GVCF  --min-base-quality-score 20 --standard-min-confidence-threshold-for-calling 20 '%(Variance_Calling_sample_mapping_dir,Genome_fa,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir)

        variant_str+='--variant '+Variance_Calling_sample_mapping_dir+'/5.raw_variants.g.vcf.gz '
        
        shell0.write(cmd0+'\n')
        shell1.write(cmd1+'\n')
        shell2.write(cmd2+'\n')
        shell3.write(cmd5+'\n')
    test_cmd0='cat %s |/Data_all/Software/Rush/rush {} -j 10'%(Variance_Calling_shell0)
    test_cmd1='cat %s |/Data_all/Software/Rush/rush {} -j 10'%(Variance_Calling_shell1)
    test_cmd2='cat %s |/Data_all/Software/Rush/rush {} -j 10'%(Variance_Calling_shell2)
    test_cmd3='cat %s |/Data_all/Software/Rush/rush {} -j 10'%(Variance_Calling_shell3)
    shell.write(test_cmd0+'\n'+test_cmd1+'\n'+test_cmd2+'\n'+test_cmd3+'\n')

    shell.write('\n')
    cmd6='gatk CombineGVCFs -R %s %s -O %s/combined.g.vcf'%(Genome_fa,variant_str,Variance_Calling_bam_dir)
    cmd7='gatk GenotypeGVCFs -R %s -V %s/combined.g.vcf -O %s/raw_variants.vcf'%(Genome_fa,Variance_Calling_bam_dir,Variance_Calling_bam_dir)
    #QD < 2.0 || FS > 60.0 || MQ < 40.0
    cmd8="gatk VariantFiltration -R %s -V %s/raw_variants.vcf --filter-expression 'QD < 5.0 || FS > 30.0 || MQ < 50.0' --filter-name 'basic_snp_filter'  -O %s/filtered_variants.vcf"%(Genome_fa,Variance_Calling_bam_dir,Variance_Calling_bam_dir)
    shell.write(cmd6+'\n'+cmd7+'\n'+cmd8+'\n'+'\n')

    shell.write('#all snp indel'+'\n')
    cmd9='gatk SelectVariants  -R %s  -V %s/filtered_variants.vcf  --select-type-to-include SNP  -O  %s/all_sample_snps.vcf'%(Genome_fa,Variance_Calling_bam_dir,Variance_Calling_snp_dir)
    cmd10='gatk VariantsToTable  -V %s/all_sample_snps.vcf -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER -GF GT -GF AD -GF DP -O %s/all_sample_snps_stats.txt'%(Variance_Calling_snp_dir,Variance_Calling_snp_dir)
    cmd11='gatk SelectVariants  -R %s  -V %s/filtered_variants.vcf  --select-type-to-include INDEL -O %s/all_sample_indels.vcf'%(Genome_fa,Variance_Calling_bam_dir,Variance_Calling_indel_dir)
    cmd12='gatk VariantsToTable  -V %s/all_sample_indels.vcf -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER -GF GT -GF AD -GF DP -O %s/all_sample_indels_stats.txt'%(Variance_Calling_indel_dir,Variance_Calling_indel_dir)
    shell.write(cmd9+'\n'+cmd10+'\n'+cmd11+'\n'+cmd12+'\n'+'\n')


    shell.write('#vs snp indel'+'\n')
    for vs in DiffPeak_vs.strip().split(','):
        treat=vs.strip().split('_vs_')[0]
        control=vs.strip().split('_vs_')[1]
        sample_str=''
        for m in group_dict[treat]:
            sample_str+=' -sn '+m
        for n in group_dict[control]:
            sample_str+=' -sn '+n
        cmd13='gatk SelectVariants -R %s -V %s/all_sample_snps.vcf  %s -O %s/%s_snps.vcf'%(Genome_fa,Variance_Calling_snp_dir,sample_str,Variance_Calling_snp_dir,vs)
        cmd14='gatk VariantsToTable  -V %s/%s_snps.vcf -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER -GF GT -GF AD -GF DP -O %s/%s_snps_stats.txt'%(Variance_Calling_snp_dir,vs,Variance_Calling_snp_dir,vs)
        cmd15='gatk SelectVariants -R %s -V %s/all_sample_indels.vcf  %s -O %s/%s_indels.vcf'%(Genome_fa,Variance_Calling_indel_dir,sample_str,Variance_Calling_indel_dir,vs)
        cmd16='gatk VariantsToTable  -V %s/%s_indels.vcf -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER -GF GT -GF AD -GF DP -O %s/%s_indels_stats.txt'%(Variance_Calling_indel_dir,vs,Variance_Calling_indel_dir,vs)
        shell.write(cmd13+'\n'+cmd14+'\n'+cmd15+'\n'+cmd16+'\n')
        shell.write('\n')

    shell.write('#sample snp indel'+'\n')
    for x in sample_id:
        cmd17='gatk SelectVariants -R %s -V %s/all_sample_snps.vcf  -sn %s -O %s/%s_snps.vcf'%(Genome_fa,Variance_Calling_snp_dir,x,Variance_Calling_snp_dir,x)
        cmd18='gatk VariantsToTable  -V %s/%s_snps.vcf -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER -GF GT -GF AD -GF DP -O %s/%s_snps_stats.txt'%(Variance_Calling_snp_dir,x,Variance_Calling_snp_dir,x)
        cmd19='gatk SelectVariants -R %s -V %s/all_sample_indels.vcf  -sn %s -O %s/%s_indels.vcf'%(Genome_fa,Variance_Calling_indel_dir,x,Variance_Calling_indel_dir,x)
        cmd20='gatk VariantsToTable  -V %s/%s_indels.vcf -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER -GF GT -GF AD -GF DP -O %s/%s_indels_stats.txt'%(Variance_Calling_indel_dir,x,Variance_Calling_indel_dir,x)
        shell.write(cmd17+'\n'+cmd18+'\n'+cmd19+'\n'+cmd20+'\n')

"""
        if vcf_known_sites.lower() != 'none':
            vcf_known_sites_str=''
            for i in vcf_known_sites.strip().split(','):
                vcf_known_sites_str+=' --known-sites '+i
            cmd3='gatk --java-options "-Djava.io.tmpdir=%s/tmp" BaseRecalibrator -R %s -I %s/2.SplitNCigarReads.bam %s -O %s/3.recal_data.table'%(Variance_Calling_sample_mapping_dir,Genome_fa,Variance_Calling_sample_mapping_dir,vcf_known_sites_str,Variance_Calling_sample_mapping_dir)
        else:
            cmd3='gatk --java-options "-Djava.io.tmpdir=%s/tmp" BaseRecalibrator -R %s -I %s/2.SplitNCigarReads.bam    -O %s/3.recal_data.table'%(Variance_Calling_sample_mapping_dir,Genome_fa,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir)
        cmd4='gatk --java-options "-Djava.io.tmpdir=%s/tmp" ApplyBQSR -R %s -I %s/2.SplitNCigarReads.bam -bqsr %s/3.recal_data.table -O %s/4.recalibrated.bam'%(Variance_Calling_sample_mapping_dir,Genome_fa,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir,Variance_Calling_sample_mapping_dir)
"""

def Report():
    report_shell=work_sh+"/Step_11_Report.sh"
    shell=open(report_shell,"w")
 
    report=analysis_dir+'/report'
    if not os.path.exists(report):
        os.makedirs(report)
    src_old_dir=bin+'/src'
    src_dir=report+'/src'

    cmd1="cp -rf %s %s"%(src_old_dir,report)
    os.system(cmd1)
    cmd2="cp -rf %s/1.QC/stats/qc_stats.txt  %s/table/"%(analysis_dir,src_dir)
    cmd3="cp -rf %s/2.Mapping/mapping_stats.txt  %s/table/"%(analysis_dir,src_dir)

    if Gene_id_name.lower() !='none':
        cmd4="cat %s/3.GenesExpress/3.Gene_name_all/FPKM.txt |head -n 30 > %s/table/FPKM.txt"%(analysis_dir,src_dir)
        cmd5="cp -rf %s/3.GenesExpress/3.Gene_name_all/FPKM*png  %s/image/ "%(analysis_dir,src_dir)
    else:
        cmd4="cat %s/3.GenesExpress/1.Gene_id/FPKM.txt |head -n 30 > %s/table/FPKM.txt"%(analysis_dir,src_dir)
        cmd5="cp -rf %s/3.GenesExpress/1.Gene_id/FPKM*png  %s/image/ "%(analysis_dir,src_dir)

    cmd6="cat %s/4.DiffGenes/%s/Sig_genes_exprData_merge.txt|head -n 30 >  %s/table/Sig_genes_exprData.txt"%(analysis_dir,Demo_group,src_dir)
    cmd7="cp -rf %s/4.DiffGenes/%s/*png  %s/image/ "%(analysis_dir,Demo_group,src_dir)
    cmd8="cp -rf %s/4.DiffGenes/diffExprGene_stats.txt  %s/table/"%(analysis_dir,src_dir)
    cmd9="cp -rf %s/4.DiffGenes/*png  %s/image/ "%(analysis_dir,src_dir)


    if Gene_id_name.lower() !='none':
        cmd10="cat %s/5.Function_anno/Card_function_id_name_all.txt |head -n 30 > %s/table/Card_function.txt"%(analysis_dir,src_dir)
        cmd11="cat %s/5.Function_anno/CAZy_function_id_name_all.txt |head -n 30 > %s/table/CAZy_function.txt"%(analysis_dir,src_dir)
        cmd12="cat %s/5.Function_anno/COG_function_id_name_all.txt |head -n 30 > %s/table/COG_function.txt"%(analysis_dir,src_dir)
        cmd13="cat %s/5.Function_anno/GO_function_id_name_all.txt |head -n 30 > %s/table/GO_function.txt"%(analysis_dir,src_dir)
        cmd14="cat %s/5.Function_anno/KEGG_function_id_name_all.txt |head -n 30 > %s/table/KEGG_function.txt"%(analysis_dir,src_dir)
        cmd15="cat %s/5.Function_anno/PHI_function_id_name_all.txt |head -n 30 > %s/table/PHI_function.txt"%(analysis_dir,src_dir)
        cmd16="cat %s/5.Function_anno/Uniprot_function_id_name_all.txt |head -n 30 > %s/table/Uniprot_function.txt"%(analysis_dir,src_dir)
        cmd17="cat %s/5.Function_anno/VFDB_function_id_name_all.txt |head -n 30 > %s/table/VFDB_function.txt"%(analysis_dir,src_dir)
        cmd18="cat %s/5.Function_anno/eggNOG_function_id_name_all.txt |head -n 30 > %s/table/eggNOG_function.txt"%(analysis_dir,src_dir)
        cmd19="cat %s/5.Function_anno/NR_function_id_name_all.txt |head -n 30 > %s/table/NR_function.txt"%(analysis_dir,src_dir)
        cmd20="cat %s/5.Function_anno/Pfam_function_id_name_all.txt |head -n 30 > %s/table/Pfam_function.txt"%(analysis_dir,src_dir)
        cmd21="cat %s/5.Function_anno/stats_id_name_all.txt |head -n 30 > %s/table/stats_function.txt"%(analysis_dir,src_dir)

    else:
        cmd10="cat %s/5.Function_anno/Card_function_id.txt |head -n 30 > %s/table/Card_function.txt"%(analysis_dir,src_dir)
        cmd11="cat %s/5.Function_anno/CAZy_function_id.txt |head -n 30 > %s/table/CAZy_function.txt"%(analysis_dir,src_dir)
        cmd12="cat %s/5.Function_anno/COG_function_id.txt |head -n 30 > %s/table/COG_function.txt"%(analysis_dir,src_dir)
        cmd13="cat %s/5.Function_anno/GO_function_id.txt |head -n 30 > %s/table/GO_function.txt"%(analysis_dir,src_dir)
        cmd14="cat %s/5.Function_anno/KEGG_function_id.txt |head -n 30 > %s/table/KEGG_function.txt"%(analysis_dir,src_dir)
        cmd15="cat %s/5.Function_anno/PHI_function_id.txt |head -n 30 > %s/table/PHI_function.txt"%(analysis_dir,src_dir)
        cmd16="cat %s/5.Function_anno/Uniprot_function_id.txt |head -n 30 > %s/table/Uniprot_function.txt"%(analysis_dir,src_dir)
        cmd17="cat %s/5.Function_anno/VFDB_function_id.txt |head -n 30 > %s/table/VFDB_function.txt"%(analysis_dir,src_dir)
        cmd18="cat %s/5.Function_anno/eggNOG_function_id.txt |head -n 30 > %s/table/eggNOG_function.txt"%(analysis_dir,src_dir)
        cmd19="cat %s/5.Function_anno/NR_function_id.txt |head -n 30 > %s/table/NR_function.txt"%(analysis_dir,src_dir)
        cmd20="cat %s/5.Function_anno/Pfam_function_id.txt |head -n 30 > %s/table/Pfam_function.txt"%(analysis_dir,src_dir)
        cmd21="cat %s/5.Function_anno/stats_id.txt |head -n 30 > %s/table/stats_function.txt"%(analysis_dir,src_dir)

    cmd22="cp -rf %s/6.GO_KEGG_Enrichment/%s/Sig_GO_Enrichment.txt  %s/table/"%(analysis_dir,Demo_group,src_dir)
    cmd23="cp -rf %s/6.GO_KEGG_Enrichment/%s/Sig_KEGG_Enrichment.txt  %s/table/"%(analysis_dir,Demo_group,src_dir)
    cmd24="cp -rf %s/6.GO_KEGG_Enrichment/%s/*png  %s/image/ "%(analysis_dir,Demo_group,src_dir)
    Demo_group_Pathway_dir=GO_KEGG_Enrichment_dir+'/'+Demo_group+'/Pathway/*pathway.png'
    cmd25="cp -rf $(ls %s|head -n 1) %s/image/pathway.png"%(Demo_group_Pathway_dir,src_dir)

    cmd26="cp -rf %s/7.PPI/%s/*png  %s/image/ "%(analysis_dir,Demo_group,src_dir)

    cmd27="cp -rf %s/8.GSEA/%s/*png  %s/image/ "%(analysis_dir,Demo_group,src_dir)

    Demo_group_GSEA_GO_dir=GSEA_dir+'/'+Demo_group+'/GO/'
    cmd28="cp -rf $(ls %s/*png|head -n 1) %s/image/GO_GSEA_top1.png"%(Demo_group_GSEA_GO_dir,src_dir)
    Demo_group_GSEA_KEGG_dir=GSEA_dir+'/'+Demo_group+'/KEGG/'
    cmd29="cp -rf $(ls %s/*png|head -n 1) %s/image/KEGG_GSEA_top1.png"%(Demo_group_GSEA_KEGG_dir,src_dir)

    cmd29_0="cat %s/8.GSEA/%s/GO_GSEA_all.txt |head -n 10 >  %s/table/GO_GSEA_all.txt"%(analysis_dir,Demo_group,src_dir)
    cmd29_1="cat %s/8.GSEA/%s/KEGG_GSEA_all.txt |head -n 10 >  %s/table/KEGG_GSEA_all.txt"%(analysis_dir,Demo_group,src_dir)

    cmd30="cat %s/9.rMATS/%s/SE.MATS.JC.txt |head -n 30 > %s/table/SE.MATS.JC.txt"%(analysis_dir,Demo_group,src_dir)
    Demo_group_rMATS_dir=rMATS_dir+'/'+Demo_group+'/Sashimi_plot/'
    cmd31="pdftoppm -png $(ls %s/*pdf|head -n 1) > %s/image/rMATS.png"%(Demo_group_rMATS_dir,src_dir)



    cmd32="cat %s/10.Variance_Calling/snp/all_sample_snps_stats.txt |head -n 30 > %s/table/all_sample_snps_stats.txt"%(analysis_dir,src_dir)
    cmd33="cat %s/10.Variance_Calling/indel/all_sample_indels_stats.txt |head -n 30 > %s/table/all_sample_indels_stats.txt"%(analysis_dir,src_dir)



    shell.write(cmd2+'\n'+cmd3+'\n'+cmd4+'\n'+cmd5+'\n'+cmd6+'\n'+cmd7+'\n'+cmd8+'\n'+cmd9+'\n'+cmd10+'\n'+cmd11+'\n')
    shell.write(cmd12+'\n'+cmd13+'\n'+cmd14+'\n'+cmd15+'\n'+cmd16+'\n'+cmd17+'\n'+cmd18+'\n'+cmd19+'\n'+cmd20+'\n'+cmd21+'\n')
    shell.write(cmd22+'\n'+cmd23+'\n'+cmd24+'\n'+cmd25+'\n'+cmd26+'\n'+cmd27+'\n'+cmd28+'\n'+cmd29+'\n'+cmd29_0+'\n'+cmd29_1+'\n'+cmd30+'\n'+cmd31+'\n')
    shell.write(cmd32+'\n'+cmd33+'\n')
    #project_info.txt
    project_info_txt=src_dir+'/table/project_info.txt'
    project_info=open(project_info_txt,"w")
    project_info.write('合同编号'+'\t'+str(contract_Num)+'\n'+'项目名称'+'\t'+project_Name+'\n'+'分析人员'+'\t'+company_name+'\n'+'报告时间'+'\t'+str(report_Time))

    #sample_info.txt
    sample_info_txt=src_dir+'/table/sample_info.txt'
    sample_info=open(sample_info_txt,"w")


    if rename.lower() == 'true':
        sample_info.write('sample_id'+'\t'+'group'+'\t'+'byzh_id'+'\n')
        for i in dict_rename.keys():
            sample_name=dict_rename[i]
            test_group='-'
            for j in group_dict.keys():
                if sample_name in group_dict[j]:
                    test_group=j
                    
            sample_info.write(sample_name+'\t'+test_group+'\t'+i+'\n')

    else:
        sample_info.write('sample_id'+'\t'+'group'+'\n')
        for i in sample_id:
            test_group='-'
            for j in group_dict.keys():
                if i in group_dict[j]:
                    test_group=j
            sample_info.write(i+'\t'+test_group+'\n')

    report_py=bin+'/report.py'
    report_Rmd_old=bin+'/report.Rmd'
    report_Rmd=report+'/report.Rmd'
    cmd34='python %s %s %s %s %s %s '%(report_py,report_Rmd_old,Demo_sample,Demo_group,version,report_Rmd)
    shell.write(cmd34+'\n')
    rmarkdown_R=bin+'/rmarkdown.R'
    report_html=report+'/report.html'
    cmd35='%s  %s --infile %s --outfile %s  --format html_document'%(Rscript,rmarkdown_R,report_Rmd,report_html)
    shell.write(cmd35)

def Result():
    result_shell=work_sh+"/Step_12_Result.sh"
    shell=open(result_shell,"w")
    result_dir=analysis_dir+'/result/'
    if not os.path.exists(result_dir):
        os.makedirs(result_dir)
    cmd1='mkdir %s/1.QC  %s/2.Mapping   %s/3.GenesExpress   %s/9.Variance_Calling %s/report '%(result_dir,result_dir,result_dir,result_dir,result_dir)
    cmd2='ln -s %s/1.QC/raw %s/1.QC/raw'%(analysis_dir,result_dir)
    cmd3='ln -s %s/1.QC/clean %s/1.QC/clean'%(analysis_dir,result_dir)
    cmd4='ln -s %s/1.QC/stats %s/1.QC/stats'%(analysis_dir,result_dir)

    cmd5='ln -s %s/3.GenesExpress/1.Gene_id %s/3.GenesExpress/1.Gene_id'%(analysis_dir,result_dir)
    shell.write(cmd1+'\n'+cmd2+'\n'+cmd3+'\n'+cmd4+'\n'+cmd5+'\n')
    if Gene_id_name.lower() !='none':
        cmd6='ln -s %s/3.GenesExpress/2.Gene_name_part %s/3.GenesExpress/2.Gene_name_part'%(analysis_dir,result_dir)
        cmd7='ln -s %s/3.GenesExpress/3.Gene_name_all %s/3.GenesExpress/3.Gene_name_all'%(analysis_dir,result_dir)
        shell.write(cmd7+'\n')
    cmd8='cp -rf  %s/4.DiffGenes %s/'%(analysis_dir,result_dir)
    cmd9='cd  %s/4.DiffGenes/ &&  rm -rf *input.txt  */control.txt */treat.txt  */gfold.diff*   */sample_info.txt  */tmp*   */COUNT.txt */heatmap_input.txt '%(result_dir)

    cmd10='ln -s %s/5.Function_anno %s/5.Function_anno'%(analysis_dir,result_dir)
    cmd11='cp -rf  %s/6.GO_KEGG_Enrichment %s/'%(analysis_dir,result_dir)
    cmd12='cd %s/6.GO_KEGG_Enrichment/ && rm -rf GO_function*  KEGG_function* */*input.txt ' %(result_dir)

    #cmd13='cp -rf  %s/7.PPI %s/'%(analysis_dir,result_dir)
    #cmd14='cd %s/7.PPI && rm -rf */ppi_input.txt'%(result_dir)

    cmd15='ln -s  %s/8.GSEA %s/7.GSEA'%(analysis_dir,result_dir)

    shell.write(cmd8+'\n'+cmd9+'\n'+cmd10+'\n'+cmd11+'\n'+cmd12+'\n'+cmd15+'\n')

    for vs in DiffPeak_vs.strip().split(','):
        vs_dir=rMATS_dir+'/'+vs+'/'
        rMATS_vs_dir=result_dir+'/8.rMATS/'+vs
        if not os.path.exists(rMATS_vs_dir):
            os.makedirs(rMATS_vs_dir)
        cmd16='cp -rf  %s/SE.MATS.JC.txt %s/'%(vs_dir,rMATS_vs_dir)
        cmd17='cp -rf  %s/Sashimi_plot %s/'%(vs_dir,rMATS_vs_dir)
        shell.write(cmd16+'\n'+cmd17+'\n')

    cmd18='cp -rf  %s/10.Variance_Calling/indel  %s/9.Variance_Calling'%(analysis_dir,result_dir)
    cmd19='cp -rf  %s/10.Variance_Calling/snp  %s/9.Variance_Calling'%(analysis_dir,result_dir)
    shell.write(cmd18+'\n'+cmd19+'\n')
    for id in sample_id:
        bam=Variance_Calling_dir+'/bam/'+id+'/1.marked_duplicates.bam'
        new_bam=result_dir+'/2.Mapping/'+id+'.bam'
        cmd20='ln -s %s %s'%(bam,new_bam)
        shell.write(cmd20+'\n')
    cmd21='cp -rf %s/2.Mapping/mapping_stats.txt %s/2.Mapping/'%(analysis_dir,result_dir)

    cmd22='ln -s %s/report/report.html  %s/report/report.html'%(analysis_dir,result_dir)
    cmd23='ln -s %s/report/src  %s/report/src'%(analysis_dir,result_dir)
    shell.write(cmd21+'\n'+cmd22+'\n'+cmd23+'\n')

    
    cmd24='cp -rf %s/txt2xlsx*  %s/' %(bin,work_sh)
    cmd25='cd %s && bash txt2xlsx.sh '%(work_sh)
    shell.write(cmd24+'\n'+cmd25+'\n')


if __name__=='__main__':
    Qc()
    Mapping()
    GenesExpress()
    DiffGenes()
    Function_anno()
    GO_KEGG_Enrichment()
    PPI()
    GSEA()
    rMATS()
    Variance_Calling()
    Report()
    Result()

    
