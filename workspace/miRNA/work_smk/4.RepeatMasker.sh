RepeatMasker  -pa 10 -engine nhmmer -qq  -xsmall -norna \
    -dir /data3/2026_04/LiPeng_6_human_miRNA/analysis//4.RepeatMasker/D1 \
    -species 9606  \
    analysis//3.ncRNA_classification/5.piRNA/1.mapping/D1_unmapping.fa
python /data3/Data_all/script/miRNA/bin//Repeat_stat.py \
    analysis//3.ncRNA_classification/5.piRNA/1.mapping/D1_unmapping.fa \
    analysis//4.RepeatMasker/D1/D1_unmapping.fa.out \
    analysis//4.RepeatMasker/D1
Rscript /data3/Data_all/script/miRNA/bin//Repeat_plot.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//4.RepeatMasker/D1/Repeat_stat.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//4.RepeatMasker/D1