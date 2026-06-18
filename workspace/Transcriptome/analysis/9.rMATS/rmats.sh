echo '/mnt/e/data/training/Transcriptome/analysis//2.Mapping//hisat2_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260145T/hisat2_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260146T/hisat2_sorted.bam' > /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia//treat.list
echo '/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260141T/hisat2_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260142T/hisat2_sorted.bam' > /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia//control.list

/home/zhangxuejie/miniconda3/envs/rmats/bin/python  \
        /home/zhangxuejie/miniconda3/envs/rmats/bin/rmats.py \
        --b1 treat.list --b2 control.list \
        --gtf ../../ref/Mus_musculus.GRCm39.115.chr.gtf* \
        --od ./ \
        -t paired  --readLength 149 --nthread 12 \
        --tmp ./tmp

# --b1 第一组所有样本的 bam
# --b2 第二组所有样本的 bam
rmats2sashimiplot   --b1 /mnt/e/data/training/Transcriptome/analysis//2.Mapping//hisat2_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260145T/hisat2_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260146T/hisat2_sorted.bam \
                    --b2 /mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260141T/hisat2_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260142T/hisat2_sorted.bam \
                    -t SE -e /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia//SE.MATS.JC.txt \
                    -l1 PRPP --l2 Hypoxia -o /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia/
