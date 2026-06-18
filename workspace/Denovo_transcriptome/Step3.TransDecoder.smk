rule TransDecoder_LongOrfs:	# 从转录本提取 ORF（从起始密码子到终止密码子之间的一段连续序列）
	input:
		Trinity_fasta = "analysis/2.Trinity/Trinity.fasta",
		Trinity_fasta_gene_trans_map = "analysis/2.Trinity/Trinity.fasta.gene_trans_map"	# 基因到转录本的映射文件
	output:
		dir = directory(analysis/3.TransDecoder)
		ORF_pep = "analysis/3.TransDecoder/Trinity.fasta.transdecoder_dir/longest_orfs.pep",	# 满足最小长度的所有 ORF 的蛋白质序列？？？
		ORF_gff3 = "analysis/3.TransDecoder/Trinity.fasta.transdecoder_dir/longest_orfs.gff3",	# 所有 ORF 在转录本中的位置信息
		ORF_cds = "analysis/3.TransDecoder/Trinity.fasta.transdecoder_dir/longest_orfs.cds"	# 所有基因转录本的 ORF 的核酸编码序列
	log:
		"log/3.TransDecoder/TransDecoder_LongOrfs.log"
	shell:
		"TransDecoder.LongOrfs "
		"-t {input.Trinity_fasta} "	# transcripts.fasta
		"--gene_trans_map {input.Trinity_fasta_gene_trans_map} "	# 流程没有，可加
		"-m 100 "	# minimum protein length (default: 100)
		"--output_dir {output.dir} "
		"> {log} 2>&1"


rule blastp:	# 用提取开放阅读框的蛋白和蛋白数据库进行比对，
	input:
		ORF_Pep = "Trinity.fasta.transdecoder_dir/longest_orfs.pep",
		DB = "/Data_all/Databases/Uniprot/taxonomic_divisions/uniprot_sprot_plants"
	output:
		Uniprot = "analysis/3.TransDecoder/Uniprot_tmp.txt"
	log:
		"log/3.TransDecoder/Blastp_Uniprot.log"
	threads: 40
	shell:
		"blastp "
		"-query {input.ORF_Pep} "
		"-db {input.DB} "
		"-out {output} "
		"-max_target_seqs 1 "	# Maximum number of aligned sequences to keep, value of 5 or more is recommended, Default = `500'
		"-outfmt 6 "
		"-num_threads {threads} "
		"> {log} 2>&1"


rule TransDecoder_Predict:	# 预测可能的编码区域
	input:
		Trinity_fasta = "analysis/2.Trinity/Trinity.fasta",
		Uniprot = "analysis/3.TransDecoder/Uniprot_tmp.txt"
	output:
		dir = directory(analysis/3.TransDecoder)
		Predict_bed = "analysis/3.TransDecoder/Trinity.fasta.transdecoder.bed",
		Predict_cds = "analysis/3.TransDecoder/Trinity.fasta.transdecoder.cds",
		Predict_gff3 = "analysis/3.TransDecoder/Trinity.fasta.transdecoder.gff3",
		Predict_pep = "analysis/3.TransDecoder/Trinity.fasta.transdecoder.pep"
	log:
		"log/3.TransDecoder/TransDecoder_Predict.log"
	threads: 1
	shell:
		"TransDecoder.Predict "
		"-t {input.Trinity_fasta} "
		"--retain_blastp_hits {input.Uniprot} "	# 保留与已知蛋白质数据库匹配的 ORF
		"--single_best_only "	# Retain only the single best orf per transcript (prioritized by homology then orf length)，先按照同源性优先，然后按照开放阅读框长度
		"--output_dir {output.dir} "
		"> {log} 2>&1"


rule rename_trinity_transdecoder_all:
	input:
		Trinity_fasta = "analysis/2.Trinity/Trinity.fasta",
		Predict_cds = "analysis/3.TransDecoder/Trinity.fasta.transdecoder.cds",
		Predict_pep = "analysis/3.TransDecoder/Trinity.fasta.transdecoder.pep",
		Predict_gff3 = "analysis/3.TransDecoder/Trinity.fasta.transdecoder.gff3"
	output:
		dir = directory("analysis/3.TransDecoder/renamed"),
		renamed_cds = "analysis/3.TransDecoder/renamed/Trinity.renamed.cds.fa",
		renamed_fasta = "analysis/3.TransDecoder/renamed/Trinity.renamed.fasta",
		renamed_gff3 = "analysis/3.TransDecoder/renamed/Trinity.renamed.gff3",
		renamed_pep = "analysis/3.TransDecoder/renamed/Trinity.renamed.pep.fa",
		"analysis/3.TransDecoder/renamed/chr_map.tsv",	# 转录本重新命名
		"analysis/3.TransDecoder/renamed/gene_map.tsv",	# Gene 重新命名
		"analysis/3.TransDecoder/renamed/id_map_gff.tsv",
		"analysis/3.TransDecoder/renamed/mrna_map.tsv"
	log:
		"log/3.TransDecoder/rename_trinity_transdecoder.log"
	threads: 1
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//rename_trinity_transdecoder_all.py "
		"--trinity {input.Trinity_fasta} "
		"--cds {input.Predict_cds} "
		"--pep {input.Predict_pep} "
		"--gff {input.Predict_gff3} "
		"--outdir {output.dir} "
		"> {log} 2>&1"
# 功能：
## 从 TransDecoder GFF3 构建映射（chr_map/gene_map/mrna_map），并记录 GFF 中出现的 Trinity 序列ID（used_trinity_ids）
## Trinity.fasta 仅保留 GFF 覆盖到的序列，其它丢弃
## FASTA（Trinity/CDS/PEP）标题仅输出新ID（不保留原始注释）
## 同步改写 GFF3：seqid -> chrX，ID/Parent/Name -> 新ID
## 输出映射表：chr_map.tsv, gene_map.tsv, mrna_map.tsv, id_map_gff.tsv


rule samtools_index:
	input:
		"analysis/3.TransDecoder/renamed/Trinity.renamed.fasta"
	output:
		"analysis/3.TransDecoder/renamed/Trinity.renamed.fasta.fai"
	log:
		"log/3.TransDecoder/samtools_index.log"
	threads: 1
	shell:
		"samtools faidx {input} > {log} 2>&1"


rule gatk_SequenceDictionary:
	input:
		"analysis/3.TransDecoder/renamed/Trinity.renamed.fasta"
		"analysis/3.TransDecoder/renamed/Trinity.renamed.fasta.fai"
	output:
		"analysis/3.TransDecoder/renamed/Trinity.renamed.dict"
	log:
		"log/3.TransDecoder/gatk_SequenceDictionary.log"
	threads: 1
	shell:
		"gatk CreateSequenceDictionary "
		"-R {input} "
		"-O {output} "
		"> {log} 2>&1"