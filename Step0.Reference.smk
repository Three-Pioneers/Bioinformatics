rule faCount:
	input:
		genome_fa = "genome.fa"
	output:
		genome_len = "genome_len.txt"
	params:
		"path/to/params"
	log:
		"log/0.Reference/1.faCount.log"
	threads: 1
	shell:
		"faCount {input.genome_fa} > {output.genome_len} > {log} 2>&1"


rule samtools_faidx:
	input:
		genome_fa = "genome.fa"
	output:
		genome_fa_fai = "genome.fa.fai"
	params:
		"path/to/params"
	log:
		"log/0.Reference/2.samtools_faidx.log"
	threads: 1
	shell:
		"samtools faidx {input.genome_fa} > {log} 2>&1"


rule gatk_CreateSequenceDictionary:
	input:
		genome_fa = "genome.fa"
	output:
		genome_dict = "genome.dict"
	params:
		"path/to/params"
	log:
		"log/0.Reference/3.gatk_CreateSequenceDictionary.log"
	threads: 1
	shell:
		"gatk CreateSequenceDictionary "
		"--java-options \"-XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Dsamjdk.compression_level=${compression_level} -XX:ParallelGCThreads=${available_threads} -Xms${gatk_memory}g -Xmx${gatk_memory}g -Djava.io.tmpdir=${tmp_dir}"
		"-R {input.genome_fa} "
		"-O {output.genome_dict} "
		"> {log} 2>&1"


rule gatk_ScatterIntervalsByNs:
	input:
		genome_fa = "genome.fa"
	output:
		genome_il = "genome.interval_list"
	params:
		max_contiguous_n = 1	# maximal number of contiguous N bases to tolerate, thereby continuing the current ACGT interval <Integer>
	log:
		"log/0.Reference/4.gatk_ScatterIntervalsByNs.log"
	threads: 1
	shell:
		"gatk ScatterIntervalsByNs "
		"--java-options \"-XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Dsamjdk.compression_level=${compression_level} -XX:ParallelGCThreads=${available_threads} -Xms${gatk_memory}g -Xmx${gatk_memory}g -Djava.io.tmpdir=${tmp_dir}"
		"-R {input.genome_fa} "
		"-N {params.max_contiguous_n} "
		"-OT BOTH "
		"-O {output.genome_il} "
		"> {log} 2>&1"


rule interval_list_to_bed:
	input:
		genome_il = "genome.interval_list"
	output:
		call_bed = "genome_calling.bed"
	params:
		dir = "./"
	log:
		"log/0.Reference/5.interval_list_to_bed.log"
	threads: 1
	shell:
		"perl /data1/Bioinfo/users/fubaiqi/pipeline/reseq/non-human/v1.8/bin/interval_list_to_bed.pl "
		"--infile {input.genome_il} "
		"--outdir {params.dir} "
		"> {log} 2>&1"


rule split_FASTA_to_Chr:
	input:
		genome_fa = "genome.fa"
	output:
		split_Chr = dir("split")
	params:
		"path/to/params"
	log:
		"log/0.Reference/6.split_FASTA_to_Chr.log"
	threads: 1
	shell:
		"python split_FASTA_to_Chr.py {input.genome_fa} > {log} 2>&1"


rule bwamem2_index:
	input:
		genome_fa = "genome.fa"
	output:
		"path/to/output"
	params:
		"path/to/params"
	log:
		"log/to/log"
	threads: 1
	shell:
		"bwa-mem2 index {input.genome_fa} > {log} 2>&1"


rule gtfToGenePred:
	input:
		genome_gtf = "genome.gtf"
	output:
		"path/to/output"
	params:
		"path/to/params"
	log:
		"log/to/log"
	threads: 1
	shell:
		"command {input} {output} > {log} 2>&1"





	ref_fa="${ref_dir}/${prefix}.fa"
	ref_gff="${ref_fa%.*}.gff"
	ref_gtf="${ref_fa%.*}.gtf"
	ref_len="${ref_fa}.len"
	ref_fai="${ref_fa}.fai"
	ref_dict="${ref_fa%.*}.dict"
	ref_il="${ref_fa}.interval_list"
	ref_wgs_call_bed="${ref_fa%.*}_wgs_calling.bed"
	ref_wgs_excl_bed="${ref_fa%.*}_wgs_exclude.bed"
	ref_amb="${ref_fa}.amb"
	ref_ann="${ref_fa}.ann"
	ref_bwt="${ref_fa}.bwt"
	ref_pac="${ref_fa}.pac"
	ref_sa="${ref_fa}.sa"
	ref_0123="${ref_fa}.0123"
	ref_bwt64="${ref_fa}.bwt.2bit.64"