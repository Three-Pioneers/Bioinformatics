rule bowtie_mapping_genome:
	input:
		clean="analysis/1.QC/clean/{sample}.fq.gz",
		index="ref/index_bowtie"
	output:
		sam=temp("analysis/2.Mapping/sort/{sample}.sam"),
		align_fq=temp("analysis/2.Mapping/sort/{sample}_mapped.fq")
	log:
		"log/2.Mapping/bowtie_{sample}.log"
	threads: 12
	shell:
		"bowtie "
		"-x {input.index}/index "
		"-q {input.clean} "
		"--al {output.align_fq} "	# write aligned reads/pairs to file
		"-S {output.sam} "	# write hits in SAM format
		"-p {threads} "
		"> {log} 2>&1"


rule samtools:
	input:
		sam="analysis/2.Mapping/sort/{sample}.sam"
	output:
		bam="analysis/2.Mapping/sort/{sample}_sorted.bam",
		bai="analysis/2.Mapping/sort/{sample}_sorted.bam.bai"	# 如果基因组过长，建立不了 bai 索引，可建立 cai 索引，加参数 -c
	log:
		"log/2.Mapping/samtools_{sample}.log"
	threads: 12
	shell:
		"""
		(samtools sort -@ {threads} -O bam {input.sam} -o {output.bam} && \
		samtools index -@ {threads} {output.bam} -o {output.bai}) > {log} 2>&1
		"""


rule fq_to_fa:
	input:
		align_fq="analysis/2.Mapping/sort/{sample}_mapped.fq"
	output:
		align_fa="analysis/2.Mapping/sort/{sample}_mapped.fa"
	shell:
		"seqkit fq2fa {input.align_fq} -o {output.align_fa}"


rule qualimap:
	input:
		bam="analysis/2.Mapping/sort/{sample}_sorted.bam"
	output:
		"analysis/2.Mapping/bamqc/{sample}_bamqc/genome_results.txt",
		"analysis/2.Mapping/bamqc/{sample}_bamqc/qualimapReport.html"
	log:
		"log/2.Mapping/qualimap_{sample}.log"
	params:
		outdir="analysis/2.Mapping/bamqc/{sample}_bamqc/"
	shell:
		"qualimap --java-mem-size=8G bamqc -bam {input.bam} -outdir {params.outdir} > {log} 2>&1"	# 设置 java 堆内存最大值


rule multiqc_bam:
	input:	# 还有其他，不确定了
		expand("analysis/2.Mapping/bamqc/{sample}_bamqc/genome_results.txt", sample=config["Samples"]),
		expand("analysis/2.Mapping/bamqc/{sample}_bamqc/raw_data_qualimapReport/coverage_histogram.txt", sample=config["Samples"])
	output:
		directory("analysis/2.Mapping/stats/multiqc_data/"),
		"analysis/2.Mapping/stats/multiqc_report.html"
	log:
		"log/2.Mapping/multiqc_bam.log"
	params:
		indir=expand("analysis/2.Mapping/bamqc/{sample}_bamqc/", sample=config["Samples"]),
		outdir="analysis/2.Mapping/stats/"
	shell:
		"multiqc {params.indir} --outdir {params.outdir} > {log} 2>&1"


rule stats_bamqc:	# 提取所有样本 genome_results.txt 的 all reads、mapped reads、mean mapping quality
	input:
		expand("analysis/2.Mapping/bamqc/{sample}_bamqc/genome_results.txt", sample=config["Samples"])
	output:
		"analysis/2.Mapping/stats/Statistic_Mapping.txt"
	params:
		indir="analysis/2.Mapping/bamqc/",
		outdir="analysis/2.Mapping/stats/"
	log:
		"log/2.Mapping/stats_bamqc_py.log"
	shell:
		"python work_smk/Script/statistic_mapping.py --bamqc_dir {params.indir} --output {params.outdir} > {log} 2>&1"


"""
rule build_ref:
	input:
		"ref/Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
	output:
		"ref/ATAC_index/ATAC_index.1.ebwt*",
		dir=""
	log:
		"log/2.Mapping/build_ref.log"
	threads: 12
	shell:
		"bowtie-build {input} {output.dir} "
		"--threads {threads} > {log} 2>&1"
"""