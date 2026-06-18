rule RepeatMasker:	# 若序列数量多，文件大，需将第三步比对后的输出序列拆分后做输入（跑不出来就拆分，以 50M 为宜）
	input:
		fa="analysis//3.ncRNA_classification/5.piRNA/1.mapping/{sample}_unmapping.fa"
		pa="10"
		species="9606"
	output:
		dir="analysis//4.RepeatMasker/{sample}",
		cat="analysis//4.RepeatMasker/{sample}/{sample}_unmapping.fa.cat.gz",	# 中间文件，做 ProcessRepeats 输入可输出 .out .tbl
		masked="analysis//4.RepeatMasker/{sample}/{sample}_unmapping.fa.masked",	# 屏蔽（非删除） repeat 后的 fa 序列；把 repeat 区域小写或替换为 "N"
		out="analysis//4.RepeatMasker/{sample}/{sample}_unmapping.fa.out",	# repeat 注释明细表
		tbl="analysis//4.RepeatMasker/{sample}/{sample}_unmapping.fa.tbl"	# repeat 分类汇总表
	log:
		"log/RepeatMasker/{sample}.log"
	threads: 40
	shell:
		"RepeatMasker "	# 比对样本序列和 Dfam 数据库中的 repeat 区域，并注释统计
		"{input.fa} "
		"-engine rmblast "	# 搜索比对引擎：RMBlast（默认）；ABBlast（最快）；nhmmer（仅用于人，最准）；crossmatch（慢但准），详解在下
		"-qq "	# 极快模式
		"-xsmall "	# 把重复区域改成小写，非重复区域保持大写；便于后续基因预测；不加则把重复区域改成 "N"
		"-norna "	# 不屏蔽 small RNA 相关的假基因 / 基因序列
		"-nopost "	# 只搜索比对，ProcessRepeats 后续并行所有的样本
		"-species {input.species} "	# 种类编号？
		"-dir {output.dir} "
		"-pa {input.pa} "	# 并行任务数；不等于 threads；详解在下
		"2> {log}"
# -engine：	搜索比对引擎
##			Cross_match：更灵敏但速度慢
##			ABBlast：速度非常快，但灵敏度略低
##			RMBlast 是 NCBI Blast 工具套件中与 RepeatMasker 兼容的版本。
##			nhmmer：使用新的 nhmmer 程序，将序列与新的 Dfam 数据库（仅限人类）进行比对

# -pa：	并行任务数；不等于 threads
##		使用总线程：threads = pa * 搜索引擎使用核心数；不同引擎使用核心数如下
##		RMBlast     4 cores
##		ABBlast     4 cores
##		nhmmer      2 cores
##		crossmatch  1 core


rule ProcessRepeats:    #耗时长，单线程，内存占用不大，必须并行
	input:
		cat="analysis//4.RepeatMasker/{sample}/{sample}_unmapping.fa.cat.gz",    # 中间文件，做 ProcessRepeats 输入可输出 .out .tbl
		species="9606"
	output:
		out="analysis//4.RepeatMasker/{sample}/{sample}_unmapping.fa.out",   # repeat 注释明细表
		tbl="analysis//4.RepeatMasker/{sample}/{sample}_unmapping.fa.tbl"    # repeat 分类汇总表
	log:
		"log/RepeatMasker/{sample}.log"
	threads: 1
	shell:
		"ProcessRepeats "
		"-species {input.species} "
		"-xsmall "
		"{input.cat} "  # 默认输出到输入路径的同级路径
		"2> {log}"



rule Repeat_stat:
	input:
		fa="analysis//3.ncRNA_classification/5.piRNA/1.mapping/D1_unmapping.fa",
		out="analysis//4.RepeatMasker/D1/D1_unmapping.fa.out"
	output:
		dir="analysis//4.RepeatMasker/{sample}",
		map="analysis//4.RepeatMasker/{sample}/Repeat_mapped.fa",
		unmap="analysis//4.RepeatMasker/{sample}/Repeat_unmapped.fa",
		stat="analysis//4.RepeatMasker/{sample}/Repeat_stat.txt"
	log:
		"analysis//4.RepeatMasker/{sample}_py.log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//Repeat_stat.py
		"""


rule Repeat_plot:
	input:
		stat="analysis//4.RepeatMasker/{sample}/Repeat_stat.txt"
	output:
		dir="analysis//4.RepeatMasker/{sample}",
		png="analysis//4.RepeatMasker/{sample}/Repeat_stat.png",
		pdf="analysis//4.RepeatMasker/{sample}/Repeat_stat.pdf"
	log:
		"log/4.RepeatMasker/{sample}_plot.log"
	script:
		"""
		/data3/Data_all/script/miRNA/bin//Repeat_plot.R
		"""
