rule bowtie_piRNA:
    input:
        ref="ref/Rfam/piRNA",
        fq="analysis/3.ncRNA_classification/4.snoRNA/1.mapping/{sample}_unmapping.fa"
    output:
        align="analysis/3.ncRNA_classification/5.piRNA/1.mapping/{sample}_mapping.fa",
        sam="analysis/3.ncRNA_classification/5.piRNA/1.mapping/{sample}_mapping.sam",
        un_align="analysis/3.ncRNA_classification/5.piRNA/1.mapping/{sample}_unmapping.fa"
    log:
        "log/ncRNA/piRNA_{sample}_bowtie.log"
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
        sam="analysis/3.ncRNA_classification/5.piRNA/1.mapping/{sample}_mapping.sam",
    output:
        bam="analysis/3.ncRNA_classification/5.piRNA/1.mapping/{sample}_mapping_sorted.bam",
        index="analysis/3.ncRNA_classification/5.piRNA/1.mapping/{sample}_mapping_sorted.bam.bai",
        count="analysis/3.ncRNA_classification/5.piRNA/1.mapping/D1_mapping_count.txt"
    log:
        "log/ncRNA/piRNA_{sample}_samtools.log"
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
        "analysis/3.ncRNA_classification/5.piRNA/1.mapping"
    output:
        "analysis/3.ncRNA_classification/5.piRNA/2.quantify"
    script:
        """
        ncRNA_count_stats.py
        """


rule ncRNA_count_stats_plot:
    input:
        "analysis/3.ncRNA_classification/5.piRNA/2.quantify/count.txt"
    output:
        "analysis/3.ncRNA_classification/5.piRNA/2.quantify"
    script:
        """
        ncRNA_count_stats_plot.py
        """


rule PCA:
    input:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/5.piRNA/2.quantify/count.txt",
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
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/5.piRNA/2.quantify/count.txt",
        "sample_info.txt",
        "count"
    output:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/5.piRNA/2.quantify"
    script:
        """
        violin.R
        """


rule cor:
    input:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/5.piRNA/2.quantify/count.txt",
        "count"
    output:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/5.piRNA/2.quantify"
    script:
        """
        cor.R
        """


rule rule_name:
    input:
        expand("/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/{ncRNA}/2.quantify/stats.txt")
    output:
        "/mnt/e/data/training/miRNA/analysis/3.ncRNA_classification/stats.txt"
    log:
        "log/to/log"
    threads: 1
    shell:
        """
        cat {input} | awk 'NR==1 || NR==2 || NR==4 || NR==6 || NR==8 || NR==10' > {output}
        """
