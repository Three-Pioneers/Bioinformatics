Quantity = ["COUNT", "FPKM", "TPM"]

rule featureCounts:
	input:
		renamed_gff3 = "analysis/3.TransDecoder/renamed/Trinity.renamed.gff3",
		all_sorted_bam = expand("analysis/4.Mapping/{sample}/{sample}_sorted.bam", sample = config["Samples"])
	output:
		featureCounts = "analysis//5.GenesExpress/featureCounts/featureCounts.txt",
		featureCounts_summary = "analysis//5.GenesExpress/featureCounts/featureCounts.txt.summary"
	log:
		"log/5.GenesExpress/featureCounts.log"
	threads: 40
	shell:
		"featureCounts "
		"-a {input.renamed_gff3} "	# Name of an annotation file. GTF/GFF format by default
		"-T {threads} "
		"-g ID "	# Specify attribute type in GTF annotation. gene_id by default
		"-t gene "	# Specify feature type(s) in a GTF annotation. exon by default
		"-p "	# If specified, libraries are assumed to contain paired-end reads；--countReadPairs 是不也应该加上？
		"{input.all_sorted_bam} "
		"-o {output.featureCounts} "
		"> {log} 2>&1"


rule gene_result_stas:
	input:
		featureCounts = "analysis//5.GenesExpress/featureCounts/featureCounts.txt",
	output:
		dir = directory("analysis/5.GenesExpress"),
		COUNT = "analysis/5.GenesExpress/COUNT.txt",
		FPKM = "analysis/5.GenesExpress/FPKM.txt",
		TPM = "analysis/5.GenesExpress/TPM.txt"
	log:
		"log/5.GenesExpress/Normalization.log"
	threads: 1
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//gene_result_stas.py {input} {output.dir} > {log} 2>&1"


rule violin:
	input:
		quantity_txt = "analysis/5.GenesExpress/{Quantity}.txt",
		sample_info = "analysis/report/src/table/sample_info.txt",
		quantity
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//5.GenesExpress")
		violin_pdf = "analysis/5.GenesExpress/{Quantity}_violin.pdf",
		violin_png = "analysis/5.GenesExpress/{Quantity}_violin.png"
	log:
		"log/5.GenesExpress/Violin_{Quantity}.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//violin.R {input.quantity_txt} {input.sample_info} {input.quantity} {output.dir} > {log} 2>&1"


rule cor:
	input:
		quantity_txt = "analysis/5.GenesExpress/{Quantity}.txt",
		quantity
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//5.GenesExpress"),
		cor_pdf = "analysis/5.GenesExpress/{Quantity}_cor.pdf",
		cor_png = "analysis/5.GenesExpress/{Quantity}_cor.png"
	log:
		"log/5.GenesExpress/cor_{Quantity}.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//cor.R {input.quantity_txt} {input.quantity} {output.dir} > {log} 2>&1"