## Copy image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/src/image/* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/trim/NouvSight001_RPC2024001_trim.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_psc.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_type.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_distribution.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_psc.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_length.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_distribution.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_psc.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_type.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/stats/cm_cnv_psc.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats/cm_snp_function_stats.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats/cm_snp_exonic_function_stats.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats/cm_indel_function_stats.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats/cm_indel_exonic_function_stats.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/stats/cm_sv_function_stats.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/stats/NouvSight001_RPC2024001_cnv_function_stats.png /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image

## Thumbnails
ls /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image/*.png | while read line
do
	name=$(basename ${line})
	convert -resize 150x100 ${line} /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/image/thumb/${name}
done

## Copy table
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/src/table/* /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/config/cm_project_info.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_project_info.txt
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/cm_sample_info.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_sample_info.txt
/data1/software/pigz/2.4/pigz -dc /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/NouvSight001_RPC2024001_clean_R1.fq.gz | head -4 > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/fastq_format.txt
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats/cm_trim_stats.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats/cm_qc_stats.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/stats/cm_mapping_stats.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/cm_snp_genotype.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_snp_genotype.txt
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_psc.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_density.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/cm_indel_genotype.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_indel_genotype.txt
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_psc.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_density.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/cm_sv_call.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_sv_call.txt
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_psc.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/call/NouvSight001_RPC2024001_cnv_call.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/NouvSight001_RPC2024001_cnv_call.txt
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/stats/cm_cnv_psc.txt /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/cm_snp_anno.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_snp_anno.txt
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/cm_indel_anno.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_indel_anno.txt
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/cm_sv_anno.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/cm_sv_anno.txt
head -51 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/anno/NouvSight001_RPC2024001_cnv_anno.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/table/NouvSight001_RPC2024001_cnv_anno.txt

## Copy html
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/fastp/NouvSight001_RPC2024001_fastp.html /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/html
cp -r /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/bamqc/NouvSight001_RPC2024001_bamqc /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/html
rm /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/html/NouvSight001_RPC2024001_bamqc/genome_results.txt
rm -r /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/html/NouvSight001_RPC2024001_bamqc/raw_data_qualimapReport
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats/cm_multiqc_fastp.html /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/html
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/stats/cm_multiqc_bamqc.html /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/html

## Copy bibliography
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/src/bib/reference.bib /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/src/bib

## Copy R Markdown
cp /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/src/rmarkdown/report.Rmd /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/report.Rmd

## Replace variable in R Markdown
while read line
do
	OLD_IFS="$IFS"
	IFS=$'\t'
	var=(${line})
	IFS="${OLD_IFS}"
	sed -i "s/${var[0]}/${var[1]}/g" /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/report.Rmd
done < /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/report_variable.txt

## R Markdown to HTML
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/rmarkdown.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/report.Rmd --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/5.Report/report.html --format html_document
