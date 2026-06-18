"""
rule link:
	input:
		fastq="data/{sample}.fq.gz"
	output:
		raw="analysis/1.QC/raw/{sample}.fq.gz"
	shell:
		"ln -s {input.fastq} {output.raw}"
"""


rule fastp:
	input:
		raw="data/{sample}.fq.gz"	# miRNA 都是单端测序数据
	output:
		clean="analysis/1.QC/clean/{sample}.fq.gz",
		json="analysis/1.QC/fastp/{sample}.json",
		html="analysis/1.QC/fastp/{sample}.html"
	log:
		"log/1.QC/fastp_{sample}.log"
	threads: 12
	shell:
		"fastp "
		"--in1 {input.raw} "
		"--out1 {output.clean} "
		"--detect_adapter_for_pe "
		"--thread {threads} "
		"--json {output.json} "
		"--html {output.html} "
		"> {log} 2>&1"


rule multiqc_fastp:
	input:
		"analysis/1.QC/fastp/"
	output:
		directory("analysis/1.QC/stats/")
	log:
		"log/1.QC/multiqc_fastp.log"
	shell:
		"multiqc {input} --filename multiqc_fastp --outdir {output} > {log} 2>&1"