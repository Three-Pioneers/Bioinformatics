## SNP anno stats
perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/annovar_stats.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/cm_snp_anno.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats --prefix cm_snp

## Pie plot of SNP function stats
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/pieplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats/cm_snp_function_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats --prefix cm_snp_function_stats --xcol "#Func_refGene" --ycol "Count" --limit 0 --title "SNP Function" --height 6 --width 8

## Pie plot of SNP exonic function stats
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/pieplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats/cm_snp_exonic_function_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/snp/stats --prefix cm_snp_exonic_function_stats --xcol "#ExonicFunc_refGene" --ycol "Count" --limit 0 --title "SNP Exonic Function" --height 6 --width 8

## InDel anno stats
perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/annovar_stats.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/cm_indel_anno.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats --prefix cm_indel

## Pie plot of InDel function stats
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/pieplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats/cm_indel_function_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats --prefix cm_indel_function_stats --xcol "#Func_refGene" --ycol "Count" --limit 0 --title "InDel Function" --height 6 --width 8

## Pie plot of InDel exonic function stats
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/pieplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats/cm_indel_exonic_function_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/indel/stats --prefix cm_indel_exonic_function_stats --xcol "#ExonicFunc_refGene" --ycol "Count" --limit 0 --title "InDel Exonic Function" --height 6 --width 8

## Convert SV into ANNOVAR input format
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/sv_to_avinput.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/cm_sv_call.txt --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/cm_sv.avinput

## Annotate SV using ANNOVAR
/data1/software/perl/5.30.0/bin/perl /data1/software/annovar/2020-06-08/table_annovar.pl --buildver cm --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/cm_sv --protocol refGene --operation g --nastring - --thread 40 --maxgenethread 40 --dot2underline --remove /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/cm_sv.avinput /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/ANNOVAR

## SV anno stats
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/annovar_stats.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/cm_sv_anno.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/stats --prefix cm_sv

## Pie plot of SV function stats
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/pieplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/stats/cm_sv_function_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/sv/stats --prefix cm_sv_function_stats --xcol "#Func_refGene" --ycol "Count" --limit 0 --title "SV Function" --height 6 --width 8

## Convert CNV into ANNOVAR input format
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/call -maxdepth 1 -name "*_cnv_call.txt" -not -empty | while read line
do
	name=$(basename ${line})
	sm=${name%_*_*}
	cnv_avinput="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/avinput/${sm}_cnv.avinput"
	if [ -s "${line}" ] && [ ! -s "${cnv_avinput}" ]
	then
		echo "/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/cnv_to_avinput.pl --infile ${line} --outfile ${cnv_avinput}"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_avinput.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_avinput.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_avinput.rush --verbose

## Annotate CNV using ANNOVAR
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/avinput -maxdepth 1 -name "*_cnv.avinput" -not -empty | while read line
do
	name=$(basename ${line})
	sm=${name%_*}
	cnv_anno="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/anno/${sm}_cnv_anno.txt"
	if [ -s "${line}" ] && [ ! -s "${cnv_anno}" ]
	then
		echo "/data1/software/perl/5.30.0/bin/perl /data1/software/annovar/2020-06-08/table_annovar.pl --buildver cm --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/anno/${sm}_cnv --protocol refGene --operation g --nastring - --dot2underline --remove ${line} /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/ANNOVAR"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_anno.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_anno.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_anno.rush --verbose

## CNV anno stats
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/anno -maxdepth 1 -name "*_cnv_anno.txt" -not -empty | while read line
do
	name=$(basename ${line})
	sm=${name%_*_*}
	cnv_function_stats="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/stats/${sm}_cnv_function_stats.txt"
	if [ -s "${line}" ] && [ ! -s "${cnv_function_stats}" ]
	then
		echo "/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/annovar_stats.pl --infile ${line} --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/stats --prefix ${sm}_cnv"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_stats.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_stats.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_stats.rush --verbose

## Pie plot of CNV function stats
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/stats -maxdepth 1 -name "*_cnv_function_stats.txt" -not -empty | while read line
do
	name=$(basename ${line})
	sm=${name%_*_*_*}
	if [ -s "${line}" ]
	then
		echo "/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/pieplot.R --infile ${line} --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/4.Annotation/cnv/stats --prefix ${sm}_cnv_function_stats --xcol \"#Func_refGene\" --ycol \"Count\" --limit 0 --title \"${sm} CNV Function\" --height 6 --width 8"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_pieplot.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_pieplot.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_pieplot.rush --verbose
