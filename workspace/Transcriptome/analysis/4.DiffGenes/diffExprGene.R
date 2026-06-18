library(DESeq2)
library(dplyr)

args<-commandArgs(T)
outdir=args[3]
count <- read.table(args[1],header=T,row.names=1,check.names=F)
#count <- count[rowMeans(count)>1,]
count <- round(as.matrix(count))
sample <- read.table(args[2],header = T,row.names = 1)
control_group <- as.character(sample$group[nrow(sample)])
sample$group <- as.factor(sample$group)
dds <-  DESeqDataSetFromMatrix(countData = round(count),colData = sample,design = ~ group)

dds$group <- relevel(dds$group, ref = control_group)
#过滤
dds <- dds[rowSums(counts(dds)) > 1,]


## 差异比较
dep <- DESeq(dds)
diff =  results(dep)
#diff <- na.omit(diff)  ## 去除缺失值NA
diff <- as.data.frame(diff)
diff <- cbind(id=rownames(diff),diff)

diff$Direction <-with(diff,ifelse(pvalue<0.05 & abs(log2FoldChange) >= 1,ifelse(log2FoldChange>=1,"Up","Down"),"No"))
diff<- select(diff,c(id,baseMean,log2FoldChange,pvalue,padj,Direction))
names(diff)<-c("id","baseMean","log2FoldChange","pvalue","padj","Direction")
diff.filter<-diff %>% filter(pvalue<0.05 & abs(log2FoldChange) >= 1)

All_genes=paste0(outdir,"/All_genes_exprData.txt")
Sig_genes=paste0(outdir,"/Sig_genes_exprData.txt")
write.table(diff, file=All_genes, sep="\t", quote=FALSE,row.name=FALSE)
write.table(diff.filter, file=Sig_genes, sep="\t", quote=FALSE,row.name=FALSE)



