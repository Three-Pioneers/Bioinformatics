rule Trinity:	# 分别整合所有样本 R1，R2 的 reads，再重新生成 contig、划分图结构并生成最终转录本
	input:
		all_clean_R1 = expand("analysis//1.QC/clean/TS11_R1.fq.gz", sample = config["Samples"], separator = ","),
		all_clean_R2 = expand("analysis//1.QC/clean/TS11_R1.fq.gz", sample = config["Samples"], separator = ",")
	output:
		Trinity_dir = directory("analysis/2.Trinity/"),
		Trinity_fasta = "analysis/2.Trinity/Trinity.fasta",
		Trinity_fasta_gene_trans_map = "analysis/2.Trinity/Trinity.fasta.gene_trans_map"	# 第一列为基因（有重复），第二列为基因对应的不同转录本
	log:
		"log/2.Trinity/Trinity.log"
	threads: 40
	shell:
		"Trinity "
		"--seqType fq "
		"--left {input.clean_R1} "
		"--right {input.clean_R2} "
		"--max_memory 100G "
		"--CPU 40 "	# CPU 数非线程数，是不可以添 CPU 实际数而非线程数？
		"--min_contig_length 300 "	# 最小组装 contig，默认 200
		"--output {output.Trinity_dir} "	# output directory
		"--no_normalize_reads "	# 禁用读数归一化？？？
		"--no_salmon "	# 运行完成后不进行转录本定量
		"--min_kmer_cov 2 "	# min count for K-mers to be assembled by Inchworm (default: 1)
		"--max_reads_per_graph 30000 "	# maximum number of reads to anchor within a single graph (default: 200000)
		"--bflyHeapSpaceMax 16G "	# java max heap space setting for butterfly (default: 10G)；感觉可以设置个 100G，qualimap bamqc 使用时由于 java 内存的原因老是报错
		"--bflyCPU 28 "
		"--monitoring "	# 监督，监督啥呀
		"--verbose "	# 冗余的；运行过程中提供 job 的附加状态信息
		"2> {log}"


rule trinity_len_stats_from_map:	# 统计 Transcript 和 Unigene（选定为最长转录本）不同碱基长度区间的数量、总数量以及 N50 length 和 Mean length
	input:
		Trinity_fa = "analysis/2.Trinity//Trinity.fasta",
		gene_map = "analysis/2.Trinity//Trinity.fasta.gene_trans_map"
	output:
		Trinity_stat_dir = directory("analysis/2.Trinity/"),
		length_stats_table = "analysis/2.Trinity/length_stats_table.txt",
		length_bins_bar = "analysis/2.Trinity/length_bins_bar.{picture}, picture = ["png", "pdf"]"
	log:
		"log/2.Trinity/trinity_len_stats_from_map.log"
	shell:
		"python trinity_len_stats_from_map.py "
		"--fasta {input.Trinity_fa} "
		"--gene_map {input.gene_map} "
		"--outdir {output.Trinity_stat_dir} "
		"> {log} 2>&1"