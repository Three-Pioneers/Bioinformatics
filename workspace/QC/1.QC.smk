configfile: "haha.yaml"

rule fastp:
    input:
        R1="data/{sample}_R1.fq.gz",
        R2="data/{sample}_R2.fq.gz"
    output:
        R1="analysis/clean/{sample}_R1.fq.gz",
        R2="analysis/clean/{sample}_R2.fq.gz",
        json="analysis/json/{sample}.json",
        html="analysis/html/{sample}.html"
    log:
        "log/1.fastp/{sample}.log"
    threads: 12
    shell:
        "fastp "
        "--in1 {input.R1} "
        "--in2 {input.R2} "
        "--out1 {output.R1} "
        "--out2 {output.R2} "
        "--detect_adapter_for_pe --thread {threads} "
        "--json {output.json} "
        "--html {output.html} "
        "2> {log}"

rule multiqc_fastp:
    input:
        json=expand("analysis/json/{sample}.json", sample=config["samples"])
    output:
        "stats/multiqc_fastp.html"
    log:
        "log/1.fastp/multiqc.log"
    shell:
        "multiqc {input.json} --filename multiqc_fastp --outdir stats/ 2> {log}"