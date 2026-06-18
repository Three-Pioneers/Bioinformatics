rule GSEA:
	input:
		All_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/All_genes_exprData.txt}",
		GO_Function = "analysis/6.Function_anno/2.GO/GO_function_id.txt",
		Enrichment_KEGG = "analysis/6.Function_anno/3.KEGG/Enrichment_KEGG_id.txt"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/9.GSEA/{Compare_ID}/"),	# 还分别生成 GO KEGG 的 ko编号 十个图，最显著？
		GO_GSEA_all = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/9.GSEA/{Compare_ID}/GO_GSEA_all.txt",
		GO_GSEA_top10_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/9.GSEA/{Compare_ID}/GO_GSEA_top10.pdf",
		GO_GSEA_top10_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/9.GSEA/{Compare_ID}/GO_GSEA_top10.png",
		KEGG_GSEA_all = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/9.GSEA/{Compare_ID}/KEGG_GSEA_all.txt",
		KEGG_GSEA_top10_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/9.GSEA/{Compare_ID}/KEGG_GSEA_top10.pdf",
		KEGG_GSEA_top10_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/9.GSEA/{Compare_ID}/KEGG_GSEA_top10.png"
	log:
		"log/9.GSEA/GSEA_{Compare_ID}.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//GSEA.R {input.All_genes_exprData} {input.GO_Function} {input.Enrichment_KEGG} {output.dir} > {log} 2>&1"