rule soft_link:
	input:
		"/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//4.Mapping/{sample}/{sample}_sorted.bam"
	output:
		"/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/11.Variance_Calling/vcf/{sample}"
	shell:
		"ln -s {input} {output}"


rule bcftools_mpileup:
	input:
		renamed_fasta = "analysis/3.TransDecoder/renamed/Trinity.renamed.fasta",
		all_samples = expand({sample}, sample = config["Samples"])
	output:
		"path/to/output"
	log:
		"log/to/log"
	threads: 1
	shell:
		"bcftools mpileup "
		"-Ou "	# --output-type -u：uncompressed BCF
		"-f {input} "
		"-q 20 "
		"-Q 20 "
		"-d 10000 "
		"-a FORMAT/DP,FORMAT/AD "
		"--threads 40 "
		""
		"{output} > {log} 2>&1"
