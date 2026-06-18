library(clusterProfiler)
library(enrichplot)
library(stringr)
library(dplyr)

#Rscript GSEA.R \
#  /mnt/e/data/training/Transcriptome/analysis//4.DiffGenes/PRPP_vs_Hypoxia/All_genes_exprData.txt \
#  /mnt/e/data/training/Transcriptome/analysis/6.GO_KEGG_Enrichment/GO_function_id_name_all.txt \
#  /mnt/e/data/training/Transcriptome/analysis/6.GO_KEGG_Enrichment/Enrichment_KEGG_id_name_all.txt \
#  /mnt/e/data/training/Transcriptome/analysis/8.GSEA/PRPP_vs_Hypoxia

#args<-commandArgs(T)
All_genes_exprData="4.DiffGenes/PRPP_vs_Hypoxia/All_genes_exprData.txt"
GO_function="6.GO_KEGG_Enrichment/GO_function_id_name_all.txt"
KEGG_function="6.GO_KEGG_Enrichment/Enrichment_KEGG_id_name_all.txt"
outdir="8.GSEA/PRPP_vs_Hypoxia/"
data1=read.table(All_genes_exprData,header=T,sep="\t",quote="",check.names=F,as.is=T)
data <- data1 %>%
  mutate(log2FoldChange = if_else(log2FoldChange == 0, 0.00000000001, log2FoldChange))



genelist <- data$log2FoldChange
names(genelist) <- data$id
genelist <- sort(genelist,decreasing=T)
head(genelist)

go_function <- read.table(GO_function,header=T,sep="\t",quote="",check.names=F,as.is=T)
go_gene = data.frame(Term = go_function$go, Gene = go_function$ID)
go_name = data.frame(Term = go_function$go, Name = go_function$name)
set.seed(1)
gsea.go <- GSEA(genelist, TERM2GENE = go_gene, TERM2NAME = go_name,minGSSize = 10, pvalueCutoff = 0.99,pAdjustMethod = "BH")
result=gsea.go@result
GO_GSEA_all=paste0(outdir,"/GO_GSEA_all.txt")
write.table(result,file=GO_GSEA_all,col.names=T,row.names=F,quote=F,sep="\t")


sortgo<-gsea.go[order(gsea.go$pvalue, decreasing = F),]
if (nrow(sortgo) > 10) {
  go.top10<-row.names(sortgo)[1:10]
} else {
  go.top10<-row.names(sortgo)
}

GO_GSEA_top10_png=paste0(outdir,'/GO_GSEA_top10.png')
GO_GSEA_top10_pdf=paste0(outdir,'/GO_GSEA_top10.pdf')
png(file=GO_GSEA_top10_png,width=1500, height=1000)
gseaplot2(gsea.go,go.top10,pvalue_table = TRUE)
dev.off()
pdf(file=GO_GSEA_top10_pdf,width=16, height=16)
gseaplot2(gsea.go,go.top10,pvalue_table = TRUE)
dev.off()


kegg_function <- read.table(KEGG_function,header=T,sep="\t",quote="",check.names=F,as.is=T,fill=T)
kegg_gene = data.frame(Term = kegg_function$Pathway_id, Gene = kegg_function$ID)
kegg_name = data.frame(Term = kegg_function$Pathway_id, Name = kegg_function$Pathway_name)

# 富集分析
gsea.kegg <- GSEA(genelist, TERM2GENE=kegg_gene, TERM2NAME=kegg_name, minGSSize = 10, pvalueCutoff = 0.99, pAdjustMethod = "BH")
gsea.kegg_result=gsea.kegg@result
KEGG_GSEA_all=paste0(outdir,"/KEGG_GSEA_all.txt")
write.table(gsea.kegg_result,file=KEGG_GSEA_all,col.names=T,row.names=F,quote=F,sep="\t")

sortkegg<-gsea.kegg[order(gsea.kegg$pvalue, decreasing = F),]
if (nrow(sortkegg) > 10) {
  kegg.top10<-row.names(sortkegg)[1:10]
} else {
  kegg.top10<-row.names(sortkegg)
}

KEGG_GSEA_top10_png=paste0(outdir,'/KEGG_GSEA_top10.png')
KEGG_GSEA_top10_pdf=paste0(outdir,'/KEGG_GSEA_top10.pdf')
png(file=KEGG_GSEA_top10_png,width=1500, height=1000)
gseaplot2(gsea.kegg,kegg.top10,pvalue_table = TRUE)
dev.off()
pdf(file=KEGG_GSEA_top10_pdf,width=16, height=16)
gseaplot2(gsea.kegg,kegg.top10,pvalue_table = TRUE)
dev.off()


pase1=paste(outdir,sep="/","GO")
pase2=paste(outdir,sep="/","KEGG")
setwd(pase1)
for (i in go.top10){
  ID=str_replace(i,":","_")
  file.png=paste0(ID,".png")
  file.pdf=paste0(ID,".pdf")
  png(file=file.png)
  p=gseaplot2(gsea.go,i,pvalue_table = F,title=ID)
  print(p)
  dev.off() 
  pdf(file=file.pdf)
  p=gseaplot2(gsea.go,i,pvalue_table = F,title=ID)
  print(p)
  dev.off() 
}

setwd(pase2)
for (i in kegg.top10){
  file.png=paste0(i,".png")
  file.pdf=paste0(i,".pdf")
  png(file=file.png)
  p=gseaplot2(gsea.kegg,i,pvalue=F,title=i)
  print(p)
  dev.off() 
  pdf(file=file.pdf)
  p=gseaplot2(gsea.kegg,i,pvalue=F,title=i)
  print(p)
  dev.off() 
}













