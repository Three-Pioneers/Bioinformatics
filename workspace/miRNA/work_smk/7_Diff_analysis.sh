# Known_miRNA
## D7_vs_D1
python /data3/Data_all/script/miRNA/bin//gfold_diffExprGene.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/2.express/count.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//report/src/table/sample_info.txt  \
	D7 D1 \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1

gfold diff \
	-s1 /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/treat.txt \
	-s2 /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/control.txt \
	-o /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/gfold.diff

python /data3/Data_all/script/miRNA/bin//gfold_trans.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/gfold.diff \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/COUNT.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1

Rscript /data3/Data_all/script/miRNA/bin//MA.R \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/All_genes_exprData.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1

sed '1d' /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/Sig_genes_exprData.txt | \
	sort -g -k 4  |cut -f 1 |head -n 50 |sort -k 1 \
	> /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/tmp_top50.id  

sed '1d' /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/COUNT.txt | \
	sort -k 1 \
	> /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/tmp_COUNT.txt

cat /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/COUNT.txt | \
	head -n 1 > /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/heatmap_input.txt

join --nocheck-order  -t $'\t' -1 1 -2 1  \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/tmp_top50.id \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/tmp_COUNT.txt  \
	>> /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/heatmap_input.txt

Rscript /data3/Data_all/script/miRNA/bin//heatmap.R \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/heatmap_input.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/sample_info.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1

# Novel_miRNA
## D7_vs_D1
python /data3/Data_all/script/miRNA/bin//gfold_diffExprGene.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express/count.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//report/src/table/sample_info.txt  D7 D1 /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1
gfold diff -s1 /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/treat.txt -s2 /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/control.txt -o /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/gfold.diff
python /data3/Data_all/script/miRNA/bin//gfold_trans.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/gfold.diff /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/COUNT.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1
/data3/Data_all/Software/miniconda3/bin/Rscript /data3/Data_all/script/miRNA/bin//MA.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/All_genes_exprData.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1

sed '1d' /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/Sig_genes_exprData.txt | sort -g -k 4  |cut -f 1 |head -n 50 |sort -k 1 > /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/tmp_top50.id  
sed '1d' /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/COUNT.txt |sort -k 1 > /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/tmp_COUNT.txt
cat /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/COUNT.txt|head -n 1 > /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/heatmap_input.txt
join --nocheck-order  -t $'\t' -1 1 -2 1  /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/tmp_top50.id /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/tmp_COUNT.txt  >> /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/heatmap_input.txt
/data3/Data_all/Software/miniconda3/bin/Rscript /data3/Data_all/script/miRNA/bin//heatmap.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/heatmap_input.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/sample_info.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1


# 绘图
python /data3/Data_all/script/miRNA/bin//venn_input.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/D7_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/D12_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/D16_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/D19_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/D20_vs_D1/Sig_genes_exprData.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/

Rscript /data3/Data_all/script/miRNA/bin//venn.R \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//venn_input.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/ 

python /data3/Data_all/script/miRNA/bin//venn_input.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/D7_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/D12_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/D16_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/D19_vs_D1/Sig_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/D20_vs_D1/Sig_genes_exprData.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/

Rscript /data3/Data_all/script/miRNA/bin//venn.R \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//venn_input.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/ 

python /data3/Data_all/script/miRNA/bin/diffExprGene_stats.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D7_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D12_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D16_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D19_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//D20_vs_D1/All_genes_exprData.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/ 

Rscript /data3/Data_all/script/miRNA/bin/diffExprGene_stats.R \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA//diffExprGene_stats_input.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Known_miRNA/

python /data3/Data_all/script/miRNA/bin/diffExprGene_stats.py \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D7_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D12_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D16_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D19_vs_D1/All_genes_exprData.txt,/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//D20_vs_D1/All_genes_exprData.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/ 

Rscript /data3/Data_all/script/miRNA/bin/diffExprGene_stats.R \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA//diffExprGene_stats_input.txt \
	/data3/2026_04/LiPeng_6_human_miRNA/analysis//7.Diff_analysis//Novel_miRNA/
