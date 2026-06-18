echo '/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260145T/WR260145T_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260146T/WR260146T_sorted.bam' > /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia//treat.list
echo '/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260141T/WR260141T_sorted.bam,/mnt/e/data/training/Transcriptome/analysis//2.Mapping/WR260142T/WR260142T_sorted.bam' > /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia//control.list

/home/zhangxuejie/miniconda3/envs/rmats/bin/python  \
        /home/zhangxuejie/miniconda3/envs/rmats/bin/rmats.py \
        --b1 /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia/treat.list \
        --b2 /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia/control.list \
        --gtf /mnt/e/data/training/Transcriptome/ref/Mus_musculus.GRCm39.115.chr.gtf* \
        --od /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia/ \
        -t paired  --readLength 150 --nthread 12 \
        --tmp /mnt/e/data/training/Transcriptome/analysis/9.rMATS/PRPP_vs_Hypoxia/tmp/