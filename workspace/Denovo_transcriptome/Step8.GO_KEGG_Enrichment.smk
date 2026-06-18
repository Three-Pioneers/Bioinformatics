rule GO_KEGG_Enrichment:
	input:
		Sig_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/Sig_genes_exprData.txt}",
		GO_Function = "analysis/6.Function_anno/2.GO/GO_function_id.txt",
		KEGG_function = "analysis/6.Function_anno/3.KEGG/KEGG_function_id.txt"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/"),
		Sig_GO_Enrichment = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/Sig_GO_Enrichment.txt",
		All_GO_Enrichment = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/All_GO_Enrichment.txt",
		GO_barplot_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_barplot.pdf",
		GO_barplot_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_barplot.png",
		GO_dotplot_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_dotplot.pdf",
		GO_dotplot_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_dotplot.png",
		Sig_KEGG_Enrichment = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/Sig_KEGG_Enrichment.txt",
		All_KEGG_Enrichment = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/All_KEGG_Enrichment.txt",
		KEGG_barplot_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/KEGG_barplot.pdf",
		KEGG_barplot_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/KEGG_barplot.png",
		KEGG_dotplot_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/KEGG_dotplot.pdf",
		KEGG_dotplot_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/KEGG_dotplot.png"
	log:
		"log/8.GO_KEGG_Enrichment/GO_KEGG_Enrichment_{Compare_ID}.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//GO_KEGG_Enrichment.R {input.Sig_genes_exprData} {input.GO_Function} {input.KEGG_function} {output.dir} > {log} 2>&1"


rule pathview:
	input:
		Sig_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/Sig_genes_exprData.txt}",
		Sig_KEGG_Enrichment = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/Sig_KEGG_Enrichment.txt",
		Enrichment_KEGG = "analysis/6.Function_anno/3.KEGG/Enrichment_KEGG_id.txt",
		choice_1 = "KEGG",
		choice_2 = "ko"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/Pathway")	# 输出 ko123456.{pathway.png,png,xml}
	log:
		"log/8.GO_KEGG_Enrichment/pathview_{Compare_ID}.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//pathview.R {input.Sig_genes_exprData} {input.Sig_KEGG_Enrichment} {input.Enrichment_KEGG} {input.choice_1} {input.choice_2} {output.dir} > {log} 2>&1"


rule circlize_input:
	input:
		Sig_GO_Enrichment = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/Sig_GO_Enrichment.txt",
		Sig_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/Sig_genes_exprData.txt}"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}"),
		GO_circlize_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_circlize_input.txt"
	log:
		"log/8.GO_KEGG_Enrichment/circlize_input_{Compare_ID}.log"
	threads: 1
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//circlize_input.py {input.Sig_GO_Enrichment} {input.Sig_genes_exprData} {output.dir} > {log} 2>&1"


rule circlize_plot:	# 这图真牛；修改脚本，同时生成 png，而不是再加一条命令
	input:
		GO_circlize_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_circlize_input.txt"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}"),
		GO_circlize_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_circlize.pdf",
		GO_circlize_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/8.GO_KEGG_Enrichment/{Compare_ID}/GO_circlize.png"
	log:
		"log/8.GO_KEGG_Enrichment/circlize_plot_{Compare_ID}.log"
	threads: 1
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//circlize.R {input.GO_circlize_input} {output.dir} > {log} 2>&1"