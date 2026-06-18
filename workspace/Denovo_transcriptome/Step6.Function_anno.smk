# Uniprot
rule Uniprot_blastp:
	input:
		renamed_pep = "analysis/3.TransDecoder/renamed/Trinity.renamed.pep.fa",
		Uniprot_DB = "/Data_all/Databases/Uniprot/taxonomic_divisions/uniprot_sprot_plants"
	output:
		Uniprot_tmp_1 = "analysis/6.Function_anno/1.Uniprot/Uniprot_tmp.txt"
	log:
		"log/6.Function_anno/Uniprot_blastp.log"
	threads: 1
	shell:
		"blastp "
		"-query {input.renamed_pep} "
		"-db {input.Uniprot_DB} "
		"-num_threads {threads} "
		"-max_target_seqs 1 "
		"-outfmt 6 "
		"-out {output.Uniprot_tmp} "
		"> {log} 2>&1"


rule Uniprot_process:
	input:
		Uniprot_tmp_1 = "analysis/6.Function_anno/1.Uniprot/Uniprot_tmp.txt",
		Uniprot_DB_species = "analysis/6.Function_anno/1.Uniprot/Uniprot_function_id.txt"
	output:
		Uniprot_tmp_2_sort = "analysis/6.Function_anno/1.Uniprot/Uniprot_tmp_2_sort.txt",
		Uniprot_function = "analysis/6.Function_anno/1.Uniprot/Uniprot_function_id.txt"
	log:
		"log/6.Function_anno/Uniprot_process.log"
	shell:	# 很奇怪，为啥排序又排序
		"""
		(sort -k 1,1 -k 11,11g  {input.Uniprot_tmp1} | \
		sort -k 1,1 -s -u | \
		csvtk cut -t -f 1,2 | \
		sort -k 2 -s > {output.Uniprot_tmp2}
		join --nocheck-order -t $'\t' -1 2 -2 1 {output.Uniprot_tmp2} {Uniprot_DB_species} | \
		awk -F "\t" '{print $2"\t"$1"\t"$4}' | \
		sed '1d\ID\tUniprot_id\tProtein\tOrganism_Taxonomic_Gene' > {output.Uniprot_function}) > {log} 2>&1
		"""


# GO
rule GO_process:
	input:
		Uniprot = "analysis/6.Function_anno/1.Uniprot/Uniprot_function_id.txt",
		GO_DB = "/Data_all/Databases/Uniprot/uniprot_go_sort.txt"
	output:
		Uniprot_1d = "analysis/6.Function_anno/2.GO/Uniprot_function_tmp.txt",
		GO_tmp = "analysis/6.Function_anno/2.GO/GO_tmp.txt"
	log:
		"log/6.Function_anno/GO_process.log"
	shell:
		"""
		(sed '1d' {input.Uniprot} > {output.Uniprot_1d} 
		join --nocheck-order -t $'\t' -1 2 -2 1 {output.Uniprot_1d} {input.GO_DB} | \
		awk -F '\t' '{print $2"\t"$1"\t"$5}' | \
		sort -k 1 > {output.GO_tmp}) > {log} 2>&1
		"""


rule GO_function:
	input:
		GO_basic = "/Data_all/Databases/GO/go-basic.txt",	# GO数据库：id name classic
		GO_tmp = "analysis/6.Function_anno/2.GO/GO_tmp.txt"
	output:
		GO_Function = "analysis/6.Function_anno/2.GO/GO_function_id.txt"
	log:
		"log/6.Function_anno/GO_function.log"
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//GO_function.py {input.GO_basic} {GO_tmp} {output.GO_Function} > {log} 2>&1"


# KEGG
rule KEGG_blastp:
	input:
		renamed_cds = "analysis/3.TransDecoder/renamed/Trinity.renamed.cds.fa",
		kEGG_species = "Eudicots"	#?要把此处放到config
	output:
		KEGG_tmp_1 = "analysis/6.Function_anno/3.KEGG/KEGG_tmp.txt"
	log:
		"log/6.Function_anno/KEGG_blastp.log"
	threads: 40
	shell:
		"blastp "
		"-query {input.renamed_cds} "
		"-db /Data_all/Databases/KEGG/taxonomic_divisions/nucl/{input.kEGG_DB} "
		"-num_threads {threads} "
		"-max_target_seqs 1 "
		"-outfmt 6 "
		"-out {output.KEGG_tmp_1} "
		"> {log} 2>&1"


rule KEGG_process:
	input:
		KEGG_tmp_1 = "analysis/6.Function_anno/3.KEGG/KEGG_tmp.txt",
		KEGG_anno = "/Data_all/Databases/KEGG/anno.txt"
	output:
		KEGG_tmp_2_sort = "analysis/6.Function_anno/3.KEGG/KEGG_tmp_2_sort.txt",
		KEGG_function = "analysis/6.Function_anno/3.KEGG/KEGG_function_id.txt"
	log:
		"log/6.Function_anno/KEGG_process.log"
	shell:
		"""
		(sort -k1,1 -k11,11g {input.KEGG_tmp_1} | \
		sort -k1,1 -u | \
		csvtk cut -t -f 1,2 | \
		sort -k 2 > {output.KEGG_tmp_2_sort}
		join --nocheck-order -t $'\t' -1 2 -2 1 {output.KEGG_tmp_2_sort} {input.KEGG_anno} | \
		awk -F '\t' '{print $2"\t"$1"\t"$5"\t"$6"\t"$8}' | \
		sed '1i\ID\tgene_id\tKO\tKO_name\tPathway' > {output.KEGG_function}) > {log} 2>&1
		"""


rule KEGG_Enrichment:
	input:
		KEGG_function = "analysis/6.Function_anno/3.KEGG/KEGG_function_id.txt"
	output:
		dir = directory("analysis/6.Function_anno/3.KEGG"),
		Enrichment_KEGG = "analysis/6.Function_anno/3.KEGG/Enrichment_KEGG_id.txt"
	log:
		"log/6.Function_anno/KEGG_Enrichment.log"
	shell:
		"python /data3/Data_all/script/Denovo_transcriptome/bin//Enrichment_KEGG_id.py {input.KEGG_function} ko {output.dir} > {log} 2>&1"


# COG
rule cOG_diamond_blastp:
	input:
		renamed_pep = "analysis/3.TransDecoder/renamed/Trinity.renamed.pep.fa",
		COG_dmnd = "/Data_all/Databases/COG/cog-20.dmnd"
	output:
		COG_tmp_1 = "analysis/6.Function_anno/4.COG/COG_tmp.txt"
	log:
		"log/6.Function_anno/COG_blastp.log"
	threads: 40
	shell:
		"diamond blastp "
		"--query {input.renamed_pep} "
		"--db {input.COG_dmnd} "
		"--top 3 "
		"--outfmt 6 "
		"--threads {threads} "
		"--out {output} "
		"> {log} 2>&1"


rule COG_process:
	input:
		COG_tmp_1 = "analysis/6.Function_anno/4.COG/COG_tmp.txt",
		COG_anno = "/Data_all/Databases/COG/anno_1_sort.txt"
	output:
		COG_tmp_2_sort = "analysis/6.Function_anno/4.COG/COG_tmp_2_sort.txt",
		COG_function = "analysis/6.Function_anno/4.COG/COG_function_id.txt"
	log:
		"log/6.Function_anno/COG_process.log"
	shell:
		"""
		(sort -k1,1 -k11,11g {input.COG_tmp_1} | \
		sort -k1,1 -u | \
		csvtk cut -t -f 1,2 | \
		sort -k 2 > {output.COG_tmp_2_sort}
		join --nocheck-order -t $'\t' -1 2 -2 1 {output.COG_tmp_2_sort} {input.COG_anno} | \
		awk -F '\t' '{print$2"\t"$1"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7}' | \
		sed '1i\ID\tProtein_id\tCOG_id\tCOG_class\tCOG_class_name\tCOG_name\tCOG_related_gene' > {output.COG_function}) > {log} 2>&1
		"""


# eggNOG
rule emapper:
	input:
		renamed_pep = "analysis/3.TransDecoder/renamed/Trinity.renamed.pep.fa"
	output:
		dir = directory("analysis/6.Function_anno/5.eggNOG/"),
		eggNOG_anno = "analysis/6.Function_anno/5.eggNOG/eggNOG.emapper.annotations",
		eggNOG_hits = "analysis/6.Function_anno/5.eggNOG/eggNOG.emapper.hits",
		eggNOG_seed_orthologs = "analysis/6.Function_anno/5.eggNOG/eggNOG.emapper.seed_orthologs",
	log:
		"log/6.Function_anno/eggNOG_emapper.log"
	threads: 40
	shell:
		"/data3/Data_all/Software/miniconda3/bin/emapper.py "
		"--itype proteins "
		"-m diamond "
		"--cpu {threads} "
		"-i {input.renamed_pep} "
		"-o {output} > {log} 2>&1"


rule eggNOG_process:
	input:
		eggNOG_anno = "analysis/6.Function_anno/5.eggNOG/eggNOG.emapper.annotations"
	output:
		eggNOG_function = "analysis/6.Function_anno/5.eggNOG/eggNOG_function_id.txt"
	log:
		"log/6.Function_anno/eggNOG_process.log"
	shell:
		"""
		(grep -v "#" {input.eggNOG_anno} | \
		sort -k 1 | \
		awk -F '\t' '{print$1"\t"$2"\t"$5"\t"$8}' | \
		sed '1i\ID\teggNOG_id\teggNOG_OGs\tDescription' > {output.eggNOG_function}) > {log} 2>&1
		"""


# NR
rule NR_diamond_blastp:
	input:
		renamed_pep = "analysis/3.TransDecoder/renamed/Trinity.renamed.pep.fa",
		NR_dmnd = "/Data_all/Databases/NR/taxonomic_divisions/Eudicots.dmnd"
	output:
		NR_tmp_1 = "analysis/6.Function_anno/6.NR/NR_tmp.txt"
	log:
		"log/6.Function_anno/NR_diamond_blastp.log"
	threads: 40
	shell:
		"diamond blastp "
		"--query {input.renamed_pep} "
		"--db {input.NR_dmnd} "
		"--top 3 "
		"--outfmt 6 "
		"--threads {threads} "
		"--out {output.NR_tmp_1} "
		"> {log} 2>&1"


rule NR_process:
	input:
		NR_tmp_1 = "analysis/6.Function_anno/6.NR/NR_tmp.txt"
		NR_anno = "/Data_all/Databases/NR/anno_1_sort.txt"
	output:
		NR_tmp_2_sort = "analysis/6.Function_anno/4.COG/COG_tmp_2_sort.txt",
		NR_function = "analysis/6.Function_anno/4.COG/COG_function_id.txt"
	log:
		"log/6.Function_anno/NR_process.log"
	shell:
		"""
		(sort -k1,1 -k11,11g {input.NR_tmp_1} | \
		sort -k1,1 -u | \
		csvtk cut -t -f 1,2 | \
		sort -k 2 > {output.NR_tmp_2_sort}
		join --nocheck-order -t $'\t' -1 2 -2 1 {output.NR_tmp_2_sort} {input.NR_anno} | \
		awk -F '\t' '{print$2"\t"$1"\t"$3}' | \
		sed '1i\ID\tFunction_id\tDescript' > {output.NR_function}) > {log} 2>&1
		"""


# Pfam
rule Pfam_seqkit:
	input:
		renamed_pep = "analysis/3.TransDecoder/renamed/Trinity.renamed.pep.fa",
	output:
		dir = directory("analysis/6.Function_anno/7.Pfam/")
	log:
		"log/6.Function_anno/Pfam_seqkit.log"
	threads: 1
	shell:
		"seqkit split2 "
		"{input.renamed_pep} "
		"-p 30 "
		"-j 40 "
		"-O {output}/split "
		"> {log} 2>&1"


rule Pfam_process:
	input:
		"path/to/input"
	output:
		Pfam_function = "analysis/6.Function_anno/7.Pfam/Pfam_function_id.txt"
	log:
		"log/6.Function_anno/Pfam_process.log"
	shell:
		"""
		cat analysis/6.Function_anno/7.Pfam/split/hmmscan.sh | \
		/data3/Data_all/Software/Rush/rush {} -j 13 
		cat analysis/6.Function_anno/7.Pfam/split/Pfam_tbl_* | \
		grep -v "#" | \
		awk -F ' ' '{print$3"\t"$2"\t"$1"\t"$19" "$20" "$21" "$22" "$23" "$24}' | \
		sort -k1,1 -u | \
		sed '1i\ID\tPfam_accession\tPfam_name\tDescript' > {output} > {log} 2>&1
		"""