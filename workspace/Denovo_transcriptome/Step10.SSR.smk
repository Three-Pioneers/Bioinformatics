rule trf:
	input:
		renamed_cds = "analysis/3.TransDecoder/renamed/Trinity.renamed.cds.fa"
	output:
		TRF_dat = "Trinity.renamed.cds.fa.2.7.7.80.10.50.500.dat"
	log:
		"log/10.SSR/trf.log"
	threads: 1
	shell:	#  trf File Match Mismatch Delta PM PI Minscore MaxPeriod [options]
		"trf {input} 2 7 7 80 10 50 500 "
		"-d "	# 生成包含详细的重复序列的信息
		"-h "	# 不输出 html
		"> {log} 2>&1"


rule trf_stats:	# 有时间研究下
	input:
		TRF_dat = "Trinity.renamed.cds.fa.2.7.7.80.10.50.500.dat"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/10.SSR"),
		trf_ssr = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/10.SSR/trf_ssr.txt",
		trf_stats = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/10.SSR/trf_stats.txt"
	log:
		"log/10.SSR/trf_stats.log"
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//trf_stats.py {input.TRF_dat} {output.dir} > {log} 2>&1"


rule trf_stats_plot:
	input:
		trf_stats = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/10.SSR/trf_stats.txt"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/10.SSR"),
		trf_stats_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/10.SSR/trf_stats.pdf",
		trf_stats_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/10.SSR/trf_stats.png"
	log:
		"log/10.SSR/trf_stats_plot.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//trf_stats.R {input.trf_stats} {output.dir} > {log} 2>&1"