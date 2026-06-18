featureCounts -a ../../ref/Mus_musculus.GRCm39.115.chr.gtf* \
              -o /mnt/e/data/training/Transcriptome/analysis/3.GenesExpress/0.featureCounts/featureCounts.txt \
              -g gene_id  -t exon -T 12 -p \
              /mnt/e/data/training/Transcriptome/analysis/2.Mapping/WR260141T/WR260141T.bam /mnt/e/data/training/Transcriptome/analysis/2.Mapping/WR260142T/WR260142T.bam /mnt/e/data/training/Transcriptome/analysis/2.Mapping/WR260145T/WR260145T.bam /mnt/e/data/training/Transcriptome/analysis/2.Mapping/WR260146T/WR260146T.bam
