fastp --in1 WR241371D_R1.fq.gz --in2 WR241371D_R2.fq.gz \
    --out1 clean_WR241371D_R1.fq.gz --out2 clean_WR241371D_R2.fq.gz \
    --detect_adapter_for_pe --json qc_WR241371D.json --html qc_WR241371D.html \
    --thread 8

fastp --in1 WR241372D_R1.fq.gz --in2 WR241372D_R2.fq.gz --out1 clean_WR241372D_R1.fq.gz --out2 clean_WR241372D_R2.fq.gz --detect_adapter_for_pe --json qc_WR241372D.json --html qc_WR241372D.html --thread 8

md5sum WR241371D_R* > raw_md5sum.txt 
md5sum WR241372D_R* >> raw_md5sum.txt

multiqc --outdir /mnt/e/data/training_qc/clean/ /mnt/e/data/training_qc