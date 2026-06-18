rule gene_order:
	input:
		COUNT = "analysis/5.GenesExpress/COUNT.txt",
		sample_info = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/report/src/table/sample_info.txt",
		Compare_ID = "TS3_vs_TS1"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/"),
		New_COUNT = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/COUNT.txt",
		New_sample_info = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/sample_info.txt",
	log:
		"log/7.DiffGenes/gene_order_{Compare_ID}.log"
	threads: 1
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//gene_order.py {input.COUNT} {input.sample_info} {input.Comapre_ID} {output.dir}{input.Comapre_ID} > {log} 2>&1"


rule diffExprGene:
	input:
		New_COUNT = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/COUNT.txt",
		New_sample_info = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/sample_info.txt",
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/"),
		All_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/All_genes_exprData.txt}",
		Sig_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/Sig_genes_exprData.txt}"
	log:
		"log/7.DiffGenes/diffExprGene_{Compare_ID}.log"
	threads: 1
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//diffExprGene.R {input.COUNT} {input.sample_info} {output.dir}{input.Comapre_ID} > {log} 2>&1"


rule volcano:
	input:
		All_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/All_genes_exprData.txt}"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/")
	log:
		"log/7.DiffGenes/volcano_{Compare_ID}.log"
	threads: 1
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//volcano.R {input.All_genes_exprData} {output.dir}{input.Comapre_ID} > {log} 2>&1"


rule heatmap_process:
	input:
		Sig_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/Sig_genes_exprData.txt}",
		New_COUNT = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/COUNT.txt",
	output:
		tmp_top50 = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/tmp_top50.id",
		tmp_COUNT = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/tmp_COUNT.txt",
		heatmap_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/{Compare_ID}/heatmap_input.txt"
	log:
		"log/7.DiffGenes/heatmap_process_{Compare_ID}.log"
	shell:
		"""
		(sed '1d' {input.Sig_genes_exprData} | \
		sort -g -k 4 | \
		cut -f 1 | \
		head -n 50 | \
		sort -k 1 > {output.tmp_top50}
		sed '1d' {input.COUNT} | \
		sort -k 1 > {output.tmp_COUNT}
		head -n 1 {input.COUNT} > {output.heatmap_input}
		join --nocheck-order  -t $'\t' -1 1 -2 1 {output.tmp_top50} {output.tmp_COUNT} >> {output.heatmap_input}) > {log} 2>&1
		"""


rule heatmap:
	input:
		heatmap_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/{Compare_ID}/heatmap_input.txt",
		New_sample_info = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/sample_info.txt"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/")
	log:
		"log/7.DiffGenes/heatmap_{Compare_ID}.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//heatmap.R {input.heatmap_input} {input.New_sample_info} {output.dir}{Compare_ID} > {log} 2>&1"


rule venn_input:
	input:
		all_Sig_genes_exprData = expand("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/{Compare_ID}/Sig_genes_exprData.txt", Compare_ID = config["Compare_ID"], separator = ",")
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/"),
		venn_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/venn_input.txt"
	log:
		"log/7.DiffGenes/venn_input.log"
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//venn_input.py {input.all_Sig_genes_exprData} {output.dir} > {log} 2>&1"


rule venn:
	input:
		venn_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/venn_input.txt"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/"),
		venn_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/venn.png",
		venn_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/venn.pdf",
		venn_output = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/venn_output.txt"
	log:
		"log/7.DiffGenes/venn.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin//venn_6.R {input.venn_input} {output.dir} > {log} 2>&1"


rule diffExprGene_stats:
	input:
		all_All_genes_exprData = expand("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/{Compare_ID}/All_genes_exprData.txt", Compare_ID = config["Compare_ID"], separator = ",")
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/"),
		diffExprGene_stats_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/diffExprGene_stats_input.txt",
		diffExprGene_stats = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/diffExprGene_stats.txt"
	log:
		"log/7.DiffGenes/diffExprGene_stats.log"
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin/diffExprGene_stats.py {input.all_All_genes_exprData} {output.dir} > {log} 2>&1"


rule diffExprGene_stats_plot:
	input:
		diffExprGene_stats_input = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/diffExprGene_stats_input.txt"
	output:
		dir = directory("/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/"),
		diffExprGene_stats_png = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes//diffExprGene_stats.png",
		diffExprGene_stats_pdf = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes//diffExprGene_stats.pdf"
	log:
		"log/7.DiffGenes/diffExprGene_stats_plot.log"
	shell:
		"Rscript /data3/Data_all/script/Denovo_transcriptome/bin/diffExprGene_stats.R {input.diffExprGene_stats_input} {output.dir} > {log} 2>&1"


rule Sig_genes_merge:
	input:
		Sig_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/Sig_genes_exprData.txt}"
		New_COUNT = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/COUNT.txt",
		Uniprot_function = "analysis/6.Function_anno/1.Uniprot/Uniprot_function_id.txt"
	output:
		Sig_genes_exprData_merge = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/{Compare_ID}/Sig_genes_exprData_merge.txt"
	log:
		"log/7.DiffGenes/Sig_genes_merge.log"
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//merge.py {input.Sig_genes_exprData} {output.Sig_genes_exprData_merge} {input.New_COUNT} {input.Uniprot_function} > {log} 2>&1"


rule All_genes_merge:
	input:
		All_genes_exprData = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/All_genes_exprData.txt}",
		New_COUNT = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis/7.DiffGenes/{Compare_ID}/COUNT.txt",
		Uniprot_function = "analysis/6.Function_anno/1.Uniprot/Uniprot_function_id.txt"
	output:
		All_genes_exprData_merge = "/data0_2/2026_06/LiuJiaWei_9_shaoyao_Denovo_transcriptome/analysis//7.DiffGenes/{Compare_ID}/All_genes_exprData_merge.txt"
	log:
		"log/7.DiffGenes/All_genes_merge.log"
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//merge.py {input.All_genes_exprData} {output.All_genes_exprData_merge} {input.New_COUNT} {input.Uniprot_function} > {log} 2>&1"