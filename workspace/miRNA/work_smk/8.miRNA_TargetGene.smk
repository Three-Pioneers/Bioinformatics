# Known_miRNA
rule all_known_miRNA_targetgene:
	input:
		"/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/Known_miRNA/D7_vs_D1/Sig_genes_exprData.txt",
		"/data3/Data_all/Databases/starbase/hg38_all.txt"
	output:
		all_TargetGene="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt"
	log:
		"log/to/log"
	script:
		"""
		all_known_miRNA_targetgene.py 2> {log}
		"""


rule data_process:
	input:
		all_TargetGene="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt"
	output:
		sig_TargetGene="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt",
		TargetGene_id="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/3.TargetGene_id"
	shell:
		"""
		awk -F'\t' 'NR==1 || ($9> 0 && $10> 0)' {input.all_TargetGene} > {output.sig_TargetGene} \
		awk -F'\t' 'NR==1 { print "id"; next }{print$2}' {output.sig_TargetGene} \
		| awk 'NR==1 || !seen[$0]++' > {output.TargetGene_id}
		"""


rule add_anno:	# 加注释，包括 All 和 Sig 的
	input:
		TargetGene="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt",
		gene_descript="/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_descript.txt",
		id_name_all="/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/Functional_annotation//12.stats/stats_id_name_all.txt"
	output:
		all_TargetGene_anno="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_add_anno.txt"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//add_anno.py
		"""


# Novel_miRNA
rule data_process_2:
	input:
		a="/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/Novel_miRNA/D7_vs_D1/Sig_genes_exprData.txt",
		b="/data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction//2.express/miRNA_mature_seq.fa",
		c="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//sig_miRNA_mature_seq.fa"
	output:
		A="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//sig_miRNA_mature_seq.fa",
		dir="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split/",
		miranda="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//miranda.sh",
		all_txt="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//*_out.txt",
		all_TargetGene="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt"
	shell:
		"""
		cut -f1 {input.a} \
		seqtk subseq {input.b} \
		seqkit seq -w 0 {output.A} \
		seqkit split2 {input.c} -p 40 -j 40 -O {output.dir} \
		rush {} {output.miranda} -j 40 \
		grep '^>[^>]' {output.all_txt} \
		| awk -F'>' '{print$2}' \
		| sed '1i\miRNA\tgene\tScore\tEnergy\tQ_start_end\tR_start_end\tAlign_Length\tIdentity\tSeed_Match' > {output.all_TargetGene}
		"""


rule gene_id_name:
	input:
		all_TargetGene="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt",
		gene_name="/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_name.txt"
	output:
		all_TargetGene_id_name="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_id_name.txt"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//gene_id_name.py
		"""


rule data_process3:
	input:
		all_TargetGene_id_name="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_id_name.txt"
	output:
		sig_TargetGene="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt",
		TargetGene_id="/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/3.TargetGene_id"
	shell:
		"""
		awk -F'\t' 'BEGIN{OFS="\t"} NR==1{print; next} {percent=$NF; sub(/%$/,"",percent); if($3>140 && $4<-15 && percent>90) {print $0}}' {input.all_TargetGene_id_name} {output.sig_TargetGene} \
		tail -n +2 {output.sig_TargetGene} \
		| cut -f 2 |sort -u | sed '1i\id' > {output.TargetGene_id}
		"""


rule add_anno:
	input:
		"/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt",
		"/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_descript.txt",
		"/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/Functional_annotation//12.stats/stats_id_name_all.txt",
		"/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt"
	output:
		"/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_add_anno.txt",
		"/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene_add_anno.txt"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//add_anno.py
		"""
