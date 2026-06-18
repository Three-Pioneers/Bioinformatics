rule bowtie_rRNA:
	input:
		rRNA_ref="ref/Rfam",
		align_fa="analysis/2.Mapping/sort/{sample}_mapped.fa"
	output:
		align="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_mapping.fa",
		sam="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_mapping.sam",
		un_align="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_unmapping.fa"
	log:
		"log/3.ncRNA_classification/1.rRNA/{sample}_bowtie.log"
	threads: 12
	shell:
		"bowtie "
		"-f {input.align_fa} "	# query input files are (multi-)FASTA .fa/.mfa
		"-x {input.rRNA_ref}/rRNA "
		"--un {output.un_align} "	# write unaligned reads/pairs to file(s)
		"--al {output.align} "	# write aligned reads/pairs to file(s)
		"-S {output.sam} "
		"-v 1 "	# report end-to-end hits <=v mismatches；也就是允许的最大错配数量
		"-p {threads} "
		"> {log} 2>&1"


rule samtools_2:
	input:
		sam="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_mapping.sam"
	output:
		bam="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_mapping_sorted.bam",
		index="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_mapping_sorted.bam.bai",
		mapping_count="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_mapping_count.txt"
	log:
		"log/3.ncRNA_classification/1.rRNA/{sample}_samtools.log"
	threads: 12
	shell:
		"""
		samtools view -@ {threads} -Sb {input} | \
		samtools sort -@ {threads} -o {output.bam} && \
		samtools index -@ {threads} {output.bam} && \
		samtools idxstats -@ {threads} {output.index} > {output.mapping_count} > {log} 2>&1
		"""


rule ncRNA_count_stats:
	input:
		"analysis/3.ncRNA_classification/1.rRNA/1.mapping"
	output:
		dir=directory("analysis/3.ncRNA_classification/1.rRNA/2.quantify"),
		map_count="analysis/3.ncRNA_classification/1.rRNA/2.quantify/count.txt"
	log:
		"log/3.ncRNA_classification/1.rRNA/ncRNA_count_stats.log"
	shell:
		"python work_smk/Script/ncRNA_count_stats.py {input} {output.dir} > {log} 2>&1"


rule ncRNA_count_stats_plot:
	input:
		"analysis/3.ncRNA_classification/1.rRNA/2.quantify/count.txt"
	output:
		directory("analysis/3.ncRNA_classification/1.rRNA/2.quantify")
	log:
		"log/3.ncRNA_classification/1.rRNA/ncRNA_count_stats_plot.log"
	shell:
		"python work_smk/Script/ncRNA_count_stats_plot.py {input} {output} > {log} 2>&1"


rule PCA:
	input:
		"/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/1.rRNA/2.quantify/count.txt",
		"sample_info.txt",
		"count"
	output:
		"path/to/output"
	script:
		"""
		PCA.R
		"""


rule violin:
	input:
		"/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/1.rRNA/2.quantify/count.txt",
		"sample_info.txt",
		"count"
	output:
		"/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/1.rRNA/2.quantify"
	script:
		"""
		violin.R
		"""


rule cor:
	input:
		"/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/1.rRNA/2.quantify/count.txt",
		"count"
	output:
		"/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/1.rRNA/2.quantify"
	script:
		"""
		cor.R
		"""