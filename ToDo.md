# ToDo

## 转录组

- [ ] 研究 bowtie bowtie2 hisat2 STAR bwa 算法原理，以判断何种生物用何种比对软件
- [ ] 差异检测 gatk 多线程运行
- [ ] 

---

## WGS

- [ ] WGS 流程化
- [ ] Perl 语言学习并转化 Perl 脚本为 Python
- [ ] 差异检测注释 annova

---

## ChipSeq

- [ ] 

---

## 代谢数据库

- [ ] 更新 HMDB 数据库中没有的数据

---

## 项目

### 15 个大豆转录组测序 /data0_1/2026_09/xxx

- [ ] 跑基因注释所需要的 ID 和 name 对应，ID 是哪个？gtf 里的 Gene_ID 还是啥；LOC100808170 是哪个？
- [ ] Pathview 要实现对应

---

### 朱亚莎 1 个人单细胞

- [ ] cellranger --expect-cells

~~~bash
# tutorial 没有，同时说明会自动计算该值
# 设置不含有该值以及不同值判断对 estimate number of cell 是否有影响
# 如果还是不一样再判断是否需要 fastp
~~~

- [ ] 解决 scRNA 第八步最后报错问题

### 李娜 5 个人单细胞

- [ ] 如何去除低质量细胞，nFeature_RNA、nCount_RNA、percent.mt
- [ ] 要去除双细胞，看脚本

### 王诗老师6个人转录组售后

- [ ] 火山图显著性几个点影响整体导致作图非常难看，后续需要修改脚本