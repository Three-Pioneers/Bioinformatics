#Known_miRNA
#D7_vs_D1
python /data3/Data_all/script/miRNA/bin//all_known_miRNA_targetgene.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/Known_miRNA/D7_vs_D1/Sig_genes_exprData.txt \
	/data3/Data_all/Databases/starbase/hg38_all.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt

cat /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt | \
	awk -F'\t' 'NR==1 || ($9> 0 && $10> 0)' >\
	 /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt

cat /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt | \
	awk -F'\t' 'NR==1 { print "id"; next }{print$2}' | \
	awk 'NR==1 || !seen[$0]++' >\
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/3.TargetGene_id

python /data3/Data_all/script/miRNA/bin//add_anno.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt \
	/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_descript.txt \
	/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/Functional_annotation//12.stats/stats_id_name_all.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_add_anno.txt

python /data3/Data_all/script/miRNA/bin//add_anno.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt \
	/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_descript.txt \
	/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/Functional_annotation//12.stats/stats_id_name_all.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Known_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene_add_anno.txt
#Novel_miRNA
#D7_vs_D1

cut -f1 /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis/Novel_miRNA/D7_vs_D1/Sig_genes_exprData.txt | \
	seqtk subseq /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction//2.express/miRNA_mature_seq.fa | \
	seqkit seq -w 0 > /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//sig_miRNA_mature_seq.fa

seqkit split2 /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//sig_miRNA_mature_seq.fa \
	-p 40 -j 40 -O /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split/

cat /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//miranda.sh | \
	/data3/Data_all/Software/Rush/rush {} -j 40

grep '^>[^>]'  /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/0.split//*_out.txt | \
	awk -F'>' '{print$2}' | \
	sed '1i\miRNA\tgene\tScore\tEnergy\tQ_start_end\tR_start_end\tAlign_Length\tIdentity\tSeed_Match' >\
	 /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt

python /data3/Data_all/script/miRNA/bin//gene_id_name.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt \
	/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_name.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_v1.txt && \
	mv /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_v1.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt

awk -F'\t' 'BEGIN{OFS="\t"} NR==1{print; next} {percent=$NF; sub(/%$/,"",percent); if($3>140 && $4<-15 && percent>90) {print $0}}' \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt >\
	 /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt

tail -n +2 /data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt | \
	cut -f 2 |sort -u | sed '1i\id' >\
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/3.TargetGene_id

python /data3/Data_all/script/miRNA/bin//add_anno.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene.txt \
	/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_descript.txt \
	/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/Functional_annotation//12.stats/stats_id_name_all.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/1.all_miRNA_TargetGene_add_anno.txt

python /data3/Data_all/script/miRNA/bin//add_anno.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene.txt \
	/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/gene_descript.txt \
	/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/Functional_annotation//12.stats/stats_id_name_all.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//8.miRNA_TargetGene//Novel_miRNA//D7_vs_D1/2.sig_miRNA_TargetGene_add_anno.txt