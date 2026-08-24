#!/usr/bin/env bash

#set -euxo pipefail
set -eo pipefail

# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# set -u or set -o nounset # treat unset variables as an error
# set -x or set -o xtrace # expands variables and prints a little + sign before the line
# set -e or set -o errexit # exit immediately if a pipeline, a list, or a compound command returns a non-zero status
# set -o pipefail # if set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully
# set -v or set -o verbose # print shell input lines as they are read

#####################################################################
# Description and Change History
#####################################################################
: << !
Change History：
	(v1.8) Thu, 01 Apr 2021
		* Update third-party software
		* Update scripts
		* Add insert size
		* Add rawdata md5 and cleandata md5
		* Use bamsormadup instead of samblaster + bamsort

	(v1.7) Thu, 03 Dec 2020
		* Use BWA-MEM2 instead of BWA
		* Update third-party software
		* Adjust the order of output directories
		* Update variable name

	(v1.6) Mon, 28 Sep 2020
		* Modify the fastp options
		* Modify the content of the report
		* Modify the bar chart of Variants PSC

	(v1.5) Tue, 08 Sep 2020
		* Use find + xargs instead of ls
		* Auto set server resource
		* Add CNV filter and CNV stats
		* Use bcftools query instead of convert2annovar for snp
		* Change 7.Backup
	
	(v1.4) Thu, 16 Jul 2020
		* Update third-party software
		* Add WGS calling bed
		* Change exclude expression
		* Change SV filter
	
	(v1.3) Wed, 10 Jun 2020
		* Change fastp's options
		* Set multiqc config
		* Split trim stats for drawing in parallel
		* Call variants per-chromosome, producing separate VCF files per-chromosome
		* Merge VCF files per-chromosome using bcftools concat
		* Extract fields from VCF file using translated genotype
		* Add exclude BED for SV calling
		* Add exclude BED for CNV filtering
	
	(v1.2) Tue, 05 May 2020
		* Fix the bug: copy report file in 7.Backup
		* Update third-party software (see config)
		* Use rush for executing jobs in parallel
		* Check whether the result had been generated before generate new command
	
	(v1.1) Wed, 08 Jan 2020
		* Check if 2.ref.sh exists
		* GFF and GTF are optional, but must provide one of them
		* SV calling and filter only one sample (https://github.com/dellytools/delly/issues/177)
		* Fix the bug: x axis scale in R scripts
		* Fix the bug: regular expression in cnvnator_stats.pl
		* Remove MultiQC BamQC in Report and Backup (https://github.com/ewels/MultiQC/issues/1082)
	
	(v1.0) Tue, 31 Dec 2019
		* The first version
		* This shell is only tested for CentOS Linux 7 (Core)
		* This requires GNU getopt.
		* I do not issue any guarantee that this will work for you

Copyright © 2019 - 2021 Baiqi Fu. All Rights Reserved.
!
#####################################################################

#####################################################################
# Script information
#####################################################################
Script_Description="This function performs Whole Genome Re-sequencing (Non-human species)"

Script_Name="${BASH_SOURCE[0]}"

Script_File=$(readlink -f ${BASH_SOURCE[0]})

SOURCE="${BASH_SOURCE[0]}"

# resolve ${SOURCE} until the file is no longer a symlink
while [ -h "${SOURCE}" ]
do
	DIR=$(cd -P $(dirname ${SOURCE}) && pwd)
	SOURCE=$(readlink ${SOURCE})
	[[ "${SOURCE}" != "/*" ]] && SOURCE="${DIR}/${SOURCE}"
	# if ${SOURCE} was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# ScriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
Script_Dir=$(cd -P $(dirname ${SOURCE}) && pwd)

Script_Version="v1.8"

Script_Author="Baiqi Fu"

Script_Date="Thu, 01 Apr 2021"
#####################################################################

#####################################################################
# Usage
#####################################################################
function usage()
{
	cat << EOF

Script:
	${Script_Name}
	
Description:
	${Script_Description}
	
Version:
	${Script_Version}
	
Author:
	${Script_Author}
	
Date:
	${Script_Date}

Usage:
	bash ${Script_Name} [options] ...

Options:
	---------------Required Arguments---------------
	-i, --config   <File>   the configuration file
	-o, --outdir   <Path>   the output directory
	
	---------------Optional Arguments---------------
	-h, --help              help document
	
Exit status:
	0   if OK,
	!=0 if serious problems.
	
Example:
	1) Use short options:
	$  bash ${Script_Name} -i reseq.cfg -o analysis
	
	2) Use long options:
	$  bash ${Script_Name} --config reseq.cfg --outdir analysis

EOF
}
#####################################################################

#####################################################################
# Getopt
#####################################################################
if [ "$#" -lt "1" ]
then
	usage
	exit 1
fi

# parse options:
ARGS=$(getopt -o i:o:h -l config:,outdir:,help -- "$@")

if [ "$?" != "0" ]
then
	echo "${Script_File} exited with doing nothing." >&2
	exit 1
fi

# note the quotes around $ARGS: they are essential!
eval set -- "${ARGS}"

while [ "$#" -gt "0" ]
do
	case "$1" in
	-i | --config )
		config_file="$2"
		shift 2 ;;
	-o | --outdir )
		output_dir="$2"
		shift 2 ;;
	-h | --help )
		usage
		exit 1 ;;
	-- )
		shift
		break ;;
	* )
		usage
		exit 1 ;;
	\? )
		echo "unknow argument"
		exit 1 ;;
	esac
done
#####################################################################

#####################################################################
# Required Parameters
#####################################################################
if [ ! -s "${config_file}" ] || [ -z "${output_dir}" ]
then
	usage
	exit 1
fi
#####################################################################

#####################################################################
# Default Parameters
#####################################################################

#####################################################################

#####################################################################
# Script
#####################################################################
Bin="${Script_Dir}/bin"

il_to_bed="${Bin}/interval_list_to_bed.pl"
fastp_stats="${Bin}/fastp_stats.pl"
trim_pieplot="${Bin}/trim_pieplot.R"
qualimap_stats="${Bin}/qualimap_stats.pl"
multiqc_config="${Bin}/multiqc_config.yaml"
annovar_stats="${Bin}/annovar_stats.pl"
barplot="${Bin}/barplot.R"
bcftools_stats="${Bin}/bcftools_stats.pl"
cnvnator_filter="${Bin}/cnvnator_filter.pl"
cnvnator_stats="${Bin}/cnvnator_stats.pl"
cnv_to_avinput="${Bin}/cnv_to_avinput.pl"
cum_lineplot="${Bin}/cumulative_lineplot.R"
delly_stats="${Bin}/delly_stats.pl"
dodge_barplot="${Bin}/dodge_barplot.R"
indel_length_barplot="${Bin}/indel_length_barplot.R"
lineplot="${Bin}/lineplot.R"
multi_lineplot="${Bin}/multiple_lineplot.R"
pieplot="${Bin}/pieplot.R"
rmarkdown="${Bin}/rmarkdown.R"
sv_to_avinput="${Bin}/sv_to_avinput.pl"
var_density="${Bin}/variant_density.pl"
var_dis_barplot="${Bin}/variant_distribution_barplot.R"
#####################################################################

#####################################################################
# User-defined functions
#####################################################################
## get absolute path
function abs_path()
{
	local real=""
	if [ -s "$1" ]
	then
		file=$(basename "$1")
		dir=$(cd -P $(dirname "$1") && pwd)
		real="${dir}/${file}"
	elif [ -d "$1" ]
	then
		dir=$(cd -P "$1" && pwd)
		real="${dir}"
	else
		echo "Warning: $1 is neither a file nor a directory" 2>&1
		exit 1
	fi
	
	if [ -n "${real}" ]
	then
		echo "${real}"
	fi
}

## current time
function current_time()
{
	# local time=$(date "+%F %T")
	local time=$(date "+%Y-%m-%d %H:%M:%S")
	echo "[${time}]"
}

## elapsed time
function elapsed_time()
{
	local start_seconds="$1"
	local end_seconds="$2"
	
	local elapsed_seconds=$[${end_seconds}-${start_seconds}]
	local elapsed_time="${elapsed_seconds}s"

	if [ "${elapsed_seconds}" -ge "3600" ]
	then
		hours=$[${elapsed_seconds}/3600]
		remainder=$[${elapsed_seconds}%3600]
		if [ "${remainder}" -ge "60" ]
		then
			minutes=$[${remainder}/60]
			seconds=$[${remainder}%60]
			elapsed_time="${hours}h-${minutes}m-${seconds}s"
		else
			elapsed_time="${hours}h-0m-${remainder}s"
		fi
	else
		if [ "${elapsed_seconds}" -ge "60" ]
		then
			minutes=$[${elapsed_seconds}/60]
			seconds=$[${elapsed_seconds}%60]
			elapsed_time="${minutes}m-${seconds}s"
		else
			elapsed_time="${elapsed_seconds}s"
		fi
	fi
	
	echo "${elapsed_time}"
}
#####################################################################

#####################################################################
# Start Time
#####################################################################
if [ ! -d "${output_dir}" ]
then
	mkdir -p ${output_dir}
fi
output_dir=$(abs_path ${output_dir})

log="${output_dir}/output.log"

if [ -s "${log}" ]
then
	rm ${log}
fi

user_name=$(whoami)
host_name=$(hostname)
work_dir=$(pwd)
start_time=$(date "+%Y-%m-%d %H:%M:%S")
start_seconds=$(date --date="${start_time}" +%s)

tee -a "${log}" << EOF
${Script_Description}

User Name: [${user_name}]
Host Name: [${host_name}]
Work Directory: [${work_dir}]

Start Time: [${start_time}]

EOF
#####################################################################

#####################################################################
# Output parameters
#####################################################################
config_file=$(abs_path ${config_file})

tee -a ${log} << EOF
$(current_time) Parameters:
	--config	${config_file}
	--outdir	${output_dir}
$(current_time) Done!

EOF
#####################################################################

#####################################################################
# Create temporary directory and work shell directory
#####################################################################
sh_dir="${output_dir}/work_sh"
if [ ! -d "${sh_dir}" ]
then
	mkdir ${sh_dir}
fi

tmp_dir="${sh_dir}/tmp"
if [ ! -d "${tmp_dir}" ]
then
	mkdir ${tmp_dir}
fi
#####################################################################

#####################################################################
# Check the configuration file
#####################################################################
echo "$(current_time) Check the configuration file ......" | tee -a ${log}

config_dir="${output_dir}/config"
if [ ! -d "${config_dir}" ]
then
	mkdir ${config_dir}
fi

config_txt="${config_dir}/config.txt"
grep -v "^#" ${config_file} | sed '/^\s*$/d' | sed 's/\s*$//g' | sed 's/^\s*//g' > ${config_txt}

declare -A config

while read line
do
	OLD_IFS="$IFS"
	IFS="="
	array=(${line})
	IFS="${OLD_IFS}"
	config["${array[0]}"]="${array[1]}"
done < ${config_txt}

for i in "${!config[@]}"
do
	echo -e "	$i\t${config[$i]}" | tee -a ${log}
done

# global information
prefix=${config["prefix"]}
platform=${config["platform"]}
report_sample_name=${config["report_sample_name"]}
report_genome_name=${config["report_genome_name"]}
#report_genome_link=${config["report_genome_link"]}

# project information
contract_number=${config["contract_number"]}
project_name=${config["project_name"]}
species_name=${config["species_name"]}
sample_size=${config["sample_size"]}
company_name=${config["company_name"]}
#company_website=${config["company_website"]}

sample_size=$(echo "${sample_size}" | awk '{ if ($0 ~ /^[-]?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][-+]?[0-9]+)?$/) {printf "%'\''d",$0} else {printf "%s",$0}}')

# input information
sample_file=${config["sample_file"]}
if [ -s "${sample_file}" ]
then
	sample_file=$(abs_path ${sample_file})
fi

genome_file=${config["genome_file"]}
if [ -s "${genome_file}" ]
then
	genome_file=$(abs_path ${genome_file})
fi

fastq_dir=${config["fastq_dir"]}
if [ -d "${fastq_dir}" ]
then
	fastq_dir=$(abs_path ${fastq_dir})
fi

# other input information
# must provide one of GFF or GTF
gff_file=${config["gff_file"]}
if [ -s "${gff_file}" ]
then
	gff_file=$(abs_path ${gff_file})
fi

gtf_file=${config["gtf_file"]}
if [ -s "${gtf_file}" ]
then
	gtf_file=$(abs_path ${gtf_file})
fi

bed_file=${config["bed_file"]}
if [ -s "${bed_file}" ]
then
	bed_file=$(abs_path ${bed_file})
fi

# server resource
available_memory=${config["available_memory"]}
available_threads=${config["available_threads"]}
compression_level=${config["compression_level"]}

# rename options
convert_id=${config["convert_id"]}
rename_file=${config["rename_file"]}

if [ "${convert_id}" = "true" ]
then
	rename_txt="${config_dir}/rename.txt"

	if [ -s "${rename_file}" ]
	then
		grep -v "^#" ${rename_file} | sed '/^\s*$/d' | sed 's/\s*$//g' | sed 's/^\s*//g' > ${rename_txt}
	else
		grep -v "^#" ${sample_file} | sed '/^\s*$/d' | sed 's/\s*$//g' | sed 's/^\s*//g' | awk 'BEGIN {FS=OFS="\t"} {print $1,$2}' > ${rename_txt}
	fi
fi

# quality control
adapter_fasta_file=${config["adapter_fasta_file"]}
if [ ! -s "${adapter_fasta_file}" ]
then
	adapter_fasta_file="${Bin}/adapter/PE_adapter.fa"
else
	adapter_fasta_file=$(abs_path ${adapter_fasta_file})
fi
qualified_quality_phred=${config["qualified_quality_phred"]}
unqualified_percent_limit=${config["unqualified_percent_limit"]}
n_base_limit=${config["n_base_limit"]}
cut_front_window_size=${config["cut_front_window_size"]}
cut_front_mean_quality=${config["cut_front_mean_quality"]}
cut_tail_window_size=${config["cut_tail_window_size"]}
cut_tail_mean_quality=${config["cut_tail_mean_quality"]}
#cut_right_window_size=${config["cut_right_window_size"]}
#cut_right_mean_quality=${config["cut_right_mean_quality"]}
overlap_len_require=${config["overlap_len_require"]}
overlap_diff_limit=${config["overlap_diff_limit"]}
overlap_diff_percent_limit=${config["overlap_diff_percent_limit"]}
length_required=${config["length_required"]}
compute_md5=${config["compute_md5"]}

# reference
build_ref=${config["build_ref"]}
normalize_ref=${config["normalize_ref"]}
max_contiguous_n=${config["max_contiguous_n"]}

# snp and indel
adjust_map_qual=${config["adjust_map_qual"]}
max_depth=${config["max_depth"]}
min_map_qual=${config["min_map_qual"]}
min_base_qual=${config["min_base_qual"]}
mpileup_annotate=${config["mpileup_annotate"]}
min_ireads=${config["min_ireads"]}
min_gap_frac=${config["min_gap_frac"]}
call_annotate=${config["call_annotate"]}
snp_gap=${config["snp_gap"]}
indel_gap=${config["indel_gap"]}
exclude_expression=${config["exclude_expression"]}
count_window_size=${config["count_window_size"]}

if [ "${count_window_size}" -ge 1000000 ]
then
	density_unit="$[${count_window_size}/1000000]Mb"
else
	density_unit="$[${count_window_size}/1000]Kb"
fi

# sv
sv_map_qual=${config["sv_map_qual"]}
sv_mad_cutoff=${config["sv_mad_cutoff"]}
min_sv_size=${config["min_sv_size"]}
max_sv_size=${config["max_sv_size"]}

# cnv
cnv_bin_size=${config["cnv_bin_size"]}
max_cnv_eval1=${config["max_cnv_eval1"]}
max_cnv_q0=${config["max_cnv_q0"]}
min_cnv_size=${config["min_cnv_size"]}
max_cnv_size=${config["max_cnv_size"]}
germline_filter=${config["germline_filter"]}

# software path
bioawk=${config["bioawk"]}
seqtk=${config["seqtk"]}
seqkit=${config["seqkit"]}
csvtk=${config["csvtk"]}
rush=${config["rush"]}
pigz=${config["pigz"]}
gffread=${config["gffread"]}
gffcompare=${config["gffcompare"]}
ucsc=${config["ucsc"]}
faCount="${ucsc}/faCount"
faSplit="${ucsc}/faSplit"
faTrans="${ucsc}/faTrans"
faOneRecord="${ucsc}/faOneRecord"
gff3ToGenePred="${ucsc}/gff3ToGenePred"
gtfToGenePred="${ucsc}/gtfToGenePred"
fastp=${config["fastp"]}
fastqc=${config["fastqc"]}
cutadapt=${config["cutadapt"]}
multiqc=${config["multiqc"]}
bwa=${config["bwa"]}
bwamem2=${config["bwamem2"]}
samblaster=${config["samblaster"]}
biobambam2=${config["biobambam2"]}
bamsort="${biobambam2}/bamsort"
bamsormadup="${biobambam2}/bamsormadup"
samtools=${config["samtools"]}
bcftools=${config["bcftools"]}
qualimap=${config["qualimap"]}
gatk=${config["gatk"]}
delly=${config["delly"]}
svprops=${config["svprops"]}
sampleprops=${config["sampleprops"]}
cnvnator=${config["cnvnator"]}
annovar=${config["annovar"]}
retrieve_seq="${annovar}/retrieve_seq_from_fasta.pl"
convert2annovar="${annovar}/convert2annovar.pl"
table_annovar="${annovar}/table_annovar.pl"
vcftools=${config["vcftools"]}
bedtools=${config["bedtools"]}
bedops=${config["bedops"]}
convert2bed="${bedops}/convert2bed"
sortbed="${bedops}/sort-bed"
perl=${config["perl"]}
python2=${config["python2"]}
python3=${config["python3"]}
java=${config["java"]}
Rscript=${config["Rscript"]}

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
# Set server resource and software options
#####################################################################
if [ -z "${available_memory}" ]
then
	#total_memory=$(cat /proc/meminfo | grep "MemTotal" | awk '{print $2}')
	total_memory=$(cat /proc/meminfo | grep "MemAvailable" | awk '{print $2}')
	available_memory=$[${total_memory}/1024/1024]
fi

if [ -z "${available_threads}" ]
then
	total_threads=$(cat /proc/cpuinfo | grep "processor" | wc -l)
	available_threads=${total_threads}
fi

## fastp uses up to 16 threads
## upper limit, system does not have fast enough input/output performance (I/O bottleneck)
fastp_maxproc_limit="5"
fastp_threads=$(awk -v s="${sample_size}" -v l="${fastp_maxproc_limit}" -v t="${available_threads}" 'BEGIN {p = (s < l ? s : l); r = t/p; min = (r < 16 ? r : 16); printf "%.f", min}')
fastp_maxproc=$(awk -v s="${sample_size}" -v l="${fastp_maxproc_limit}" 'BEGIN {min = (s < l ? s : l); printf "%.f", min}')
fastp_options="--cut_front --cut_front_window_size ${cut_front_window_size} --cut_front_mean_quality ${cut_front_mean_quality} --cut_tail --cut_tail_window_size ${cut_tail_window_size} --cut_tail_mean_quality ${cut_tail_mean_quality} --qualified_quality_phred ${qualified_quality_phred} --unqualified_percent_limit ${unqualified_percent_limit} --n_base_limit ${n_base_limit} --adapter_fasta ${adapter_fasta_file} --correction --trim_poly_g --overlap_len_require ${overlap_len_require} --overlap_diff_limit ${overlap_diff_limit} --overlap_diff_percent_limit ${overlap_diff_percent_limit} --length_required ${length_required} --thread ${fastp_threads} --compression ${compression_level}"

## bwa
## upper limit, system does not have fast enough input/output performance (I/O bottleneck)
bwa_maxproc_limit="5"
bwa_threads=$(awk -v s="${sample_size}" -v l="${bwa_maxproc_limit}" -v t="${available_threads}" 'BEGIN {p = (s < l ? s : l); r = t/p; printf "%.f", r}')
bwa_maxproc=$(awk -v s="${sample_size}" -v l="${bwa_maxproc_limit}" 'BEGIN {min = (s < l ? s : l); printf "%.f", min}')

## biobambam2 bamsort
## size of internal memory buffer used for sorting in MiB
#bamsort_blockmb=$[${available_memory}/${bwa_maxproc}*1024]
bamsort_blockmb=$(awk -v m="${available_memory}" -v l="${bwa_maxproc}" 'BEGIN {b = m/l*1024/2; min = (b < 30720 ? b : 30720); printf "%.f", min}')
bamsort_options="level=${compression_level} SO=coordinate blockmb=${bamsort_blockmb} inputformat=sam outputformat=bam outputthreads=${bwa_threads} sortthreads=${bwa_threads} fixmates=1 index=1"
bamsormadup_options="level=${compression_level} SO=coordinate inputformat=sam outputformat=bam threads=${bwa_threads}"

## samtools sort
## set maximum memory per thread; suffix K/M/G recognized
#samtools_sortmem="$[${available_memory}/${bwa_maxproc}/${bwa_threads}*1024]M"
samtools_sortmem=$(awk -v m="${available_memory}" -v l="${bwa_maxproc}" -v t="${bwa_threads}" 'BEGIN {b = m/l/t*1024/2; min = (b < 3072 ? b : 3072); printf "%.f", min}')
samtools_sort_options="-l ${compression_level} -m ${samtools_sortmem}M -O bam --threads ${bwa_threads} --write-index"

## qualimap
qualimap_threads="${bwa_threads}"
qualimap_maxproc="${bwa_maxproc}"
#qualimap_memory=$[${available_memory}/${qualimap_maxproc}]
qualimap_memory=$(awk -v m="${available_memory}" -v l="${qualimap_maxproc}" 'BEGIN {b = m/l; min = (b < 50 ? b : 50); printf "%.f", min}')
qualimap_options="-nt 40 -outformat HTML --java-mem-size=${qualimap_memory}G --java-io-tmpdir=${tmp_dir}"

## bcftools mpileup
mpileup_options="-C ${adjust_map_qual} -d ${max_depth} -q ${min_map_qual} -Q ${min_base_qual} -a ${mpileup_annotate} -L ${max_depth} -m ${min_ireads} -F ${min_gap_frac} -p -P ${platform}"

## bcftools call
call_options="-a ${call_annotate} -v -m"

## gatk
## the Java memory heap size is a prime consideration
## testing has shown that the multithread in GATK does not scale well beyond 5 threads, so don't increase beyond that
gatk_memory=$(awk -v m="${available_memory}" 'BEGIN {min = (m < 50 ? m : 50); printf "%.f", min}')
gatk_java_options="--java-options \"-XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Dsamjdk.compression_level=${compression_level} -XX:ParallelGCThreads=${available_threads} -Xms${gatk_memory}g -Xmx${gatk_memory}g -Djava.io.tmpdir=${tmp_dir}\""

## SV calling
## upper limit, system does not have fast enough input/output performance (I/O bottleneck)
sv_maxproc_limit="10"
sv_maxproc=$(awk -v s="${sample_size}" -v l="${sv_maxproc_limit}" 'BEGIN {min = (s < l ? s : l); printf "%.f", min}')

## CNV calling
## upper limit, system does not have fast enough input/output performance (I/O bottleneck)
cnv_maxproc_limit="10"
cnv_maxproc=$(awk -v s="${sample_size}" -v l="${cnv_maxproc_limit}" 'BEGIN {min = (s < l ? s : l); printf "%.f", min}')
#####################################################################

#####################################################################
# Build Reference
#####################################################################
echo "$(current_time) 0. Build Reference ......" | tee -a ${log}

ref_dir="${output_dir}/0.Reference"
if [ ! -d "${ref_dir}" ]
then
	mkdir ${ref_dir}
fi

ref_sh="${sh_dir}/0.ref.sh"
ref_log="${sh_dir}/0.ref.log"

if [ -s "${ref_sh}" ]
then
	rm ${ref_sh} ${ref_log}
fi

if [ "${build_ref}" = "true" ]
then
	ref_fa="${ref_dir}/${prefix}.fa"
	ref_gff="${ref_fa%.*}.gff"
	ref_gtf="${ref_fa%.*}.gtf"
	ref_len="${ref_fa}.len"
	ref_fai="${ref_fa}.fai"
	ref_dict="${ref_fa%.*}.dict"
	ref_il="${ref_fa}.interval_list"
	ref_wgs_call_bed="${ref_fa%.*}_wgs_calling.bed"
	ref_wgs_excl_bed="${ref_fa%.*}_wgs_exclude.bed"
	ref_amb="${ref_fa}.amb"
	ref_ann="${ref_fa}.ann"
	ref_bwt="${ref_fa}.bwt"
	ref_pac="${ref_fa}.pac"
	ref_sa="${ref_fa}.sa"
	ref_0123="${ref_fa}.0123"
	ref_bwt64="${ref_fa}.bwt.2bit.64"
	
	if [ ! -s "${ref_fa}" ]
	then
		if [ "${normalize_ref}" = "true" ]
		then
			cat >> ${ref_sh} << EOF
## Normalizes lines of sequence in a FASTA file to be of the same length
${gatk} ${gatk_java_options} NormalizeFasta -I ${genome_file} -O ${ref_fa} --LINE_LENGTH 100

EOF
		else
			cat >> ${ref_sh} << EOF
## Make link of reference
ln -sf ${genome_file} ${ref_fa}

EOF
		fi
	fi
	
	if [ ! -s "${ref_len}" ]
	then
		cat >> ${ref_sh} << EOF
## Count base statistics and CpGs in FA files
${faCount} ${ref_fa} > ${ref_len}

EOF
	fi
	
	if [ ! -s "${ref_fai}" ]
	then
		cat >> ${ref_sh} << EOF
## Create samtools reference genome index
${samtools} faidx ${ref_fa}

EOF
	fi
	
	if [ ! -s "${ref_dict}" ]
	then
		cat >> ${ref_sh} << EOF
## Create a sequence dictionary for a reference sequence
${gatk} ${gatk_java_options} CreateSequenceDictionary -R ${ref_fa} -O ${ref_dict}

EOF
	fi
	
	if [ ! -s "${ref_gtf}" ]
	then
		if [ -s "${gtf_file}" ]
		then
			cat >> ${ref_sh} << EOF
## Make link of GTF
ln -sf ${gtf_file} ${ref_gtf}

EOF
		else
			if [ -s "${gff_file}" ]
			then
				cat >> ${ref_sh} << EOF
## GFF to GTF
${gffread} ${gff_file} -T -o ${ref_gtf}

EOF
			fi
		fi
	fi

	if [ ! -s "${ref_il}" ]
	then
		cat >> ${ref_sh} << EOF
## Break up a reference into intervals of alternating regions of N and ACGT bases
${gatk} ${gatk_java_options} ScatterIntervalsByNs -R ${ref_fa} -N ${max_contiguous_n} -OT BOTH -O ${ref_il}

EOF
	fi

	if [ ! -s "${ref_wgs_call_bed}" ]
	then
		if [ -s "${bed_file}" ]
		then
			cat >> ${ref_sh} << EOF
## Make link of WGS calling bed
ln -sf ${bed_file} ${ref_wgs_call_bed}

EOF
		else
			cat >> ${ref_sh} << EOF
## Interval list to WGS BED
${perl} ${il_to_bed} --infile ${ref_il} --outdir ${ref_dir} --prefix ${prefix}_wgs

EOF
		fi
	fi

	ref_split_dir="${ref_dir}/split"
	if [ ! -d "${ref_split_dir}" ]
	then
		mkdir ${ref_split_dir}
	fi

	ref_split_sh="${sh_dir}/ref_split.sh"
	ref_split_rush="${sh_dir}/ref_split.rush"

#	cat >> ${ref_sh} << EOF
## Split sequences into files by name ID
#${faSplit} byname ${ref_fa} ${ref_split_dir}/

#EOF

	cat >> ${ref_sh} << EOF
## Split sequences into files by name ID
cut -f 1 ${ref_wgs_call_bed} | uniq | while read chr
do
	chr_fa="${ref_split_dir}/\${chr}.fa"
	if [ ! -s "\${chr_fa}" ]
	then
		echo "${faOneRecord} ${ref_fa} \${chr} > \${chr_fa}"
	fi
done > ${ref_split_sh}
cat ${ref_split_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${ref_split_rush} --verbose

EOF

	if [ ! -s "${ref_bwt64}" ]
	then
		cat >> ${ref_sh} << EOF
## Create BWA-MEM2 reference genome index
${bwamem2} index ${ref_fa}

EOF
	fi
	
	ref_annovar_dir="${ref_dir}/ANNOVAR"
	if [ ! -d "${ref_annovar_dir}" ]
	then
		mkdir ${ref_annovar_dir}
	fi
	
	ref_gene_pred="${ref_annovar_dir}/${prefix}_refGene.txt"
	ref_gene_mrna="${ref_annovar_dir}/${prefix}_refGeneMrna.fa"
	
	#${gff3ToGenePred} ${gff3} ${gene_pred_file}
	if [ ! -s "${ref_gene_pred}" ]
	then
		cat >> ${ref_sh} << EOF
## GTF to GenePred
${gtfToGenePred} -genePredExt -allErrors ${ref_gtf} ${ref_gene_pred}

EOF
	fi
	
	if [ ! -s "${ref_gene_mrna}" ]
	then
		cat >> ${ref_sh} << EOF
## Reformat sequences at specific genomic positions from whole-genome FASTA files
${perl} ${retrieve_seq} --format refGene --seqfile ${ref_fa} ${ref_gene_pred} --outfile ${ref_gene_mrna}

EOF
	fi
else
	ref_fa=$(abs_path ${genome_file})
	genome_dir=$(dirname ${genome_file})
	ref_split_dir="${genome_dir}/split"
	#[ -d "${ref_split_dir}" ] || exit 1
	ref_annovar_dir="${genome_dir}/ANNOVAR"
	#[ -d "${ref_annovar_dir}" ] || exit 1
	ref_gff="${ref_fa%.*}.gff"
	ref_gtf="${ref_fa%.*}.gtf"
	ref_len="${ref_fa}.len"
	ref_fai="${ref_fa}.fai"
	ref_dict="${ref_fa%.*}.dict"
	ref_il="${ref_fa}.interval_list"
	ref_wgs_call_bed="${ref_fa%.*}_wgs_calling.bed"
	ref_wgs_excl_bed="${ref_fa%.*}_wgs_exclude.bed"
	ref_amb="${ref_fa}.amb"
	ref_ann="${ref_fa}.ann"
	ref_bwt="${ref_fa}.bwt"
	ref_pac="${ref_fa}.pac"
	ref_sa="${ref_fa}.sa"
	ref_0123="${ref_fa}.0123"
	ref_bwt64="${ref_fa}.bwt.2bit.64"
	ref_gene_pred="${ref_annovar_dir}/${prefix}_refGene.txt"
	ref_gene_mrna="${ref_annovar_dir}/${prefix}_refGeneMrna.fa"
fi

if [ -s "${ref_sh}" ]
then
	echo "$(current_time) Command: bash ${ref_sh} 2>&1 | tee -a ${ref_log}" | tee -a ${log}

	bash ${ref_sh} 2>&1 | tee -a ${ref_log}
else
	echo "$(current_time) Build reference is ${build_ref}. So skip this step!" | tee -a ${log}
fi

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
# Quality Control for PE data
#####################################################################
echo "$(current_time) 1. Quality Control ......" | tee -a ${log}

qc_dir="${output_dir}/1.QualityControl"
if [ ! -d "${qc_dir}" ]
then
	mkdir ${qc_dir}
fi

qc_sh="${sh_dir}/1.qc.sh"
qc_log="${sh_dir}/1.qc.log"

if [ -s "${qc_sh}" ]
then
	rm ${qc_sh} ${qc_log}
fi

raw_data_dir="${qc_dir}/raw_data"
if [ ! -d "${raw_data_dir}" ]
then
	mkdir ${raw_data_dir}
fi

clean_data_dir="${qc_dir}/clean_data"
if [ ! -d "${clean_data_dir}" ]
then
	mkdir ${clean_data_dir}
fi

fastp_dir="${qc_dir}/fastp"
if [ ! -d "${fastp_dir}" ]
then
	mkdir ${fastp_dir}
fi

qc_stats_dir="${qc_dir}/stats"
if [ ! -d "${qc_stats_dir}" ]
then
	mkdir ${qc_stats_dir}
fi

trim_dir="${qc_dir}/trim"
if [ ! -d "${trim_dir}" ]
then
	mkdir ${trim_dir}
fi

link_sh="${sh_dir}/link.sh"
link_rush="${sh_dir}/link.rush"
fastp_sh="${sh_dir}/fastp.sh"
fastp_rush="${sh_dir}/fastp.rush"
csvtk_grep_sh="${sh_dir}/csvtk_grep.sh"
csvtk_grep_rush="${sh_dir}/csvtk_grep.rush"
trim_pieplot_sh="${sh_dir}/trim_pieplot.sh"
trim_pieplot_rush="${sh_dir}/trim_pieplot.rush"

qc_stats="${qc_stats_dir}/${prefix}_qc_stats.txt"
trim_stats="${qc_stats_dir}/${prefix}_trim_stats.txt"

rawdata_md5="${raw_data_dir}/rawdata_md5.txt"
cleandata_md5="${clean_data_dir}/cleandata_md5.txt"

if [ "${convert_id}" = "true" ]
then
	cat >> ${qc_sh} << EOF
## Read BYZH ID and Sample Name
declare -A rename
while read line
do
	OLD_IFS="\$IFS"
	IFS=\$'\t'
	var=(\${line})
	IFS="\${OLD_IFS}"
	rename["\${var[1]}"]="\${var[0]}"
done < ${rename_txt}

## Convert BYZH ID to Sample Name
find ${fastq_dir} -maxdepth 1 -name "*f*q*" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\$(echo \$name | sed 's/^.*-\\?\\(WR[0-9]\\+[A-Z]\\+\\)-\\?.*_.*\\([1-2]\\)\\.f.*q.*\$/\\1/g')
	pe=\$(echo \$name | sed 's/^.*-\\?\\(WR[0-9]\\+[A-Z]\\+\\)-\\?.*_.*\\([1-2]\\)\\.f.*q.*\$/\\2/g')

	if [ -z "\${rename["\${sm}"]}" ]
	then
		sm=\$(echo \$name | sed 's/^\\(.*\\)_R\\?\\([1-2]\\)\\.f.*q.*\$/\\1/g')
		pe=\$(echo \$name | sed 's/^\\(.*\\)_R\\?\\([1-2]\\)\\.f.*q.*\$/\\2/g')
	fi
	
	new_sm="\${rename["\${sm}"]}"
	new_pe="R\${pe}"
	link="${raw_data_dir}/\${new_sm}_\${new_pe}.fq.gz"
	
	if [ -n "\${new_sm}" ]
	then
		echo "ln -sf \${line} \${link}"
	fi
done > ${link_sh}
cat ${link_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${link_rush} --verbose

EOF
else
	cat >> ${qc_sh} << EOF
## Make links for FASTQ
find ${fastq_dir} -maxdepth 1 -name "*f*q*" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\$(echo \$name | sed 's/^\\(.*\\)_.*\\([1-2]\\)\\.f.*q.*\$/\\1/g')
	pe=\$(echo \$name | sed 's/^\\(.*\\)_.*\\([1-2]\\)\\.f.*q.*\$/\\2/g')

	new_sm="\${sm}"
	new_pe="R\${pe}"
	link="${raw_data_dir}/\${new_sm}_\${new_pe}.fq.gz"

	echo "ln -sf \${line} \${link}"
done > ${link_sh}
cat ${link_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${link_rush} --verbose

EOF
fi

cat >> ${qc_sh} << EOF
## Quality Control for PE data using fastp
find ${raw_data_dir} -maxdepth 1 -name "*_R1.f*q*" -not -empty | while read R1
do
	name=\$(basename \${R1})
	sm=\${name%_*}
	R2=\$(echo \${R1} | sed 's/_R1\.f/_R2\.f/')
	clean_R1="${clean_data_dir}/\${sm}_clean_R1.fq.gz"
	clean_R2="${clean_data_dir}/\${sm}_clean_R2.fq.gz"
	fastp_json="${fastp_dir}/\${sm}_fastp.json"
	fastp_html="${fastp_dir}/\${sm}_fastp.html"
	fastp_log="${fastp_dir}/\${sm}_fastp.log"
	report_title="\${sm} Fastp Report"
	if [ ! -s "\${clean_R1}" ] || [ ! -s "\${clean_R2}" ] || [ ! -s "\${fastp_json}" ]
	then
		echo "${fastp} --in1 \${R1} --in2 \${R2} --out1 \${clean_R1} --out2 \${clean_R2} ${fastp_options} --json \${fastp_json} --html \${fastp_html} --report_title \"\${report_title}\" >\${fastp_log} 2>&1"
	fi
done > ${fastp_sh}
cat ${fastp_sh} | ${rush} {} -n 1 -j ${fastp_maxproc} -c -C ${fastp_rush} --verbose

## Multiqc for fastp
${multiqc} --force --filename ${prefix}_multiqc_fastp --config ${multiqc_config} --outdir ${qc_stats_dir} ${fastp_dir}/*_fastp.json

## Stats of Quality Control
${perl} ${fastp_stats} --indir ${fastp_dir} --outdir ${qc_stats_dir} --prefix ${prefix}

## Split trimming data
sed '1d' ${trim_stats} | cut -f 1 | while read line
do
	echo "${csvtk} grep -C '\$' -t -T -f 1 -p \${line} ${trim_stats} > ${tmp_dir}/\${line}_trim_stats.txt"
done > ${csvtk_grep_sh}
cat ${csvtk_grep_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${csvtk_grep_rush} --verbose

## Pie plot of trimming data
find ${tmp_dir} -maxdepth 1 -name "*_trim_stats.txt" -not -empty | while read line
do
	echo "${Rscript} ${trim_pieplot} --infile \${line} --outdir ${trim_dir} --height 6 --width 8"
done > ${trim_pieplot_sh}
cat ${trim_pieplot_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${trim_pieplot_rush} --verbose
EOF

echo "$(current_time) Command: bash ${qc_sh} 2>&1 | tee -a ${qc_log}" | tee -a ${log}

bash ${qc_sh} 2>&1 | tee -a ${qc_log}

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
# Mapping
#####################################################################
echo "$(current_time) 2. Mapping ......" | tee -a ${log}

map_dir="${output_dir}/2.Mapping"
if [ ! -d "${map_dir}" ]
then
	mkdir ${map_dir}
fi

map_sh="${sh_dir}/2.map.sh"
map_log="${sh_dir}/2.map.log"

if [ -s "${map_sh}" ]
then
	rm ${map_sh} ${map_log}
fi

sort_dir="${map_dir}/sort"
if [ ! -d "${sort_dir}" ]
then
	mkdir ${sort_dir}
fi

bamqc_dir="${map_dir}/bamqc"
if [ ! -d "${bamqc_dir}" ]
then
	mkdir ${bamqc_dir}
fi

map_stats_dir="${map_dir}/stats"
if [ ! -d "${map_stats_dir}" ]
then
	mkdir ${map_stats_dir}
fi

sort_sh="${sh_dir}/sort.sh"
sort_rush="${sh_dir}/sort.rush"
bamqc_sh="${sh_dir}/bamqc.sh"
bamqc_rush="${sh_dir}/bamqc.rush"

map_stats="${map_stats_dir}/${prefix}_mapping_stats.txt"

cat >> ${map_sh} << EOF
## Map to Reference and Mark Duplicates and Sort SAM by coordinate to BAM
find ${clean_data_dir} -maxdepth 1 -name "*_clean_R1.f*q*" -not -empty | while read R1
do
	name=\$(basename \$R1)
	sm=\${name%_*_*}
	R2=\$(echo \$R1 | sed 's/_clean_R1\.f/_clean_R2\.f/')
	rg="@RG\\tID:\${sm}\\tSM:\${sm}\\tLB:WGS\\tPL:${platform}"
	bwamem_log="${sort_dir}/\${sm}_bwamem.log"
	markdup_metrics="${sort_dir}/\${sm}_markdup.metrics"
	sormadup_log="${sort_dir}/\${sm}_sormadup.log"
	sormadup_tmp="${sort_dir}/\${sm}_sormadup"
	sort_bam="${sort_dir}/\${sm}_sort.bam"
	sort_bai="${sort_dir}/\${sm}_sort.bai"
	if [ ! -s "\${sort_bam}" ]
	then
		echo "${bwamem2} mem -t 20 -Y -M -R \"\${rg}\" ${ref_fa} \${R1} \${R2} 2>\${bwamem_log} | ${samtools} view -bS |${samtools} sort -m 2G -O BAM -o \${sort_bam} --threads 20 && ${samtools} index -b \${sort_bam}"
	fi
done > ${sort_sh}
cat ${sort_sh} | ${rush} {} -n 1 -j ${bwa_maxproc} -c -C ${sort_rush} --verbose



## Multiqc for bamsormadup
${multiqc} --force --filename ${prefix}_multiqc_markdup --config ${multiqc_config} --outdir ${map_stats_dir} ${sort_dir}/*_markdup.metrics

## Evaluate NGS mapping using qualimap's bamqc
find ${sort_dir} -maxdepth 1 -name "*_sort.bam" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*}
	bamqc_log="${bamqc_dir}/\${sm}_bamqc.log"
	bamqc_html="${bamqc_dir}/\${sm}_bamqc/qualimapReport.html"
	if [ ! -s "\${bamqc_html}" ]
	then
		echo "${qualimap} bamqc -bam \${line} -outdir ${bamqc_dir}/\${sm}_bamqc ${qualimap_options} >\${bamqc_log} 2>&1"
	fi
done > ${bamqc_sh}
cat ${bamqc_sh} | ${rush} {} -n 1 -j ${qualimap_maxproc} -c -C ${bamqc_rush} --verbose

## Multiqc for bamqc
${multiqc} --force --filename ${prefix}_multiqc_bamqc --config ${multiqc_config} --outdir ${map_stats_dir} ${bamqc_dir}/*_bamqc

## Stats of mapping
${perl} ${qualimap_stats} --indir ${bamqc_dir} --outfile ${map_stats}
EOF

echo "$(current_time) Command: bash ${map_sh} 2>&1 | tee -a ${map_log}" | tee -a ${log}

bash ${map_sh} 2>&1 | tee -a ${map_log}

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
## Variant Calling
#####################################################################
echo "$(current_time) 3. Variant Calling ......" | tee -a ${log}

call_dir="${output_dir}/3.Calling"
if [ ! -d "${call_dir}" ]
then
	mkdir ${call_dir}
fi

call_sh="${sh_dir}/3.call.sh"
call_log="${sh_dir}/3.call.log"

if [ -s "${call_sh}" ]
then
	rm ${call_sh} ${call_log}
fi

call_var_dir="${call_dir}/variant"
if [ ! -d "${call_var_dir}" ]
then
	mkdir ${call_var_dir}
fi

mpileup_call_sh="${sh_dir}/mpileup_call.sh"
mpileup_call_rush="${sh_dir}/mpileup_call.rush"

bam_list="${call_var_dir}/${prefix}_bam.list"
vcf_list="${call_var_dir}/${prefix}_vcf.list"
raw_vcf="${call_var_dir}/${prefix}_raw.vcf.gz"
filter_vcf="${call_var_dir}/${prefix}_filter.vcf.gz"

cat >> ${call_sh} << EOF
## Generate bam list
find ${sort_dir} -maxdepth 1 -name "*_sort.bam" -not -empty > ${bam_list}

## Call variants per-chromosome
cut -f 1 ${ref_wgs_call_bed} | uniq | while read chr
do
	chr_vcf="${call_var_dir}/${prefix}_\${chr}.vcf.gz"
	if [ ! -s "\${chr_vcf}" ]
	then
		echo "${bcftools} mpileup -b ${bam_list} -f ${ref_fa} ${mpileup_options} -O u -r \${chr} | ${bcftools} call ${call_options} -O z -o \${chr_vcf}"
	fi
done > ${mpileup_call_sh}
cat ${mpileup_call_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${mpileup_call_rush} --verbose

## Generate vcf list
cut -f 1 ${ref_wgs_call_bed} | uniq | sort -h | while read chr
do
	chr_vcf="${call_var_dir}/${prefix}_\${chr}.vcf.gz"
	if [ -s "\${chr_vcf}" ]
	then
		echo "\${chr_vcf}"
	fi
done > ${vcf_list}

EOF

if [ ! -s "${raw_vcf}" ]
then
	cat >> ${call_sh} << EOF
## Combine VCF files
${bcftools} concat -f ${vcf_list} -n -O z -o ${raw_vcf}

EOF
fi

if [ ! -s "${filter_vcf}" ]
then
	cat >> ${call_sh} << EOF
## Apply fixed-threshold filters
${bcftools} filter -s LowQual -g ${snp_gap} -G ${indel_gap} -e ${exclude_expression} -O z -o ${filter_vcf} ${raw_vcf}

EOF
fi

## Call SNP
call_snp_dir="${call_dir}/snp"
if [ ! -d "${call_snp_dir}" ]
then
	mkdir ${call_snp_dir}
fi

call_snp_stats_dir="${call_snp_dir}/stats"
if [ ! -d "${call_snp_stats_dir}" ]
then
	mkdir ${call_snp_stats_dir}
fi

snp_vcf="${call_snp_dir}/${prefix}_snp.vcf.gz"
snp_gt="${call_snp_dir}/${prefix}_snp_genotype.txt"
snp_pos="${call_snp_stats_dir}/${prefix}_snp_position.txt"
snp_stats="${call_snp_stats_dir}/${prefix}_snp_stats.txt"
snp_af="${call_snp_stats_dir}/${prefix}_snp_af.txt"
snp_dp="${call_snp_stats_dir}/${prefix}_snp_depth.txt"
snp_hwe="${call_snp_stats_dir}/${prefix}_snp_hwe.txt"
snp_psc="${call_snp_stats_dir}/${prefix}_snp_psc.txt"
snp_qual="${call_snp_stats_dir}/${prefix}_snp_quality.txt"
snp_type="${call_snp_stats_dir}/${prefix}_snp_type.txt"
snp_density="${call_snp_stats_dir}/${prefix}_snp_density.txt"

if [ ! -s "${snp_vcf}" ]
then
	cat >> ${call_sh} << EOF
## Select SNPs
${bcftools} view -f "PASS" -T ${ref_wgs_call_bed} --min-alleles 2 --max-alleles 2 --exclude-uncalled --types snps -O z -o ${snp_vcf} ${filter_vcf}

EOF
fi

if [ ! -s "${snp_gt}" ]
then
	cat >> ${call_sh} << EOF
## SNP genotype
${bcftools} query -H -f '%CHROM\t%POS\t%REF\t%ALT[\t%TGT]\n' ${snp_vcf} > ${snp_gt}

EOF
fi

if [ ! -s "${snp_stats}" ]
then
	cat >> ${call_sh} << EOF
## SNP stats using bcftools stats
${bcftools} stats -F ${ref_fa} -s - ${snp_vcf} > ${snp_stats}

EOF
fi

cat >> ${call_sh} << EOF
## Multiqc for snp stats
${multiqc} --force --filename ${prefix}_multiqc_snp --config ${multiqc_config} --outdir ${call_snp_stats_dir} ${snp_stats}

## Extract results from bcftools stats
${perl} ${bcftools_stats} --infile ${snp_stats} --outdir ${call_snp_stats_dir} --prefix ${prefix}

## Bar plot of SNP Substitution Type
${Rscript} ${barplot} --infile ${snp_type} --outdir ${call_snp_stats_dir} --prefix ${prefix}_snp_type --xcol "#Type" --ycol "Count" --limit 0 --xscale 0 --xlab "Substitution Type" --ylab "Count" --title "SNP" --height 6 --width 8

## Bar plot of SNP PSC
${Rscript} ${dodge_barplot} --infile ${snp_psc} --outdir ${call_snp_stats_dir} --prefix ${prefix}_snp_psc --xcol "#Sample_ID" --ycol "HomRef,Het,HomAlt" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "SNP" --height 6 --width 8

## SNP density
${perl} ${var_density} --infile ${snp_gt} --chrlen ${ref_len} --outfile ${snp_density} --window ${count_window_size}

## Bar plot of SNP distribution
${Rscript} ${var_dis_barplot} --infile ${snp_gt} --chrlen ${ref_len} --outdir ${call_snp_stats_dir} --prefix ${prefix}_snp_distribution --xcol 1 --ycol 2 --window ${count_window_size} --limit 0 --xscale 5 --title "SNP" --height 6 --width 10

EOF

## Call InDel
call_indel_dir="${call_dir}/indel"
if [ ! -d "${call_indel_dir}" ]
then
	mkdir ${call_indel_dir}
fi

call_indel_stats_dir="${call_indel_dir}/stats"
if [ ! -d "${call_indel_stats_dir}" ]
then
	mkdir ${call_indel_stats_dir}
fi

indel_vcf="${call_indel_dir}/${prefix}_indel.vcf.gz"
indel_gt="${call_indel_dir}/${prefix}_indel_genotype.txt"
indel_stats="${call_indel_stats_dir}/${prefix}_indel_stats.txt"
indel_af="${call_indel_stats_dir}/${prefix}_indel_af.txt"
indel_dp="${call_indel_stats_dir}/${prefix}_indel_depth.txt"
indel_hwe="${call_indel_stats_dir}/${prefix}_indel_hwe.txt"
indel_length="${call_indel_stats_dir}/${prefix}_indel_length.txt"
indel_psc="${call_indel_stats_dir}/${prefix}_indel_psc.txt"
indel_qual="${call_indel_stats_dir}/${prefix}_indel_quality.txt"
indel_pos="${call_indel_stats_dir}/${prefix}_indel_position.txt"
indel_density="${call_indel_stats_dir}/${prefix}_indel_density.txt"

if [ ! -s "${indel_vcf}" ]
then
	cat >> ${call_sh} << EOF
## Select INDELs
${bcftools} view -f "PASS" -T ${ref_wgs_call_bed} --min-alleles 2 --max-alleles 2 --exclude-uncalled --types indels -O z -o ${indel_vcf} ${filter_vcf}

EOF
fi

if [ ! -s "${indel_gt}" ]
then
	cat >> ${call_sh} << EOF
## InDel genotype
${bcftools} query -H -f '%CHROM\t%POS\t%REF\t%ALT[\t%TGT]\n' ${indel_vcf} > ${indel_gt}

EOF
fi

if [ ! -s "${indel_stats}" ]
then
	cat >> ${call_sh} << EOF
## InDel stats using bcftools' stats
${bcftools} stats -F ${ref_fa} -s - ${indel_vcf} > ${indel_stats}

EOF
fi

cat >> ${call_sh} << EOF
## Multiqc for indel stats
${multiqc} --force --filename ${prefix}_multiqc_indel --config ${multiqc_config} --outdir ${call_indel_stats_dir} ${indel_stats}

## Extract results from bcftools stats
${perl} ${bcftools_stats} --infile ${indel_stats} --outdir ${call_indel_stats_dir} --prefix ${prefix}

## Bar plot of InDel Length
${Rscript} ${indel_length_barplot} --infile ${indel_length} --outdir ${call_indel_stats_dir} --prefix ${prefix}_indel_length --xcol "#Length" --ycol "Count" --xlab "Length" --ylab "Count" --title "InDel" --height 6 --width 8

## Bar plot of InDel PSC
${Rscript} ${dodge_barplot} --infile ${indel_psc} --outdir ${call_indel_stats_dir} --prefix ${prefix}_indel_psc --xcol "#Sample_ID" --ycol "HomRef,InsHet,DelHet,InsHomAlt,DelHomAlt" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "InDel" --height 6 --width 8

## InDel density
${perl} ${var_density} --infile ${indel_gt} --chrlen ${ref_len} --outfile ${indel_density} --window ${count_window_size}

## Bar plot of InDel distribution
${Rscript} ${var_dis_barplot} --infile ${indel_gt} --chrlen ${ref_len} --outdir ${call_indel_stats_dir} --prefix ${prefix}_indel_distribution --xcol 1 --ycol 2 --window ${count_window_size} --limit 0 --xscale 5 --title "InDel" --height 6 --width 10

EOF

## Call SV
call_sv_dir="${call_dir}/sv"
if [ ! -d "${call_sv_dir}" ]
then
	mkdir ${call_sv_dir}
fi

call_sv_call_dir="${call_sv_dir}/call"
if [ ! -d "${call_sv_call_dir}" ]
then
	mkdir ${call_sv_call_dir}
fi

if [ "${sample_size}" -gt 1 ]
then
	call_sv_merge_dir="${call_sv_dir}/merge"
	if [ ! -d "${call_sv_merge_dir}" ]
	then
		mkdir ${call_sv_merge_dir}
	fi

	call_sv_geno_dir="${call_sv_dir}/geno"
	if [ ! -d "${call_sv_geno_dir}" ]
	then
		mkdir ${call_sv_geno_dir}
	fi

	sv_call_bcf_list="${call_sv_merge_dir}/${prefix}_sv_call_bcf.list"
	sv_geno_bcf_list="${call_sv_merge_dir}/${prefix}_sv_geno_bcf.list"

	sv_site_bcf="${call_sv_merge_dir}/${prefix}_sv_site.bcf"
	sv_site_log="${call_sv_merge_dir}/${prefix}_sv_site.log"

	sv_merge_bcf="${call_sv_merge_dir}/${prefix}_sv_merge.bcf"
	sv_merge_log="${call_sv_merge_dir}/${prefix}_sv_merge.log"
fi


if [ "${germline_filter}" = "true" ]
then
	call_sv_filter_dir="${call_sv_dir}/filter"
	if [ ! -d "${call_sv_filter_dir}" ]
	then
		mkdir ${call_sv_filter_dir}
	fi

	sv_filter_bcf="${call_sv_filter_dir}/${prefix}_sv_filter.bcf"
	sv_filter_log="${call_sv_filter_dir}/${prefix}_sv_filter.log"
fi

call_sv_stats_dir="${call_sv_dir}/stats"
if [ ! -d "${call_sv_stats_dir}" ]
then
	mkdir ${call_sv_stats_dir}
fi

sv_call_sh="${sh_dir}/sv_call.sh"
sv_call_rush="${sh_dir}/sv_call.rush"
sv_geno_sh="${sh_dir}/sv_geno.sh"
sv_geno_rush="${sh_dir}/sv_geno.rush"

sv_vcf="${call_sv_dir}/${prefix}_sv.vcf.gz"
sv_call="${call_sv_dir}/${prefix}_sv_call.txt"

sv_props_stats="${call_sv_stats_dir}/${prefix}_sv_props_stats.txt"
sv_sample_stats="${call_sv_stats_dir}/${prefix}_sv_sample_stats.txt"
sv_type="${call_sv_stats_dir}/${prefix}_sv_type.txt"
sv_vac="${call_sv_stats_dir}/${prefix}_sv_vac.txt"
sv_vaf="${call_sv_stats_dir}/${prefix}_sv_vaf.txt"
sv_psc="${call_sv_stats_dir}/${prefix}_sv_psc.txt"

cat >> ${call_sh} << EOF
## SV calling by DELLY2
cat ${bam_list} | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*}
	call_bcf="${call_sv_call_dir}/\${sm}_call.bcf"
	call_log="${call_sv_call_dir}/\${sm}_call.log"
	if [ ! -s "\${call_bcf}" ]
	then
		if [ -s "${ref_wgs_excl_bed}" ]
		then
			echo "${delly} call -t ALL -g ${ref_fa} -x ${ref_wgs_excl_bed} -q ${sv_map_qual} -s ${sv_mad_cutoff} -o \${call_bcf} \${line} >\${call_log} 2>&1"
		else
			echo "${delly} call -t ALL -g ${ref_fa} -q ${sv_map_qual} -s ${sv_mad_cutoff} -o \${call_bcf} \${line} >\${call_log} 2>&1"
		fi
	fi
done > ${sv_call_sh}
cat ${sv_call_sh} | ${rush} {} -n 1 -j ${sv_maxproc} -c -C ${sv_call_rush} --verbose

EOF

if [ "${sample_size}" -gt 1 ]
then
	cat >> ${call_sh} << EOF
## Generate SV call bcf list
find ${call_sv_call_dir} -maxdepth 1 -name "*_call.bcf" -not -empty > ${sv_call_bcf_list}

## Merge SV sites into a unified site list
${delly} merge -m ${min_sv_size} -n ${max_sv_size} -c -p -o ${sv_site_bcf} ${sv_call_bcf_list} >${sv_site_log} 2>&1

## Genotype this merged SV site list across all samples
cat ${bam_list} | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*}
	geno_bcf="${call_sv_geno_dir}/\${sm}_geno.bcf"
	geno_log="${call_sv_geno_dir}/\${sm}_geno.log"
	if [ ! -s "\${geno_bcf}" ]
	then
		if [ -s "${ref_wgs_excl_bed}" ]
		then
			echo "${delly} call -t ALL -g ${ref_fa} -x ${ref_wgs_excl_bed} -q ${sv_map_qual} -s ${sv_mad_cutoff} -o \${geno_bcf} -v ${sv_site_bcf} \${line} >\${geno_log} 2>&1"
		else
			echo "${delly} call -t ALL -g ${ref_fa} -q ${sv_map_qual} -s ${sv_mad_cutoff} -o \${geno_bcf} -v ${sv_site_bcf} \${line} >\${geno_log} 2>&1"
		fi
	fi
done > ${sv_geno_sh}
cat ${sv_geno_sh} | ${rush} {} -n 1 -j ${sv_maxproc} -c -C ${sv_geno_rush} --verbose

## Generate SV geno bcf list
find ${call_sv_geno_dir} -maxdepth 1 -name "*_geno.bcf" -not -empty > ${sv_geno_bcf_list}

## Merge all genotyped samples to get a single VCF/BCF using bcftools merge
${bcftools} merge -l ${sv_geno_bcf_list} -m id -O b -o ${sv_merge_bcf}

## Index bgzip compressed VCF/BCF files for random access
${bcftools} index ${sv_merge_bcf}

EOF
	if [ "${germline_filter}" = "true" ]
	then
		cat >> ${call_sh} << EOF
## Apply the germline SV filter
${delly} filter -f germline -m ${min_sv_size} -n ${max_sv_size} -p -o ${sv_filter_bcf} ${sv_merge_bcf} >${sv_filter_log} 2>&1

## SV BCF to SV VCF
${bcftools} view -f "PASS" -e 'INFO/IMPRECISE=1' -T ${ref_wgs_call_bed} -O z -o ${sv_vcf} ${sv_filter_bcf}

EOF
	else
		cat >> ${call_sh} << EOF
## SV BCF to SV VCF
${bcftools} view -f "PASS" -e 'INFO/IMPRECISE=1' -T ${ref_wgs_call_bed} -O z -o ${sv_vcf} ${sv_merge_bcf}

EOF
	fi
else
	cat >> ${call_sh} << EOF
## SV BCF to SV VCF
${bcftools} view -f "PASS" -e 'INFO/IMPRECISE=1' -T ${ref_wgs_call_bed} -O z -o ${sv_vcf} ${call_sv_bcf_dir}/${report_sample_name}_call.bcf

EOF
fi

cat >> ${call_sh} << EOF
## SV Properties
${svprops} ${sv_vcf} > ${sv_props_stats}

## SV Sample Properties
${sampleprops} ${sv_vcf} > ${sv_sample_stats}

## SV stats
${perl} ${delly_stats} --svprops ${sv_props_stats} --smprops ${sv_sample_stats} --outdir ${call_sv_dir} --prefix ${prefix}

## Bar plot of SV type
${Rscript} ${barplot} --infile ${sv_type} --outdir ${call_sv_stats_dir} --prefix ${prefix}_sv_type --xcol "#Type" --ycol "Count" --limit 0 --xscale 0 --xlab "Type" --ylab "Count" --title "SV" --height 6 --width 8

## Bar plot of SV PSC
${Rscript} ${dodge_barplot} --infile ${sv_psc} --outdir ${call_sv_stats_dir} --prefix ${prefix}_sv_psc --xcol "#Sample_ID" --ycol "HomRef,Het,HomAlt" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "SV" --height 6 --width 8

EOF


## Call CNV
call_cnv_dir="${call_dir}/cnv"
if [ ! -d "${call_cnv_dir}" ]
then
	mkdir ${call_cnv_dir}
fi

call_cnv_root_dir="${call_cnv_dir}/root"
if [ ! -d "${call_cnv_root_dir}" ]
then
	mkdir ${call_cnv_root_dir}
fi

call_cnv_call_dir="${call_cnv_dir}/call"
if [ ! -d "${call_cnv_call_dir}" ]
then
	mkdir ${call_cnv_call_dir}
fi

call_cnv_stats_dir="${call_cnv_dir}/stats"
if [ ! -d "${call_cnv_stats_dir}" ]
then
	mkdir ${call_cnv_stats_dir}
fi

cnv_call_sh="${sh_dir}/cnv_call.sh"
cnv_call_rush="${sh_dir}/cnv_call.rush"
cnv_filter_sh="${sh_dir}/cnv_filter.sh"
cnv_filter_rush="${sh_dir}/cnv_filter.rush"

cnv_psc="${call_cnv_stats_dir}/${prefix}_cnv_psc.txt"

chrom=$(cut -f 1 ${ref_wgs_call_bed} | uniq | xargs)

cat >> ${call_sh} << EOF
## Call CNVs
cat ${bam_list} | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*}
	
	tree_log="${call_cnv_root_dir}/\${sm}_tree.log"
	his_log="${call_cnv_root_dir}/\${sm}_his.log"
	stat_log="${call_cnv_root_dir}/\${sm}_stat.log"
	partition_log="${call_cnv_root_dir}/\${sm}_partition.log"
	call_log="${call_cnv_root_dir}/\${sm}_call.log"

	root="${call_cnv_root_dir}/\${sm}.root"
	cnv_out="${call_cnv_root_dir}/\${sm}_cnvnator.txt"
	
	if [ ! -s "\${cnv_out}" ]
	then
		echo "${cnvnator} -root \${root} -tree \${line} -chrom ${chrom} >\${tree_log} 2>&1 && ${cnvnator} -root \${root} -his ${cnv_bin_size} -chrom ${chrom} -d ${ref_split_dir} >\${his_log} 2>&1 && ${cnvnator} -root \${root} -stat ${cnv_bin_size} -chrom ${chrom} >\${stat_log} 2>&1 && ${cnvnator} -root \${root} -partition ${cnv_bin_size} -chrom ${chrom} >\${partition_log} 2>&1 && ${cnvnator} -root \${root} -call ${cnv_bin_size} -chrom ${chrom} > \${cnv_out} 2>\${call_log}"
	fi
done > ${cnv_call_sh}
cat ${cnv_call_sh} | ${rush} {} -n 1 -j ${cnv_maxproc} -c -C ${cnv_call_rush} --verbose

find ${call_cnv_root_dir} -maxdepth 1 -name "*_cnvnator.txt" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*}
	cnv_out="${call_cnv_root_dir}/\${sm}_cnvnator.txt"
	cnv_call="${call_cnv_call_dir}/\${sm}_cnv_call.txt"

	if [ -s "\${cnv_out}" ] && [ ! -s "\${cnv_call}" ]
	then
		echo "${perl} ${cnvnator_filter} --infile \${cnv_out} --outfile \${cnv_call} --bed ${ref_wgs_call_bed} --evalue ${max_cnv_eval1} --quality ${max_cnv_q0} --minsize ${min_cnv_size} --maxsize ${max_cnv_size}"
	fi
done > ${cnv_filter_sh}
cat ${cnv_filter_sh} | ${rush} {} -n 1 -j ${cnv_maxproc} -c -C ${cnv_filter_rush} --verbose

## CNV stats
${perl} ${cnvnator_stats} --indir ${call_cnv_call_dir} --outfile ${cnv_psc}

## Bar plot of CNV PSC
${Rscript} ${dodge_barplot} --infile ${cnv_psc} --outdir ${call_cnv_stats_dir} --prefix ${prefix}_cnv_psc --xcol "#Sample_ID" --ycol "Deletion,Duplication" --limit 10 --xscale 0 --xlab "Sample ID" --ylab "Count" --title "CNV" --height 6 --width 8
EOF

echo "$(current_time) Command: bash ${call_sh} 2>&1 | tee -a ${call_log}" | tee -a ${log}

bash ${call_sh} 2>&1 | tee -a ${call_log}

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
## Annotation
#####################################################################
echo "$(current_time) 4. Annotation ......"|tee -a ${log}

anno_dir="${output_dir}/4.Annotation"
if [ ! -d "${anno_dir}" ]
then
	mkdir ${anno_dir}
fi

anno_sh="${sh_dir}/4.anno.sh"
anno_log="${sh_dir}/4.anno.log"

if [ -s "${anno_sh}" ]
then
	rm ${anno_sh} ${anno_log}
fi

anno_snp_dir="${anno_dir}/snp"
if [ ! -d "${anno_snp_dir}" ]
then
	mkdir ${anno_snp_dir}
fi

anno_snp_avinput_dir="${anno_snp_dir}/avinput"
if [ ! -d "${anno_snp_avinput_dir}" ]
then
	mkdir ${anno_snp_avinput_dir}
fi

anno_snp_stats_dir="${anno_snp_dir}/stats"
if [ ! -d "${anno_snp_stats_dir}" ]
then
	mkdir ${anno_snp_stats_dir}
fi

snp_avinput_sh="${sh_dir}/snp_avinput.sh"
snp_avinput_rush="${sh_dir}/snp_avinput.rush"

snp_avinput_list="${anno_snp_dir}/${prefix}_snp_avinput.list"
snp_avinput="${anno_snp_dir}/${prefix}_snp.avinput"
snp_anno="${anno_snp_dir}/${prefix}_snp_anno.txt"
#snp_anno="${anno_snp_dir}/${prefix}_snp.${prefix}_multianno.txt"
snp_func_stats="${anno_snp_stats_dir}/${prefix}_snp_function_stats.txt"
snp_exonic_func_stats="${anno_snp_stats_dir}/${prefix}_snp_exonic_function_stats.txt"

#${perl} ${convert2annovar} --format vcf4 --allsample --withfreq --filter pass --outfile ${snp_avinput} ${snp_vcf}

if [ ! -s "${snp_anno}" ]
then
	cat >> ${anno_sh} << EOF
## Convert SNP VCF into ANNOVAR input format
cut -f 1 ${ref_wgs_call_bed} | uniq | while read chr
do
	chr_snp_avinput="${anno_snp_avinput_dir}/${prefix}_\${chr}_snp.avinput"
	if [ ! -s "\${chr_snp_avinput}" ]
	then
		echo "${bcftools} query -f '%CHROM\t%POS\t%POS\t%REF\t%ALT\n' -t \${chr} -o \${chr_snp_avinput} ${snp_vcf}"
	fi
done > ${snp_avinput_sh}
cat ${snp_avinput_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${snp_avinput_rush} --verbose

## Generate SNP avinput list
cut -f 1 ${ref_wgs_call_bed} | uniq | while read chr
do
	echo "${anno_snp_avinput_dir}/${prefix}_\${chr}_snp.avinput"
done > ${snp_avinput_list}

## Combine SNP avinput files
csvtk cat -H -t -T -j ${available_threads} --infile-list ${snp_avinput_list} -o ${snp_avinput}

## Annotate SNP using ANNOVAR
${perl} ${table_annovar} --buildver ${prefix} --outfile ${anno_snp_dir}/${prefix}_snp --protocol refGene --operation g --nastring - --thread ${available_threads} --maxgenethread ${available_threads} --dot2underline --remove ${snp_avinput} ${ref_annovar_dir}

EOF
fi

cat >> ${anno_sh} << EOF
## SNP anno stats
perl ${annovar_stats} --infile ${snp_anno} --outdir ${anno_snp_stats_dir} --prefix ${prefix}_snp

## Pie plot of SNP function stats
${Rscript} ${pieplot} --infile ${snp_func_stats} --outdir ${anno_snp_stats_dir} --prefix ${prefix}_snp_function_stats --xcol "#Func_refGene" --ycol "Count" --limit 0 --title "SNP Function" --height 6 --width 8

## Pie plot of SNP exonic function stats
${Rscript} ${pieplot} --infile ${snp_exonic_func_stats} --outdir ${anno_snp_stats_dir} --prefix ${prefix}_snp_exonic_function_stats --xcol "#ExonicFunc_refGene" --ycol "Count" --limit 0 --title "SNP Exonic Function" --height 6 --width 8

EOF

anno_indel_dir="${anno_dir}/indel"
if [ ! -d "${anno_indel_dir}" ]
then
	mkdir ${anno_indel_dir}
fi

anno_indel_avinput_dir="${anno_indel_dir}/avinput"
if [ ! -d "${anno_indel_avinput_dir}" ]
then
	mkdir ${anno_indel_avinput_dir}
fi

anno_indel_stats_dir="${anno_indel_dir}/stats"
if [ ! -d "${anno_indel_stats_dir}" ]
then
	mkdir ${anno_indel_stats_dir}
fi

indel_avinput_sh="${sh_dir}/indel_avinput.sh"
indel_avinput_rush="${sh_dir}/indel_avinput.rush"

indel_avinput_list="${anno_indel_dir}/${prefix}_indel_avinput.list"
indel_avinput="${anno_indel_dir}/${prefix}_indel.avinput"
indel_anno="${anno_indel_dir}/${prefix}_indel_anno.txt"
indel_func_stats="${anno_indel_stats_dir}/${prefix}_indel_function_stats.txt"
indel_exonic_func_stats="${anno_indel_stats_dir}/${prefix}_indel_exonic_function_stats.txt"

#${perl} ${convert2annovar} --format vcf4 --allsample --withfreq --outfile ${indel_avinput} ${indel_vcf}

#${bioawk} -c vcf -t '{print $chrom,$pos,$pos+length($ref)-1,$ref,$alt}' ${indel_vcf} > ${indel_avinput}

if [ ! -s "${indel_anno}" ]
then
	cat >> ${anno_sh} << EOF
## Convert InDel VCF into ANNOVAR input format
cut -f 1 ${ref_wgs_call_bed} | uniq | while read chr
do
	chr_indel_avinput="${anno_indel_avinput_dir}/${prefix}_\${chr}_indel.avinput"
	if [ ! -s "\${chr_indel_avinput}" ]
	then
		echo "${bcftools} view -t \${chr} ${indel_vcf} | ${perl} ${convert2annovar} --format vcf4 --allsample --withfreq --outfile \${chr_indel_avinput} -"
	fi
done > ${indel_avinput_sh}
cat ${indel_avinput_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${indel_avinput_rush} --verbose

## Generate InDel avinput list
cut -f 1 ${ref_wgs_call_bed} | uniq | while read chr
do
	echo "${anno_indel_avinput_dir}/${prefix}_\${chr}_indel.avinput"
done > ${indel_avinput_list}

## Combine InDel anno files
csvtk cat -H -t -T -j ${available_threads} --infile-list ${indel_avinput_list} -o ${indel_avinput}

## Annotate InDel using ANNOVAR
${perl} ${table_annovar} --buildver ${prefix} --outfile ${anno_indel_dir}/${prefix}_indel --protocol refGene --operation g --nastring - --thread ${available_threads} --maxgenethread ${available_threads} --dot2underline --remove ${indel_avinput} ${ref_annovar_dir}

EOF
fi

cat >> ${anno_sh} << EOF
## InDel anno stats
perl ${annovar_stats} --infile ${indel_anno} --outdir ${anno_indel_stats_dir} --prefix ${prefix}_indel

## Pie plot of InDel function stats
${Rscript} ${pieplot} --infile ${indel_func_stats} --outdir ${anno_indel_stats_dir} --prefix ${prefix}_indel_function_stats --xcol "#Func_refGene" --ycol "Count" --limit 0 --title "InDel Function" --height 6 --width 8

## Pie plot of InDel exonic function stats
${Rscript} ${pieplot} --infile ${indel_exonic_func_stats} --outdir ${anno_indel_stats_dir} --prefix ${prefix}_indel_exonic_function_stats --xcol "#ExonicFunc_refGene" --ycol "Count" --limit 0 --title "InDel Exonic Function" --height 6 --width 8

EOF

anno_sv_dir="${anno_dir}/sv"
if [ ! -d "${anno_sv_dir}" ]
then
	mkdir ${anno_sv_dir}
fi

anno_sv_stats_dir="${anno_sv_dir}/stats"
if [ ! -d "${anno_sv_stats_dir}" ]
then
	mkdir ${anno_sv_stats_dir}
fi

sv_avinput="${anno_sv_dir}/${prefix}_sv.avinput"
sv_anno="${anno_sv_dir}/${prefix}_sv_anno.txt"
sv_func_stats="${anno_sv_stats_dir}/${prefix}_sv_function_stats.txt"

## --otherinfo
if [ ! -s "${sv_anno}" ]
then
	cat >> ${anno_sh} << EOF
## Convert SV into ANNOVAR input format
${perl} ${sv_to_avinput} --infile ${sv_call} --outfile ${sv_avinput}

## Annotate SV using ANNOVAR
${perl} ${table_annovar} --buildver ${prefix} --outfile ${anno_sv_dir}/${prefix}_sv --protocol refGene --operation g --nastring - --thread ${available_threads} --maxgenethread ${available_threads} --dot2underline --remove ${sv_avinput} ${ref_annovar_dir}

EOF
fi

cat >> ${anno_sh} << EOF
## SV anno stats
${perl} ${annovar_stats} --infile ${sv_anno} --outdir ${anno_sv_stats_dir} --prefix ${prefix}_sv

## Pie plot of SV function stats
${Rscript} ${pieplot} --infile ${sv_func_stats} --outdir ${anno_sv_stats_dir} --prefix ${prefix}_sv_function_stats --xcol "#Func_refGene" --ycol "Count" --limit 0 --title "SV Function" --height 6 --width 8

EOF

anno_cnv_dir="${anno_dir}/cnv"
if [ ! -d "${anno_cnv_dir}" ]
then
	mkdir ${anno_cnv_dir}
fi

anno_cnv_avinput_dir="${anno_cnv_dir}/avinput"
if [ ! -d "${anno_cnv_avinput_dir}" ]
then
	mkdir ${anno_cnv_avinput_dir}
fi

anno_cnv_anno_dir="${anno_cnv_dir}/anno"
if [ ! -d "${anno_cnv_anno_dir}" ]
then
	mkdir ${anno_cnv_anno_dir}
fi

anno_cnv_stats_dir="${anno_cnv_dir}/stats"
if [ ! -d "${anno_cnv_stats_dir}" ]
then
	mkdir ${anno_cnv_stats_dir}
fi

cnv_avinput_sh="${sh_dir}/cnv_avinput.sh"
cnv_avinput_rush="${sh_dir}/cnv_avinput.rush"
cnv_anno_sh="${sh_dir}/cnv_anno.sh"
cnv_anno_rush="${sh_dir}/cnv_anno.rush"
cnv_stats_sh="${sh_dir}/cnv_stats.sh"
cnv_stats_rush="${sh_dir}/cnv_stats.rush"
cnv_pieplot_sh="${sh_dir}/cnv_pieplot.sh"
cnv_pieplot_rush="${sh_dir}/cnv_pieplot.rush"

cat >> ${anno_sh} << EOF
## Convert CNV into ANNOVAR input format
find ${call_cnv_call_dir} -maxdepth 1 -name "*_cnv_call.txt" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*_*}
	cnv_avinput="${anno_cnv_avinput_dir}/\${sm}_cnv.avinput"
	if [ -s "\${line}" ] && [ ! -s "\${cnv_avinput}" ]
	then
		echo "${perl} ${cnv_to_avinput} --infile \${line} --outfile \${cnv_avinput}"
	fi
done > ${cnv_avinput_sh}
cat ${cnv_avinput_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${cnv_avinput_rush} --verbose

## Annotate CNV using ANNOVAR
find ${anno_cnv_avinput_dir} -maxdepth 1 -name "*_cnv.avinput" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*}
	cnv_anno="${anno_cnv_anno_dir}/\${sm}_cnv_anno.txt"
	if [ -s "\${line}" ] && [ ! -s "\${cnv_anno}" ]
	then
		echo "${perl} ${table_annovar} --buildver ${prefix} --outfile ${anno_cnv_anno_dir}/\${sm}_cnv --protocol refGene --operation g --nastring - --dot2underline --remove \${line} ${ref_annovar_dir}"
	fi
done > ${cnv_anno_sh}
cat ${cnv_anno_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${cnv_anno_rush} --verbose

## CNV anno stats
find ${anno_cnv_anno_dir} -maxdepth 1 -name "*_cnv_anno.txt" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*_*}
	cnv_function_stats="${anno_cnv_stats_dir}/\${sm}_cnv_function_stats.txt"
	if [ -s "\${line}" ] && [ ! -s "\${cnv_function_stats}" ]
	then
		echo "${perl} ${annovar_stats} --infile \${line} --outdir ${anno_cnv_stats_dir} --prefix \${sm}_cnv"
	fi
done > ${cnv_stats_sh}
cat ${cnv_stats_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${cnv_stats_rush} --verbose

## Pie plot of CNV function stats
find ${anno_cnv_stats_dir} -maxdepth 1 -name "*_cnv_function_stats.txt" -not -empty | while read line
do
	name=\$(basename \${line})
	sm=\${name%_*_*_*}
	if [ -s "\${line}" ]
	then
		echo "${Rscript} ${pieplot} --infile \${line} --outdir ${anno_cnv_stats_dir} --prefix \${sm}_cnv_function_stats --xcol \"#Func_refGene\" --ycol \"Count\" --limit 0 --title \"\${sm} CNV Function\" --height 6 --width 8"
	fi
done > ${cnv_pieplot_sh}
cat ${cnv_pieplot_sh} | ${rush} {} -n 1 -j ${available_threads} -c -C ${cnv_pieplot_rush} --verbose
EOF

echo "$(current_time) Command: bash ${anno_sh} 2>&1 | tee -a ${anno_log}" | tee -a ${log}

bash ${anno_sh} 2>&1 | tee -a ${anno_log}

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
## Report
#####################################################################
echo "$(current_time) 5. Report ......" | tee -a ${log}

report_dir="${output_dir}/5.Report"
if [ ! -d "${report_dir}" ]
then
	mkdir ${report_dir}
fi

report_sh="${sh_dir}/5.report.sh"
report_log="${sh_dir}/5.report.log"

if [ -s "${report_sh}" ]
then
	rm ${report_sh} ${report_log}
fi

project_info_file="${config_dir}/${prefix}_project_info.txt"
report_date=$(date "+%Y-%m-%d")

cat > ${project_info_file} << EOF
合同编号	${contract_number}
项目名称	${project_name}
物种名称	${species_name}
样本数量	${sample_size}
公司名称	${company_name}
报告时间	${report_date}
EOF

src_dir="${report_dir}/src"
if [ ! -d "${src_dir}" ]
then
	mkdir ${src_dir}
fi

table_dir="${src_dir}/table"
if [ ! -d "${table_dir}" ]
then
	mkdir ${table_dir}
fi

image_dir="${src_dir}/image"
if [ ! -d "${image_dir}" ]
then
	mkdir ${image_dir}
fi

thumb_dir="${image_dir}/thumb"
if [ ! -d "${thumb_dir}" ]
then
	mkdir -p ${thumb_dir}
fi

html_dir="${src_dir}/html"
if [ ! -d "${html_dir}" ]
then
	mkdir ${html_dir}
fi

bib_dir="${src_dir}/bib"
if [ ! -d "${bib_dir}" ]
then
	mkdir ${bib_dir}
fi

report_rmd="${report_dir}/report.Rmd"
report_html="${report_dir}/report.html"
report_variable="${report_dir}/report_variable.txt"

## \${report_genome_link}	$(echo ${report_genome_link} | sed 's/\//\\\\\\\//g')
cat > ${report_variable} << EOF
\${project_name}	${project_name}
\${species_name}	${species_name}
\${sample_size}	${sample_size}
\${prefix}	${prefix}
\${report_sample_name}	${report_sample_name}
\${report_genome_name}	${report_genome_name}
\${cut_front_mean_quality}	${cut_front_mean_quality}
\${cut_tail_mean_quality}	${cut_tail_mean_quality}
\${qualified_quality_phred}	${qualified_quality_phred}
\${unqualified_percent_limit}	$(printf "%d%%" ${unqualified_percent_limit})
\${n_base_limit}	${n_base_limit}
\${length_required}	${length_required}
\${density_unit}	${density_unit}
EOF

cat >> ${report_sh} << EOF
## Copy image
cp ${Bin}/src/image/* ${image_dir}
cp ${trim_dir}/${report_sample_name}_trim.png ${image_dir}
cp ${call_snp_stats_dir}/${prefix}_snp_psc.png ${image_dir}
cp ${call_snp_stats_dir}/${prefix}_snp_type.png ${image_dir}
cp ${call_snp_stats_dir}/${prefix}_snp_distribution.png ${image_dir}
cp ${call_indel_stats_dir}/${prefix}_indel_psc.png ${image_dir}
cp ${call_indel_stats_dir}/${prefix}_indel_length.png ${image_dir}
cp ${call_indel_stats_dir}/${prefix}_indel_distribution.png ${image_dir}
cp ${call_sv_stats_dir}/${prefix}_sv_psc.png ${image_dir}
cp ${call_sv_stats_dir}/${prefix}_sv_type.png ${image_dir}
cp ${call_cnv_stats_dir}/${prefix}_cnv_psc.png ${image_dir}
cp ${anno_snp_stats_dir}/${prefix}_snp_function_stats.png ${image_dir}
cp ${anno_snp_stats_dir}/${prefix}_snp_exonic_function_stats.png ${image_dir}
cp ${anno_indel_stats_dir}/${prefix}_indel_function_stats.png ${image_dir}
cp ${anno_indel_stats_dir}/${prefix}_indel_exonic_function_stats.png ${image_dir}
cp ${anno_sv_stats_dir}/${prefix}_sv_function_stats.png ${image_dir}
cp ${anno_cnv_stats_dir}/${report_sample_name}_cnv_function_stats.png ${image_dir}

## Thumbnails
ls ${image_dir}/*.png | while read line
do
	name=\$(basename \${line})
	convert -resize 150x100 \${line} ${thumb_dir}/\${name}
done

## Copy table
cp ${Bin}/src/table/* ${table_dir}
cp ${project_info_file} ${table_dir}/${prefix}_project_info.txt
cp ${sample_file} ${table_dir}/${prefix}_sample_info.txt
${pigz} -dc ${clean_data_dir}/${report_sample_name}_clean_R1.fq.gz | head -4 > ${table_dir}/fastq_format.txt
cp ${trim_stats} ${table_dir}
cp ${qc_stats} ${table_dir}
cp ${map_stats} ${table_dir}
head -51 ${snp_gt} > ${table_dir}/${prefix}_snp_genotype.txt
cp ${snp_psc} ${table_dir}
cp ${snp_density} ${table_dir}
head -51 ${indel_gt} > ${table_dir}/${prefix}_indel_genotype.txt
cp ${indel_psc} ${table_dir}
cp ${indel_density} ${table_dir}
head -51 ${call_sv_dir}/${prefix}_sv_call.txt > ${table_dir}/${prefix}_sv_call.txt
cp ${sv_psc} ${table_dir}
head -51 ${call_cnv_call_dir}/${report_sample_name}_cnv_call.txt > ${table_dir}/${report_sample_name}_cnv_call.txt
cp ${cnv_psc} ${table_dir}
head -51 ${snp_anno} > ${table_dir}/${prefix}_snp_anno.txt
head -51 ${indel_anno} > ${table_dir}/${prefix}_indel_anno.txt
head -51 ${sv_anno} > ${table_dir}/${prefix}_sv_anno.txt
head -51 ${anno_cnv_anno_dir}/${report_sample_name}_cnv_anno.txt > ${table_dir}/${report_sample_name}_cnv_anno.txt

## Copy html
cp ${fastp_dir}/${report_sample_name}_fastp.html ${html_dir}
cp -r ${bamqc_dir}/${report_sample_name}_bamqc ${html_dir}
rm ${html_dir}/${report_sample_name}_bamqc/genome_results.txt
rm -r ${html_dir}/${report_sample_name}_bamqc/raw_data_qualimapReport
cp ${qc_stats_dir}/${prefix}_multiqc_fastp.html ${html_dir}
cp ${map_stats_dir}/${prefix}_multiqc_bamqc.html ${html_dir}

## Copy bibliography
cp ${Bin}/src/bib/reference.bib ${bib_dir}

## Copy R Markdown
cp ${Bin}/src/rmarkdown/report.Rmd ${report_rmd}

## Replace variable in R Markdown
while read line
do
	OLD_IFS="\$IFS"
	IFS=\$'\t'
	var=(\${line})
	IFS="\${OLD_IFS}"
	sed -i "s/\${var[0]}/\${var[1]}/g" ${report_rmd}
done < ${report_variable}

## R Markdown to HTML
${Rscript} ${rmarkdown} --infile ${report_rmd} --outfile ${report_html} --format html_document
EOF

echo "$(current_time) Command: bash ${report_sh} 2>&1 | tee -a ${report_log}" | tee -a ${log}

bash ${report_sh} 2>&1 | tee -a ${report_log}

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
## Result
#####################################################################
echo "$(current_time) 6. Result ......" | tee -a ${log}

result_dir="${output_dir}/6.Result"
if [ ! -d "${result_dir}" ]
then
	mkdir ${result_dir}
fi

result_sh="${sh_dir}/6.result.sh"
result_log="${sh_dir}/6.result.log"

if [ -s "${result_sh}" ]
then
	rm ${result_sh} ${result_log}
fi

result_date=$(date +%F)
result_prefix=$(echo "${project_name}_${result_date}" | sed 's/[\.\+(){} ]/_/g')

project_dir="${result_dir}/${result_prefix}"
if [ ! -d "${project_dir}" ]
then
	mkdir ${project_dir}
else
	rm -r ${project_dir}
fi

if [ "${compute_md5}" = "true" ]
then
	cat >> ${result_sh} << EOF
## Raw Data MD5
if [ ! -s "${rawdata_md5}" ]
then
	md5sum ${raw_data_dir}/*f*q* | awk -F"/" '{print \$1,\$NF}' | awk '{print \$1,\$NF}' > ${rawdata_md5}
fi

## Clean Data MD5
if [ ! -s "${cleandata_md5}" ]
then
	md5sum ${clean_data_dir}/*f*q* | awk -F"/" '{print \$1,\$NF}' | awk '{print \$1,\$NF}' > ${cleandata_md5}
fi

EOF
fi

cat >> ${result_sh} << EOF
## 1.QualityControl
mkdir -p ${project_dir}/1.QualityControl
mkdir -p ${project_dir}/1.QualityControl/info
ln -sf ${project_info_file} ${project_dir}/1.QualityControl/info/${prefix}_project_info.txt
ln -sf ${sample_file} ${project_dir}/1.QualityControl/info/${prefix}_sample_info.txt
mkdir -p ${project_dir}/1.QualityControl/raw_data
ln -sf ${raw_data_dir}/*f*q* ${project_dir}/1.QualityControl/raw_data
ln -sf ${rawdata_md5} ${project_dir}/1.QualityControl/raw_data
mkdir -p ${project_dir}/1.QualityControl/clean_data
ln -sf ${clean_data_dir}/*f*q* ${project_dir}/1.QualityControl/clean_data
ln -sf ${cleandata_md5} ${project_dir}/1.QualityControl/clean_data
mkdir -p ${project_dir}/1.QualityControl/fastp
ln -sf ${fastp_dir}/*fastp.html ${project_dir}/1.QualityControl/fastp
mkdir -p ${project_dir}/1.QualityControl/trim
ln -sf ${trim_dir}/* ${project_dir}/1.QualityControl/trim
mkdir -p ${project_dir}/1.QualityControl/stats
ln -sf ${qc_stats_dir}/*stats.txt ${project_dir}/1.QualityControl/stats
ln -sf ${qc_stats_dir}/*.html ${project_dir}/1.QualityControl/stats

## 2.Mapping
mkdir -p ${project_dir}/2.Mapping
cp -r ${bamqc_dir} ${project_dir}/2.Mapping
rm ${project_dir}/2.Mapping/bamqc/*_bamqc.log
rm ${project_dir}/2.Mapping/bamqc/*_bamqc/genome_results.txt
rm -r ${project_dir}/2.Mapping/bamqc/*_bamqc/raw_data_qualimapReport
mkdir -p ${project_dir}/2.Mapping/stats
ln -sf ${map_stats_dir}/*stats.txt ${project_dir}/2.Mapping/stats
ln -sf ${map_stats_dir}/*.html ${project_dir}/2.Mapping/stats

## 3.Calling
mkdir -p ${project_dir}/3.Calling
### SNP
mkdir -p ${project_dir}/3.Calling/snp
ln -sf ${snp_vcf} ${project_dir}/3.Calling/snp
ln -sf ${snp_gt} ${project_dir}/3.Calling/snp
mkdir -p ${project_dir}/3.Calling/snp/stats
ln -sf ${call_snp_stats_dir}/*_snp_density* ${project_dir}/3.Calling/snp/stats
ln -sf ${call_snp_stats_dir}/*_snp_distribution* ${project_dir}/3.Calling/snp/stats
ln -sf ${call_snp_stats_dir}/*_snp_psc* ${project_dir}/3.Calling/snp/stats
ln -sf ${call_snp_stats_dir}/*_snp_type* ${project_dir}/3.Calling/snp/stats
### InDel
mkdir -p ${project_dir}/3.Calling/indel
ln -sf ${indel_vcf} ${project_dir}/3.Calling/indel
ln -sf ${indel_gt} ${project_dir}/3.Calling/indel
mkdir -p ${project_dir}/3.Calling/indel/stats
ln -sf ${call_indel_stats_dir}/*_indel_density* ${project_dir}/3.Calling/indel/stats
ln -sf ${call_indel_stats_dir}/*_indel_distribution* ${project_dir}/3.Calling/indel/stats
ln -sf ${call_indel_stats_dir}/*_indel_psc* ${project_dir}/3.Calling/indel/stats
ln -sf ${call_indel_stats_dir}/*_indel_length* ${project_dir}/3.Calling/indel/stats
### SV
mkdir -p ${project_dir}/3.Calling/sv
ln -sf ${sv_vcf} ${project_dir}/3.Calling/sv
ln -sf ${sv_call} ${project_dir}/3.Calling/sv
mkdir -p ${project_dir}/3.Calling/sv/stats
ln -sf ${call_sv_stats_dir}/*_sv_psc* ${project_dir}/3.Calling/sv/stats
ln -sf ${call_sv_stats_dir}/*_sv_type* ${project_dir}/3.Calling/sv/stats
### CNV
mkdir -p ${project_dir}/3.Calling/cnv
mkdir -p ${project_dir}/3.Calling/cnv/call
ln -sf ${call_cnv_call_dir}/*_cnv_call.txt ${project_dir}/3.Calling/cnv/call
mkdir -p ${project_dir}/3.Calling/cnv/stats
ln -sf ${call_cnv_stats_dir}/*_cnv_psc* ${project_dir}/3.Calling/cnv/stats

## 4.Annotation
mkdir -p ${project_dir}/4.Annotation
### SNP
mkdir -p ${project_dir}/4.Annotation/snp
ln -sf ${snp_anno} ${project_dir}/4.Annotation/snp
mkdir -p ${project_dir}/4.Annotation/snp/stats
ln -sf ${anno_snp_stats_dir}/*_snp_function_stats* ${project_dir}/4.Annotation/snp/stats
ln -sf ${anno_snp_stats_dir}/*_snp_exonic_function_stats* ${project_dir}/4.Annotation/snp/stats
### InDel
mkdir -p ${project_dir}/4.Annotation/indel
ln -sf ${indel_anno} ${project_dir}/4.Annotation/indel
mkdir -p ${project_dir}/4.Annotation/indel/stats
ln -sf ${anno_indel_stats_dir}/*_indel_function_stats* ${project_dir}/4.Annotation/indel/stats
ln -sf ${anno_indel_stats_dir}/*_indel_exonic_function_stats* ${project_dir}/4.Annotation/indel/stats
### SV
mkdir -p ${project_dir}/4.Annotation/sv
ln -sf ${sv_anno} ${project_dir}/4.Annotation/sv
mkdir -p ${project_dir}/4.Annotation/sv/stats
ln -sf ${anno_sv_stats_dir}/*_sv_function_stats* ${project_dir}/4.Annotation/sv/stats
### CNV
mkdir -p ${project_dir}/4.Annotation/cnv
mkdir -p ${project_dir}/4.Annotation/cnv/anno
ln -sf ${anno_cnv_anno_dir}/*_cnv_anno.txt ${project_dir}/4.Annotation/cnv/anno
mkdir -p ${project_dir}/4.Annotation/cnv/stats
ln -sf ${anno_cnv_stats_dir}/*_cnv_function_stats* ${project_dir}/4.Annotation/cnv/stats

## 5.Report
mkdir -p ${project_dir}/5.Report
cp -r ${report_dir}/* ${project_dir}/5.Report
rm ${project_dir}/5.Report/report.Rmd
rm ${project_dir}/5.Report/*variable.txt
rm -r ${project_dir}/5.Report/src/bib
rm -r ${project_dir}/5.Report/src/table

## Readme
cp ${Bin}/src/table/Readme.txt ${project_dir}
EOF

echo "$(current_time) Command: bash ${result_sh} 2>&1 | tee -a ${result_log}" | tee -a ${log}

bash ${result_sh} 2>&1 | tee -a ${result_log}

echo -e "$(current_time) Done!\n" | tee -a ${log}
#####################################################################

#####################################################################
# End Time
#####################################################################
end_time=$(date "+%Y-%m-%d %H:%M:%S")
end_seconds=$(date --date="${end_time}" +%s)

echo -e "End Time: [${end_time}]\n" | tee -a ${log}

total_elapsed_time=$(elapsed_time ${start_seconds} ${end_seconds})

echo "Total Elapsed Time: [${total_elapsed_time}]" | tee -a ${log}
#####################################################################
