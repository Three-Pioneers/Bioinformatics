rule gfold_diffExprGene:
	input:
		count="/data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/2.express/count.txt",
		sample="/data3/2026_04/LiPeng_6_human_miRNA/analysis//report/src/table/sample_info.txt",
		compare1="D7",
		compare2="D1"
	output:
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1"
		treat="",
		control="",
		COUNT="",
		sample_info=
	script:
		"""
		/data3/Data_all/script/miRNA/bin//gfold_diffExprGene.py
		"""


rule gfold:
	input:
		treat="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/treat.txt",
		control="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/control.txt"
	output:
		"analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/gfold.diff"
	log:
		"log/to/log"
	threads: 1
	shell:
		"gfold diff "
		"-s1 {input.treat} "
		"-s2 {input.control} "
		"-o {output} "
		"2> {log}"


rule gfold_trans:
	input:
		gfold_diff="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/gfold.diff",
		COUNT="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/COUNT.txt"
	output:
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1",
		All_experData="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1//All_genes_exprData.txt",
		Sig_experData="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1//Sig_genes_exprData.txt"	# All_expera 只有上下调得来
	script:
		"""
		/data3/Data_all/script/miRNA/bin//gfold_trans.py
		"""


rule MA:
	input:
		All_experData="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1//All_genes_exprData.txt"
	output:
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1",
		volcano_png="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/volcano.png",
		volcano_pdf="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/volcano.pdf"
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//MA.R 2> {log}
		"""


rule Statistics_Process:	#！
	input:
		Sig_experaData="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/Sig_genes_exprData.txt",
		COUNT="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/COUNT.txt"
	output:
		tmp_id="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/tmp_top50.id",	# 展示 50 个差异最显著的下调基因；这里不对，"sort -g -k 4"，排序应该按照第四列绝对值排序，而不是自然数
		tmp_COUNT="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/tmp_COUNT.txt",
		heatmap_input="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/heatmap_input.txt"
	shell:
		"""
		sed '1d' {input.Sig_experaData} | sort -g -k 4 | cut -f 1 | head -n 50 | sort -k 1 > {output.tmp_id}
		sed '1d' {input.COUNT} | sort -k 1 > {output.tmp_COUNT}
		head -n 1 {input.COUNT} > {output.heatmap_input}
		join --nocheck-order  -t $'\t' -1 1 -2 1 {output.tmp_id} {output.tmp_COUNT} >> {output.heatmap_input}
		"""


rule heatmap:
	input:
		heatmap_input="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/heatmap_input.txt",
		sample_info="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/sample_info.txt"
	output:
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1",
		headmap_png="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/heatmap_pdf",
		heatmap_pdf="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/heatmap_pdf"
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//heatmap.R 2> {log}
		"""


rule Venn_input:
	input:
		expand("/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//{miRNA}/{compare}/Sig_genes_exprData.txt")
	output:
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}"
		venn_input="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/venn.input"
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//venn_input.py
		"""


rule Venn:
	input:
		venn_input="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/venn.input"
	output:
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/",
		venn_pdf="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/venn.pdf",
		venn_png="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/venn.png",
		venn_output="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/venn_output.txt"
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//venn.R 2> {log}
		"""


rule diffExprGene_stats:
	input:
		expand("/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//{miRNA}/{compare}/Sig_genes_exprData.txt")
	output:
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/",
		diffExprGene_stats_input="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/diffExprGene_stats_input.txt"
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin/diffExprGene_stats.py 2> {log}
		"""


rule diffExprGene_plot:
	input:
		diffExprGene_stats_input="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/diffExprGene_stats_input.txt"
	output:
		"/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}/",
		diffExprGene_png="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}//diffExprGene_stats.png",
		diffExprGene_pdf="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/{miRNA}//diffExprGene_stats.pdf"
	log:
		"log/to/log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin/diffExprGene_stats.R 2> {log}
		"""
