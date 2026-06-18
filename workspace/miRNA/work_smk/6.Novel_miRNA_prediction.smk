rule merge_sample_fa:
	input:
		fa=expand("analysis//5.Known_miRNA_identification/1.quantifier/{sample}/unmappend_miRNA.fa"),
		dir="analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2"
	output:
		"analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/all_sample.fa"
	shell:
		"""
		cat {input.fa} > {output}
		cd {input.dir}
		"""


rule mapper:
	input:
		fa="analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/all_sample.fa",
		index="/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index"
	output:
		collapse_fa="analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_collapsed.fa",
		arf="analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_vs_genome.arf"
	log:
		"log/to/log"
	shell:
		"mapper.pl "	# 原始测序数据的预处理和基因组比对
		"-c {input.fa} "	# fastq format
		"-p {input.index} "	# genome index_bowtie
		"-m "	# 合并相同的 reads
		"-l 18 "	# 过滤长度小于18bp的reads；Known=15
		"-r 100 "	# 允许在基因组上map最多的 reads 数量；Known=10
		"-s {output.collapse} "	# 将处理过的 reads 输出文件路径
		"-t {output.arf} "	# 输出比对上 reads 的统计信息表
		"2> {log}"


rule miRDeep2:
	input:
		fa="analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_collapsed.fa",
		genome="/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/genome.fa",
		arf="analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/reads_vs_genome.arf",
		ref="/data3/Data_all/Databases/miRBase/hsa_mature.fa",
		other="none"
		precursors="/data3/Data_all/Databases/miRBase/hsa_hairpin.fa",
	output:
		"analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/miRDeep2_output.html"
	log:
		"log/to/log"
	threads: 1
# miRDeep2.pl reads genome mappings miRNAs_ref/none miRNAs_other/none precursors/none [options]
	shell:
		"miRDeep2.pl "
		"{input.fa} "
		"{input.genome} "
		"{input.arf} "	# file_reads mapped against file_genome. The mappings should be in arf format
		"{input.ref} "	# known mature sequences from miRBase
		"{input.other} "	# known mature sequences for 1-5 species closely related to the species
		"{input.precursors} "
		"-t hsa "
		"-s {output} "	# known miRBase star sequences；公司参数用错了，无伤大雅
		"-v "	# remove directory with temporary files
		"2> {log}"


rule novel_miRNA_result_stats:
	input:
		"analysis//6.Novel_miRNA_prediction/1.quantifier/all_sample_miRDeep2/result_*.csv"
	output:
		dir="analysis//6.Novel_miRNA_prediction/1.quantifier",
		result="novel_miRNA_result.txt",
		novel_mature="/novel_mature.fa",
		novel_precursor="/novel_precursor.fa"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//novel_miRNA_result_stats.py
		"""


rule mapper:
	input:
		fa="analysis//5.Known_miRNA_identification/1.quantifier/D1/unmappend_miRNA.fa",
		index_bowtie="/data3/Data_all/GenomicDatabases/Homo_sapiens/Ensembl/ATAC_index/index"
	output:
		map_arf="analysis//6.Novel_miRNA_prediction/1.quantifier/D1/reads_vs_genome.arf",
		processed="analysis//6.Novel_miRNA_prediction/1.quantifier/D1/reads_collapsed.fa"
	log:
		"log/to/log"
	shell:
        "mapper.pl "    # 原始测序数据的预处理和基因组比对
        "-c {input} "   # fastq format
        "-m "   # 合并相同的 reads
        "-l 18 "    # 过滤长度小于15bp的reads
        "-r 100 "    # 允许在基因组上map最多的reads数量
		"-p {input.index_bowtie} "
		"-t {output.map_arf} "
        "-s {output.processed} "  # print processed reads to this file
        "2> {log}"

cd analysis//6.Novel_miRNA_prediction/1.quantifier/{sample}
rule quantifier:
    input:
		novel_precursor="/novel_precursor.fa"
		novel_mature="/novel_mature.fa",
        fa="analysis//6.Novel_miRNA_prediction/1.quantifier/{sample}/reads_collapsed.fa"
    output:
        "path/to/output"
    log:
        "log/identification_Known/{sample}_quantifier.log"
    shell:
        "quantifier.pl "    # 已知miRNA的表达定量
        "-p {input.novel_precursor} "   # miRBase数据库中前体miRNA序列
        "-m {input.novel_mature} "    # miRBase数据库中的miRNA序列
        "-r {input.fa} "    # 待定量fa序列
        "-y test "  # 时间，可选参数，否则将生成新的时间
        "2> {log}"


rule miRNAs_expressed_stats_one_sample:	# 找到比对上的miRNA的序列，和前提序列，并统计
	input:
		miRNAs_expressed="analysis//6.Novel_miRNA_prediction/1.quantifier/D1/miRNAs_expressed_all_samples_test.csv",
		novel_precursor="analysis//6.Novel_miRNA_prediction/1.quantifier/novel_precursor.fa",
		novel_mature="analysis//6.Novel_miRNA_prediction/1.quantifier/novel_mature.fa"
	output:
		dir="analysis//6.Novel_miRNA_prediction/1.quantifier/{sample}",
		result="analysis/6.Novel_miRNA_prediction/1.quantifier/{sample}/miRNAs_expressed_result.txt"
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