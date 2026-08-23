## Raw Data MD5
if [ ! -s "/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/raw_data/rawdata_md5.txt" ]
then
	md5sum /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/raw_data/*f*q* | awk -F"/" '{print $1,$NF}' | awk '{print $1,$NF}' > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/raw_data/rawdata_md5.txt
fi

## Clean Data MD5
if [ ! -s "/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/cleandata_md5.txt" ]
then
	md5sum /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/*f*q* | awk -F"/" '{print $1,$NF}' | awk '{print $1,$NF}' > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/cleandata_md5.txt
fi

## 1.QualityControl
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/info
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/config/cm_project_info.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/info/cm_project_info.txt
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/cm_sample_info.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/info/cm_sample_info.txt
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/raw_data
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/raw_data/*f*q* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/raw_data
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/raw_data/rawdata_md5.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/raw_data
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/clean_data
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/*f*q* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/clean_data
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/cleandata_md5.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/clean_data
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/fastp
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/fastp/*fastp.html /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/fastp
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/trim
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/trim/* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/trim
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats/*stats.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats/*.html /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/1.QualityControl/stats

## 2.Mapping
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping
cp -r /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/bamqc /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping
rm /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping/bamqc/*_bamqc.log
rm /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping/bamqc/*_bamqc/genome_results.txt
rm -r /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping/bamqc/*_bamqc/raw_data_qualimapReport
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/stats/*stats.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/stats/*.html /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/2.Mapping/stats

## 3.Calling
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling
### SNP
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/cm_snp.vcf.gz /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/cm_snp_genotype.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/*_snp_density* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/*_snp_distribution* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/*_snp_psc* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/*_snp_type* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/snp/stats
### InDel
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/cm_indel.vcf.gz /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/cm_indel_genotype.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/*_indel_density* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/*_indel_distribution* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/*_indel_psc* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/*_indel_length* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/indel/stats
### SV
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/sv
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/cm_sv.vcf.gz /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/sv
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/cm_sv_call.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/sv
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/sv/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/*_sv_psc* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/sv/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/*_sv_type* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/sv/stats
### CNV
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/cnv
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/cnv/call
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/call/*_cnv_call.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/cnv/call
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/cnv/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/stats/*_cnv_psc* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/3.Calling/cnv/stats

## 4.Annotation
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation
### SNP
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/snp
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/cm_snp_anno.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/snp
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/snp/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats/*_snp_function_stats* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/snp/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats/*_snp_exonic_function_stats* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/snp/stats
### InDel
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/indel
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/cm_indel_anno.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/indel
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/indel/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats/*_indel_function_stats* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/indel/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats/*_indel_exonic_function_stats* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/indel/stats
### SV
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/sv
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/cm_sv_anno.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/sv
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/sv/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/stats/*_sv_function_stats* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/sv/stats
### CNV
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/cnv
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/cnv/anno
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/anno/*_cnv_anno.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/cnv/anno
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/cnv/stats
ln -sf /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/stats/*_cnv_function_stats* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/4.Annotation/cnv/stats

## 5.Report
mkdir -p /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/5.Report
cp -r /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/5.Report
rm /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/5.Report/report.Rmd
rm /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/5.Report/*variable.txt
rm -r /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/5.Report/src/bib
rm -r /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19/5.Report/src/table

## Readme
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/src/table/Readme.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/6.Result/人源细胞全基因组致病性位点检测_2025-05-19
