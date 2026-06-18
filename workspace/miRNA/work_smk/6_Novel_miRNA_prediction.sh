cat /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1/unmappend_miRNA.fa	\
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D7/unmappend_miRNA.fa	\
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D12/unmappend_miRNA.fa	\
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D16/unmappend_miRNA.fa	\
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D19/unmappend_miRNA.fa	\
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D20/unmappend_miRNA.fa	\
     > /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/all_sample.fa

cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && \
mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/all_sample.fa \
    -c -l 18  -r 100 -m -p /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index  \
    -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_collapsed.fa \
    -t /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_vs_genome.arf
 
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && \
miRDeep2.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_collapsed.fa \
    /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/genome.fa \
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_vs_genome.arf  \
    /data3/Data_all/Databases/miRBase/hsa_mature.fa \
    none /data3/Data_all/Databases/miRBase/hsa_hairpin.fa \
    -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/miRDeep2_output.html -v -t hsa

echo >> /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/result_*.csv  && \
python novel_miRNA_result_stats.py \
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/result_*.csv \
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/test2

cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && \
mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D1/unmappend_miRNA.fa \
    -c -l 18  -r 100 -m -p /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index  \
    -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D1/reads_collapsed.fa \
    -t /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D1/reads_vs_genome.arf 

cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D1 && \
quantifier.pl -p /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa \
    -m /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa \
    -r /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D1/reads_collapsed.fa \
    -y test

python /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py \
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D1/miRNAs_expressed_all_samples_test.csv \
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa \
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa \
    /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D1


cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D7/unmappend_miRNA.fa -c -l 18  -r 100 -m -p /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index  -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D7/reads_collapsed.fa -t /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D7/reads_vs_genome.arf 
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D7 && quantifier.pl -p /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa -m /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa -r /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D7/reads_collapsed.fa -y test
python /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D7/miRNAs_expressed_all_samples_test.csv /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D7
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D12/unmappend_miRNA.fa -c -l 18  -r 100 -m -p /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index  -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D12/reads_collapsed.fa -t /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D12/reads_vs_genome.arf 
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D12 && quantifier.pl -p /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa -m /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa -r /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D12/reads_collapsed.fa -y test
python /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D12/miRNAs_expressed_all_samples_test.csv /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D12
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D16/unmappend_miRNA.fa -c -l 18  -r 100 -m -p /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index  -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D16/reads_collapsed.fa -t /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D16/reads_vs_genome.arf 
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D16 && quantifier.pl -p /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa -m /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa -r /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D16/reads_collapsed.fa -y test
python /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D16/miRNAs_expressed_all_samples_test.csv /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D16
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D19/unmappend_miRNA.fa -c -l 18  -r 100 -m -p /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index  -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D19/reads_collapsed.fa -t /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D19/reads_vs_genome.arf 
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D19 && quantifier.pl -p /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa -m /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa -r /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D19/reads_collapsed.fa -y test
python /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D19/miRNAs_expressed_all_samples_test.csv /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D19
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2 && mapper.pl /data3/2026_04/LiPeng_6_human_miRNA/analysis//5.Known_miRNA_identification/1.quantifier/D20/unmappend_miRNA.fa -c -l 18  -r 100 -m -p /data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index  -s /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D20/reads_collapsed.fa -t /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D20/reads_vs_genome.arf 
cd /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D20 && quantifier.pl -p /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa -m /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa -r /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D20/reads_collapsed.fa -y test
python /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D20/miRNAs_expressed_all_samples_test.csv /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier/D20


python /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_all_sample.py /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/1.quantifier 'D1 D7 D12 D16 D19 D20' /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express

Rscript /data3/Data_all/script/miRNA/bin//PCA.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express/count.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//report/src/table/sample_info.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express COUNT
Rscript /data3/Data_all/script/miRNA/bin//violin.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express/count.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//report/src/table/sample_info.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express COUNT
Rscript /data3/Data_all/script/miRNA/bin//cor.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express/count.txt  /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express COUNT
Rscript /data3/Data_all/script/miRNA/bin//PCA.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express/rpm.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//report/src/table/sample_info.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express RPM
Rscript /data3/Data_all/script/miRNA/bin//violin.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express/rpm.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//report/src/table/sample_info.txt /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express RPM
Rscript /data3/Data_all/script/miRNA/bin//cor.R /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express/rpm.txt  /data3/2026_04/LiPeng_6_human_miRNA/analysis//6.Novel_miRNA_prediction/2.express RPM
