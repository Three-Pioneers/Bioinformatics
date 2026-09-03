## [Snakemake](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html)

**通配符**

1. 由输出反向推导输入以确定通配符的值
2. 自由选择字符或者使用 Python 也可，同一 rule 关联输入输出通配符相同即可
3. 输出为目录时，加函数 directory()，输入和 params 不可用；但一般目录不是实际输出，应此参数输出文件夹一般放在 params 中

**运行**

1. 输出文件不含通配符的 rules 被执行时，若输入含通配符，必须指定通配符的值？
2. ==中间规则改变，被影响的所有 rules 都会重新运行==
3. 如果手动终止运行，会产生锁文件`snakemake --unlock`即可解除
4. 不要用 script 代替 shell，尽量不改变原脚本运行方式
5. 修改了参数，但是不影响结果或者不想重新运行，`snakemake --cleanup-metadata {outputfile}`

**命令与参数**

~~~bash
--forceall	# 全部强制执行
--forcerun	# 好像没啥用
--cores all	# 设置几都跑慢
# threads 不是越多越好，最好多任务，小线程，找到每个软件最佳线程数

--dag | dot -Tsvg > dag.svg	# 画图

# 若 Snakefile 下含有多个文件，则 all 规则要放到 Snakefile 里，放到下属文件中不会识别 all 为默认规则

# {} 在规则里要双用，不能单独使用
RuleException in rule process_2 in file "/home/zhangxuejie/Workspace/Fe_EET/work_smk/Step1.BLASTP.smk", line 39:
NameError: The name 'OFS="\t"' is unknown in this context. Please make sure that you defined that variable. Also note that braces not used for variable access have to be escaped by repeating them, i.e. {{print $1}}, when formatting the following:
~~~

**规则**

~~~bash
# 输入输出有文件夹
rule multiqc_fastp:
	input:
		dir=directory("analysis/1.QC/json")
	output:
		dir=directory("analysis/1.QC/stats/")
	log:
		"log/1.QC/multiqc.log"
	shell:
		"multiqc {input.dir} --filename multiqc_fastp --outdir {output.dir} 2> {log}"
~~~

**模板**

~~~bash
# Ctrl + shift + p，搜索配置代码片段，新建，名字添 Snakemake。粘贴下列代码
{
	// Place your snippets for snakemake here. Each snippet is defined under a snippet name and has a prefix, body and 
	// description. The prefix is what is used to trigger the snippet and the body will be expanded and inserted. Possible variables are:
	// $1, $2 for tab stops, $0 for the final cursor position, and ${1:label}, ${2:another} for placeholders. Placeholders with the 
	// same ids are connected.
"Snakemake Script/Single": {
    	"prefix": "rule-single",
    	"body": [
        	"rule ${1:rule_name}:",
        	"    input:",
        	"        \"${2:path/to/input}\"",
        	"    output:",
        	"        \"${3:path/to/output}\"",
        	"    log:",
        	"        \"${4:log/to/log}\"",
        	"    threads: ${5:1}",
        	"    shell:",
        	"        \"${6:command} {input} {output} > {log} 2>&1\"",
        	"$0"
    	],
    	"description": "Snakemake Single Shell"
	},	
"Snakemake Multiple": {
		"prefix": "rule-multiple",
		"body": [
			"rule ${1:rule_name}:",
			"    input:",
			"        \"${2:path/to/input}\"",
			"    output:",
			"        \"${3:path/to/output}\"",
			"    log:",
			"        \"${4:log/to/log}\"",
			"    threads: 1",
			"    shell:",
			"        \"\"\"",
			"        ${5:command} {input} {output} > {log} 2>&1",
			"        \"\"\"",
			"$0"
		],
		"description": "Snakemake Multiple Shell"
	},
}
~~~

**难点**

1. 双端测序数据建立软链接，以及单端测序建立软链接以及后续质控和比对的参数设置问题
   AI 说能在规则中用 if_else，判断语句