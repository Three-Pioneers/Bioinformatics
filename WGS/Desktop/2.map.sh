## Map to Reference and Mark Duplicates and Sort SAM by coordinate to BAM
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data -maxdepth 1 -name "*_clean_R1.f*q*" -not -empty | while read R1
do
	name=$(basename $R1)
	sm=${name%_*_*}
	R2=$(echo $R1 | sed 's/_clean_R1\.f/_clean_R2\.f/')
	rg="@RG\tID:${sm}\tSM:${sm}\tLB:WGS\tPL:ILLUMINA"
	bwamem_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort/${sm}_bwamem.log"
	markdup_metrics="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort/${sm}_markdup.metrics"
	sormadup_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort/${sm}_sormadup.log"
	sormadup_tmp="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort/${sm}_sormadup"
	sort_bam="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort/${sm}_sort.bam"
	sort_bai="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort/${sm}_sort.bai"
	if [ ! -s "${sort_bam}" ]
	then
		echo "/data1/software/bwa-mem2/2.2.1/bwa-mem2 mem -t 20 -Y -M -R \"${rg}\" /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa ${R1} ${R2} 2>${bwamem_log} | /data1/software/samtools/1.12/bin/samtools view -bS |/data1/software/samtools/1.12/bin/samtools sort -m 2G -O BAM -o ${sort_bam} --threads 20 && /data1/software/samtools/1.12/bin/samtools index -b ${sort_bam}"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/sort.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/sort.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 1 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/sort.rush --verbose



## Multiqc for bamsormadup
/data1/software/miniconda3/envs/Python-3.9/bin/multiqc --force --filename cm_multiqc_markdup --config /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/multiqc_config.yaml --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/stats /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort/*_markdup.metrics

## Evaluate NGS mapping using qualimap's bamqc
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/sort -maxdepth 1 -name "*_sort.bam" -not -empty | while read line
do
	name=$(basename ${line})
	sm=${name%_*}
	bamqc_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/bamqc/${sm}_bamqc.log"
	bamqc_html="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/bamqc/${sm}_bamqc/qualimapReport.html"
	if [ ! -s "${bamqc_html}" ]
	then
		echo "/data1/software/qualimap/2.2.2/qualimap bamqc -bam ${line} -outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/bamqc/${sm}_bamqc -nt 40 -outformat HTML --java-mem-size=50G --java-io-tmpdir=/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/tmp >${bamqc_log} 2>&1"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/bamqc.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/bamqc.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 1 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/bamqc.rush --verbose

## Multiqc for bamqc
/data1/software/miniconda3/envs/Python-3.9/bin/multiqc --force --filename cm_multiqc_bamqc --config /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/multiqc_config.yaml --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/stats /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/bamqc/*_bamqc

## Stats of mapping
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/qualimap_stats.pl --indir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/bamqc --outfile /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/2.Mapping/stats/cm_mapping_stats.txt
