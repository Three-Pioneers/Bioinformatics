rule mapper:
    input:
        "analysis//4.RepeatMasker/D1/Repeat_unmapped.fa"
    output:
        "analysis//5.Known_miRNA_identification/1.quantifier/{sample}/mapped.fa"    # 序列号奇怪
    log:
        "log/identification_Known/{sample}_mapper.log"
    shell:
        "mapper.pl "    # 原始测序数据的预处理和基因组比对
        "-c {input} "   # fastq format
        "-m "   # 合并相同的 reads
        "-l 15 "    # 过滤长度小于15bp的reads
        "-r 10 "    # 允许在基因组上map最多的reads数量
        "-s {output} "  # print processed reads to this file
        "2> {log}"


rule quantifier:
    input:
        hairpin="/data3/Data_all/Databases/miRBase/hsa_hairpin.fa",
        mature="/data3/Data_all/Databases/miRBase/hsa_mature.fa",
        fa="analysis//5.Known_miRNA_identification/1.quantifier/D1/mapped.fa"
    output:
        "path/to/output"
    log:
        "log/identification_Known/{sample}_quantifier.log"
    shell:
        "quantifier.pl "    # 已知miRNA的表达定量
        "-p {input.hairpin} "   # miRBase数据库中前体miRNA序列
        "-m {input.mature} "    # miRBase数据库中的miRNA序列
        "-r {input.fa} "    # 待定量fa序列
        "-g 3 " # 比对到前体时允许的不匹配数，默认：1
        "-t hsa "   # species
        "-y test "  # 时间，可选参数，否则将生成新的时间
        "-d "   # 不产生 pdf，应该加
        "2> {log}"


rule unmapped_miRNA_split:  # fa 序列号和 arf 的第一列比对，有交集就是 map，没交集就是 unmap
    input:
        map="analysis//5.Known_miRNA_identification/1.quantifier/{sample}/mapped.fa",
        arf="analysis//5.Known_miRNA_identification/1.quantifier/{sample}/expression_analyses/expression_analyses_test/mapped.fa_mapped.arf"
    output:
        map_mi="analysis/5.Known_miRNA_identification/1.quantifier/{sample}/mappend_miRNA.fa",
        unmap_mi="analysis/5.Known_miRNA_identification/1.quantifier/{sample}/unmappend_miRNA.fa"
    script:
        """
        /data3/Data_all/script/miRNA/bin//unmapped_miRNA_split.py
        """


rule miRNAs_expressed_stats_one_sample:	# 找到比对上的miRNA的序列，和前提序列，并统计
    input:
        all_sample="analysis//5.Known_miRNA_identification/1.quantifier/test/miRNAs_expressed_all_samples_test.csv",
        hairpin="/data3/Data_all/Databases/miRBase/hsa_hairpin.fa",
        mature="/data3/Data_all/Databases/miRBase/hsa_mature.fa",
    output:
        dir="analysis//5.Known_miRNA_identification/1.quantifier/test",
        result="analysis/5.Known_miRNA_identification/1.quantifier/test/miRNAs_expressed_result.txt"
    script:
        """
        /data3/Data_all/script/miRNA/bin//miRNAs_expressed_stats_one_sample.py
        """


rule PCA:
    input:
        count="analysis/5.Known_miRNA_identification/2.express/count.txt",
        sample_info="analysis//report/src/table/sample_info.txt",
        quanlity="COUNT"
    output:
        dir="analysis//5.Known_miRNA_identification/2.express",
        "PCA_png",
        "PCA_pdf",
        "PCA_3D_png",
        "PCA_3D_pdf"
    script:
        """
        /data3/Data_all/script/miRNA/bin//PCA.R
        """


rule violin:
    input:
        count="analysis/5.Known_miRNA_identification/2.express/count.txt",
        sample_info="analysis//report/src/table/sample_info.txt",
        quanlity="COUNT"
    output:
        dir="analysis//5.Known_miRNA_identification/2.express",
        "violin_png",
        "violin_pdf"
    script:
        """
        /data3/Data_all/script/miRNA/bin//violin.R
        """


rule Cor:
    input:
        count="analysis/5.Known_miRNA_identification/2.express/count.txt",
        quanlity="COUNT"
    output:
        dir="analysis//5.Known_miRNA_identification/2.express",
        "cor_png",
        "cor_pdf"
    script:
        """
        /data3/Data_all/script/miRNA/bin//cor.R
        """
! 将quanlity 换成RPM，同时count里也换成RPM.txt