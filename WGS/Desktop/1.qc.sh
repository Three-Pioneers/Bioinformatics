## Read BYZH ID and Sample Name
declare -A rename
while read line
do
	OLD_IFS="$IFS"
	IFS=$'\t'
	var=(${line})
	IFS="${OLD_IFS}"
	rename["${var[1]}"]="${var[0]}"
done < /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/config/rename.txt

## Convert BYZH ID to Sample Name
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/data -maxdepth 1 -name "*f*q*" -not -empty | while read line
do
	name=$(basename ${line})
	sm=$(echo $name | sed 's/^.*-\?\(WR[0-9]\+[A-Z]\+\)-\?.*_.*\([1-2]\)\.f.*q.*$/\1/g')
	pe=$(echo $name | sed 's/^.*-\?\(WR[0-9]\+[A-Z]\+\)-\?.*_.*\([1-2]\)\.f.*q.*$/\2/g')

	if [ -z "${rename["${sm}"]}" ]
	then
		sm=$(echo $name | sed 's/^\(.*\)_R\?\([1-2]\)\.f.*q.*$/\1/g')
		pe=$(echo $name | sed 's/^\(.*\)_R\?\([1-2]\)\.f.*q.*$/\2/g')
	fi
	
	new_sm="${rename["${sm}"]}"
	new_pe="R${pe}"
	link="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/raw_data/${new_sm}_${new_pe}.fq.gz"
	
	if [ -n "${new_sm}" ]
	then
		echo "ln -sf ${line} ${link}"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/link.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/link.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/link.rush --verbose

## Quality Control for PE data using fastp
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/raw_data -maxdepth 1 -name "*_R1.f*q*" -not -empty | while read R1
do
	name=$(basename ${R1})
	sm=${name%_*}
	R2=$(echo ${R1} | sed 's/_R1\.f/_R2\.f/')
	clean_R1="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/${sm}_clean_R1.fq.gz"
	clean_R2="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/clean_data/${sm}_clean_R2.fq.gz"
	fastp_json="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/fastp/${sm}_fastp.json"
	fastp_html="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/fastp/${sm}_fastp.html"
	fastp_log="/Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/fastp/${sm}_fastp.log"
	report_title="${sm} Fastp Report"
	if [ ! -s "${clean_R1}" ] || [ ! -s "${clean_R2}" ] || [ ! -s "${fastp_json}" ]
	then
		echo "/data1/software/fastp/0.23.1/fastp --in1 ${R1} --in2 ${R2} --out1 ${clean_R1} --out2 ${clean_R2} --cut_front --cut_front_window_size 1 --cut_front_mean_quality 3 --cut_tail --cut_tail_window_size 1 --cut_tail_mean_quality 3 --qualified_quality_phred 15 --unqualified_percent_limit 40 --n_base_limit 5 --adapter_fasta /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/adapter/PE_adapter.fa --correction --trim_poly_g --overlap_len_require 10 --overlap_diff_limit 5 --overlap_diff_percent_limit 20 --length_required 36 --thread 16 --compression 6 --json ${fastp_json} --html ${fastp_html} --report_title \"${report_title}\" >${fastp_log} 2>&1"
	fi
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/fastp.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/fastp.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 1 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/fastp.rush --verbose

## Multiqc for fastp
/data1/software/miniconda3/envs/Python-3.9/bin/multiqc --force --filename cm_multiqc_fastp --config /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/multiqc_config.yaml --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/fastp/*_fastp.json

## Stats of Quality Control
/data1/software/perl/5.30.0/bin/perl /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/fastp_stats.pl --indir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/fastp --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats --prefix cm

## Split trimming data
sed '1d' /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats/cm_trim_stats.txt | cut -f 1 | while read line
do
	echo "/data1/software/csvtk/0.22.0/csvtk grep -C '$' -t -T -f 1 -p ${line} /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/stats/cm_trim_stats.txt > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/tmp/${line}_trim_stats.txt"
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/csvtk_grep.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/csvtk_grep.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/csvtk_grep.rush --verbose

## Pie plot of trimming data
find /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/tmp -maxdepth 1 -name "*_trim_stats.txt" -not -empty | while read line
do
	echo "/data1/software/miniconda3/envs/R-3.6/bin/Rscript /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/bin/trim_pieplot.R --infile ${line} --outdir /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/1.QualityControl/trim --height 6 --width 8"
done > /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/trim_pieplot.sh
cat /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/trim_pieplot.sh | /data1/software/rush/0.4.2/rush {} -n 1 -j 40 -c -C /Databackup2/2025_05/ZhuYaSha_1_human_reseq/2/analysis/work_sh/trim_pieplot.rush --verbose
