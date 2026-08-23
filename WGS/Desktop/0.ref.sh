## Split sequences into files by name ID
cut -f 1 /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm_wgs_calling.bed | uniq | while read chr
do
	chr_fa="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/split/${chr}.fa"
	if [ ! -s "${chr_fa}" ]
	then
		echo "/data1/software/ucsc/faOneRecord /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/0.Reference/cm.fa ${chr} > ${chr_fa}"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/ref_split.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/ref_split.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/ref_split.rush --verbose

