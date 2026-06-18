rule hisat2_mapping:
	input:
		"path/to/input"
	output:
		sam=temp("path/to/output")
	params:
		""
	log:
		"log/to/log"
	threads: 20
	shell:
		"hisat2 "
		"--dta "	# reports alignments tailored for transcript assemblers
		"-x {params} "
		"-1 {input.clean_R1} -2 {input.clean_R2} "
		"-S {output.sam} "
		"--summary-file {output.summary} "
		"--threads {threads} 2> {log}"


rule samtools:
	input:
		"path/to/input"
	output:
		"path/to/output"
	log:
		"log/to/log"
	threads: 1
	shell:
		"""
		command {input} {output} 2> {log}
		"""
hisat2 --dta -p 20 -x /Data_all/GenomicDatabases/Homo_sapiens/Ensembl/index_hisat2/index -1 /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//1.QC/clean/AN3CAMOCK_1_R1.fq.gz -2 /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//1.QC/clean/AN3CAMOCK_1_R2.fq.gz -S /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//2.Mapping/AN3CAMOCK_1/hisat2.sam --summary-file /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//2.Mapping/AN3CAMOCK_1/summary.txt
/Data_all/Software/miniconda3/bin/samtools view -@ 4 -Sb /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//2.Mapping/AN3CAMOCK_1/hisat2.sam | /Data_all/Software/miniconda3/bin/samtools sort -@ 4 -o /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//2.Mapping/AN3CAMOCK_1/hisat2_sorted.bam && /Data_all/Software/miniconda3/bin/samtools index /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//2.Mapping/AN3CAMOCK_1/hisat2_sorted.bam
rm -rf /data0_2/2026_06/LiuLu_9_human_PolyA/analysis//2.Mapping/AN3CAMOCK_1/hisat2.sam


rule rule_name:
	input:
		expand("/data0_2/2026_06/LiuLu_9_human_PolyA/analysis//2.Mapping/AN3CAMOCK_1/summary.txt")
	output:
		"path/to/output"
	log:
		"log/to/log"
	script:
		"""
		/Data_all/script/Reference_transcriptome/V1/bin/mapping_stats.py 2> {log}
		"""
