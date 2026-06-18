rule bowtie_tRNA:
    input:
        ref="ref/Rfam/tRNA",
        fq="analysis/3.ncRNA_classification/1.rRNA/1.mapping/{sample}_unmapping.fa"
    output:
        align="analysis/3.ncRNA_classification/2.tRNA/1.mapping/{sample}_mapping.fa",
        sam="analysis/3.ncRNA_classification/2.tRNA/1.mapping/{sample}_mapping.sam",
        un_align="analysis/3.ncRNA_classification/2.tRNA/1.mapping/{sample}_unmapping.fa"
    log:
        "log/ncRNA/tRNA_{sample}_bowtie.log"
    threads: 12
    shell:
        "bowtie "
        "-f {input.fq} "
        "-x {input.ref} "
        "--un {output.un_align} "
        "--al {output.align} "
        "-S {output.sam} " 
        "-v 1 -p {threads} 2> {log}"


rule samtools:
    input:
        sam="analysis/3.ncRNA_classification/2.tRNA/1.mapping/{sample}_mapping.sam",
    output:
        bam="analysis/3.ncRNA_classification/2.tRNA/1.mapping/{sample}_mapping_sorted.bam",
        index="analysis/3.ncRNA_classification/2.tRNA/1.mapping/{sample}_mapping_sorted.bam.bai",
        count="analysis/3.ncRNA_classification/2.tRNA/1.mapping/D1_mapping_count.txt"
    log:
        "log/ncRNA/tRNA_{sample}_samtools.log"
    threads: 12
    shell:
        """
        samtools view -@ {threads} -Sb {input} | \
        samtools sort -@ {threads} -o {output.bam} && \
        samtools index -@ {threads} {output.bam} && \
        samtools idxstats -@ {threads} {output.index} > {output.count} 2> {log}
        """


rule ncRNA_count_stats:
    input:
        "analysis/3.ncRNA_classification/2.tRNA/1.mapping"
    output:
        "analysis/3.ncRNA_classification/2.tRNA/2.quantify"
    script:
        """
        ncRNA_count_stats.py
        """


rule ncRNA_count_stats_plot:
    input:
        "analysis/3.ncRNA_classification/2.tRNA/2.quantify/count.txt"
    output:
        "analysis/3.ncRNA_classification/2.tRNA/2.quantify"
    script:
        """
        ncRNA_count_stats_plot.py
        """


rule PCA:
    input:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/2.tRNA/2.quantify/count.txt",
        "sample_info.txt",
        "count"
    output:
        "path/to/output"
    script:
        """
        PCA.R
        """


rule violin:
    input:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/2.tRNA/2.quantify/count.txt",
        "sample_info.txt",
        "count"
    output:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/2.tRNA/2.quantify"
    script:
        """
        violin.R
        """


rule cor:
    input:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/2.tRNA/2.quantify/count.txt",
        "count"
    output:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/2.tRNA/2.quantify"
    script:
        """
        cor.R
        """