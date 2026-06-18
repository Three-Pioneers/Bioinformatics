rule bowtie2_build:
	input:
		"analysis/3.TransDecoder/renamed/Trinity.renamed.fasta"
	output:
		directory("analysis/3.TransDecoder/index_bowtie2/")
	log:
		"log/4.Mapping/bowtie2_index.log"
	threads: 40
	shell:
		"bowtie2-build {input} {output}/index > {log} 2>&1"


rule bowtie2:
	input:
		index = "analysis/3.TransDecoder/index_bowtie2/",
		clean_R1 = "analysis//1.QC/clean/{sample}_R1.fq.gz",
		clean_R2 = "analysis//1.QC/clean/{sample}_R2.fq.gz"
	output:
		sam = temp("analysis/4.Mapping/{sample}/{sample}.sam")
	log:
		"log/4.Mapping/bowtie2_mapping_{sample}.log"
	threads: 40
	shell:
		"bowtie2 "
		"-x {input.index}/index "
		"-1 {input.clean_R1} "
		"-2 {input.clean_R2} "
		"-S {output.sam} "
		"> {log} 2>&1"


rule samtools:
	input:
		sam = "analysis/4.Mapping/{sample}/{sample}.sam",
	output:
		bam = "analysis/4.Mapping/{sample}/{sample}_sorted.bam",
		bai = "analysis/4.Mapping/{sample}/{sample}_sorted.bam.bai",
	log:
		"log/4.Mapping/samtools_{sample}.log"
	threads: 40
	shell:
		"""
		(samtools view -Sb {input.sam} | \
		samtools sort -@ {threads} -o {output.bam} && \
		samtools index {output.bam} )> {log} 2>&1
		"""


rule bowtie2_stats:
	input:
		all_bowtie2_mapping_log = expand("log/4.Mapping/bowtie2_mapping_{sample}.log", sample = config["Samples"], separator = ",")
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//4.Mapping"),
		bowite2_stats = "analysis//4.Mapping/mapping_stats.txt"
	log:
		"log/4.Mapping/bowtie2_stats.log"
	threads: 1
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin/mapping_stats.py "
		"{input.all_bowtie2_mapping_log} "
		"{output.dir} "
		"> {log} 2>&1"