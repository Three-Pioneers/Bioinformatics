# WGS

## 准备

```bash
https://github.com/dellytools/svprops	# github 下载 svprops，sampleprops 也在其中
```



## 步骤

1. multiqc_config.yaml 去掉
2. bwa-mem2 -R 参数修改了
3. Call_variants 需要所有 Chr，需要写脚本将 Chr 赋值给 config.yaml



## Program

**delly**

- [ ] 原来 0.8 版本 delly call 在新版本区分了 SV 的短读长和长读长，命令改为 delly sr
- [ ] 使用 Snakemake 后 rule 写长命令
- [ ] exclude.bed 如果为空要取消 -x 参数，以后命令行要加上
- [ ] 学会 Snakefile + config.yaml 的条件结构选择 rule



## 致病性位点检测





### Basic





### Question

- [ ] 第七步注释表：`head -n 13 cnv_outputfile_anno.txt|awk '{print $1,$2,$3,$4,$5,$6,$7,$21,$22,$31,$32,$34}'|ct -s ' '|le`
- [ ] 报告的 html 模板：`/Databackup3/2026_07/ZhuYaSha_1_human_WGS/analysis/5.Report/report.Rmd`
- [ ] 修改了 delly_stats.pl 的 191 行，新版本 svprops 输出结果在原有基础上增加了两列。而原脚本根据位置进行筛选，而不是根据字段进行筛选，因此以后尽量改成字段