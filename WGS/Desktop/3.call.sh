## Generate bam list
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort -maxdepth 1 -name "*_sort.bam" -not -empty > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/variant/cm_bam.list

## Call variants per-chromosome
cut -f 1 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm_wgs_calling.bed | uniq | while read chr
do
	chr_vcf="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/variant/cm_${chr}.vcf.gz"
	if [ ! -s "${chr_vcf}" ]
	then
		echo "/data1/software/bcftools/1.12/bin/bcftools mpileup -b /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/variant/cm_bam.list -f /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa -C 50 -d 250 -q 20 -Q 20 -a FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/QS,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR -L 250 -m 1 -F 0.002 -p -P ILLUMINA -O u -r ${chr} | /data1/software/bcftools/1.12/bin/bcftools call -a FORMAT/GQ,FORMAT/GP,INFO/PV4 -v -m -O z -o ${chr_vcf}"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/mpileup_call.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/mpileup_call.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/mpileup_call.rush --verbose

## Generate vcf list
cut -f 1 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm_wgs_calling.bed | uniq | sort -h | while read chr
do
	chr_vcf="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/variant/cm_${chr}.vcf.gz"
	if [ -s "${chr_vcf}" ]
	then
		echo "${chr_vcf}"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/variant/cm_vcf.list

## Multiqc for snp stats
/data1/software/miniconda3/envs/Python-3.9/bin/multiqc --force --filename cm_multiqc_snp --config /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/multiqc_config.yaml --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_stats.txt

## Extract results from bcftools stats
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/bcftools_stats.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats --prefix cm

## Bar plot of SNP Substitution Type
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_type.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats --prefix cm_snp_type --xcol "#Type" --ycol "Count" --limit 0 --xscale 0 --xlab "Substitution Type" --ylab "Count" --title "SNP" --height 6 --width 8

## Bar plot of SNP PSC
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/dodge_barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_psc.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats --prefix cm_snp_psc --xcol "#Sample_ID" --ycol "HomRef,Het,HomAlt" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "SNP" --height 6 --width 8

## SNP density
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/variant_density.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/cm_snp_genotype.txt --chrlen /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa.len --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats/cm_snp_density.txt --window 1000

## Bar plot of SNP distribution
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/variant_distribution_barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/cm_snp_genotype.txt --chrlen /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa.len --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/snp/stats --prefix cm_snp_distribution --xcol 1 --ycol 2 --window 1000 --limit 0 --xscale 5 --title "SNP" --height 6 --width 10

## Multiqc for indel stats
/data1/software/miniconda3/envs/Python-3.9/bin/multiqc --force --filename cm_multiqc_indel --config /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/multiqc_config.yaml --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_stats.txt

## Extract results from bcftools stats
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/bcftools_stats.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats --prefix cm

## Bar plot of InDel Length
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/indel_length_barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_length.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats --prefix cm_indel_length --xcol "#Length" --ycol "Count" --xlab "Length" --ylab "Count" --title "InDel" --height 6 --width 8

## Bar plot of InDel PSC
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/dodge_barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_psc.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats --prefix cm_indel_psc --xcol "#Sample_ID" --ycol "HomRef,InsHet,DelHet,InsHomAlt,DelHomAlt" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "InDel" --height 6 --width 8

## InDel density
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/variant_density.pl --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/cm_indel_genotype.txt --chrlen /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa.len --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats/cm_indel_density.txt --window 1000

## Bar plot of InDel distribution
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/variant_distribution_barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/cm_indel_genotype.txt --chrlen /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa.len --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/indel/stats --prefix cm_indel_distribution --xcol 1 --ycol 2 --window 1000 --limit 0 --xscale 5 --title "InDel" --height 6 --width 10

## SV calling by DELLY2
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/variant/cm_bam.list | while read line
do
	name=$(basename ${line})
	sm=${name%_*}
	call_bcf="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/call/${sm}_call.bcf"
	call_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/call/${sm}_call.log"
	if [ ! -s "${call_bcf}" ]
	then
		if [ -s "/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm_wgs_exclude.bed" ]
		then
			echo "/data1/software/delly/0.8.7/bin/delly call -t ALL -g /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa -x /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm_wgs_exclude.bed -q 20 -s 15 -o ${call_bcf} ${line} >${call_log} 2>&1"
		else
			echo "/data1/software/delly/0.8.7/bin/delly call -t ALL -g /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa -q 20 -s 15 -o ${call_bcf} ${line} >${call_log} 2>&1"
		fi
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/sv_call.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/sv_call.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 1 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/sv_call.rush --verbose

## SV BCF to SV VCF
/data1/software/bcftools/1.12/bin/bcftools view -f "PASS" -e 'INFO/IMPRECISE=1' -T /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm_wgs_calling.bed -O z -o /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/cm_sv.vcf.gz /NouvSight001_RPC2024001_call.bcf

## SV Properties
/data1/software/svprops/svprops/src/svprops /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/cm_sv.vcf.gz > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_props_stats.txt

## SV Sample Properties
/data1/software/svprops/svprops/src/sampleprops /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/cm_sv.vcf.gz > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_sample_stats.txt

## SV stats
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/delly_stats.pl --svprops /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_props_stats.txt --smprops /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_sample_stats.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv --prefix cm

## Bar plot of SV type
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_type.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats --prefix cm_sv_type --xcol "#Type" --ycol "Count" --limit 0 --xscale 0 --xlab "Type" --ylab "Count" --title "SV" --height 6 --width 8

## Bar plot of SV PSC
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/dodge_barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats/cm_sv_psc.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/sv/stats --prefix cm_sv_psc --xcol "#Sample_ID" --ycol "HomRef,Het,HomAlt" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "SV" --height 6 --width 8

## Call CNVs
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/variant/cm_bam.list | while read line
do
	name=$(basename ${line})
	sm=${name%_*}
	
	tree_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}_tree.log"
	his_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}_his.log"
	stat_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}_stat.log"
	partition_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}_partition.log"
	call_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}_call.log"

	root="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}.root"
	cnv_out="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}_cnvnator.txt"
	
	if [ ! -s "${cnv_out}" ]
	then
		echo "/data1/software/cnvnator/0.4.1/bin/cnvnator -root ${root} -tree ${line} -chrom 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9 X Y >${tree_log} 2>&1 && /data1/software/cnvnator/0.4.1/bin/cnvnator -root ${root} -his 100 -chrom 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9 X Y -d /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/split >${his_log} 2>&1 && /data1/software/cnvnator/0.4.1/bin/cnvnator -root ${root} -stat 100 -chrom 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9 X Y >${stat_log} 2>&1 && /data1/software/cnvnator/0.4.1/bin/cnvnator -root ${root} -partition 100 -chrom 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9 X Y >${partition_log} 2>&1 && /data1/software/cnvnator/0.4.1/bin/cnvnator -root ${root} -call 100 -chrom 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9 X Y > ${cnv_out} 2>${call_log}"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_call.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_call.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 1 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_call.rush --verbose

find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root -maxdepth 1 -name "*_cnvnator.txt" -not -empty | while read line
do
	name=$(basename ${line})
	sm=${name%_*}
	cnv_out="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/root/${sm}_cnvnator.txt"
	cnv_call="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/call/${sm}_cnv_call.txt"

	if [ -s "${cnv_out}" ] && [ ! -s "${cnv_call}" ]
	then
		echo "/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/cnvnator_filter.pl --infile ${cnv_out} --outfile ${cnv_call} --bed /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm_wgs_calling.bed --evalue 0.01 --quality 0.5 --minsize 1000 --maxsize 1000000"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_filter.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_filter.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 1 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/cnv_filter.rush --verbose

## CNV stats
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/cnvnator_stats.pl --indir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/call --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/stats/cm_cnv_psc.txt

## Bar plot of CNV PSC
/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/dodge_barplot.R --infile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/stats/cm_cnv_psc.txt --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/3.Calling/cnv/stats --prefix cm_cnv_psc --xcol "#Sample_ID" --ycol "Deletion,Duplication" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "CNV" --height 6 --width 8
