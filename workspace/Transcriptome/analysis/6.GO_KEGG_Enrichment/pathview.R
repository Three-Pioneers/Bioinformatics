library(clusterProfiler)
library(stringr)
library(dplyr)
library(ggplot2)
library(stringr)
library(scales)
library(pathview)

#args <- commandArgs(T)

Sig_genes_exprData_txt <- "analysis/4.DiffGenes/PRPP_vs_Hypoxia/Sig_genes_exprData.txt"
Sig_KEGG_Enrichment_txt <- "analysis/6.GO_KEGG_Enrichment/PRPP_vs_Hypoxia/Sig_KEGG_Enrichment.txt"
all_kegg_function_txt <- "analysis/6.GO_KEGG_Enrichment/Enrichment_KEGG_id_name_all.txt"
gene_type <- "SYMBOL"
Species <- "mmu"
outdir <- "analysis//6.GO_KEGG_Enrichment/PRPP_vs_Hypoxia/Pathway"


Sig_genes <- read.table(Sig_genes_exprData_txt,header=T,sep="\t",quote="",check.names=F,as.is=T)
Sig_KEGG_Enrichment <- read.table(Sig_KEGG_Enrichment_txt,header=T,sep="\t",quote="",check.names=F,as.is=T)
all_kegg_function <- read.table(all_kegg_function_txt,header=T,sep="\t",quote="",check.names=F,as.is=T)

#names(all_kegg_function)[1]='id'

Sig_genes$tolower <- tolower(Sig_genes$id)
all_kegg_function$tolower <- tolower(all_kegg_function$ID)
Sig_genes_KO<- plyr::join(Sig_genes,all_kegg_function,by="tolower")
Sig_genes_KO_v1 <- Sig_genes_KO[!duplicated(Sig_genes_KO$id),]


gene_colors <- c("red", "gray", "green")

setwd(outdir)

if (gene_type=='SYMBOL'){
  Sig_genes_KO_v2=data.frame(Sig_genes_KO_v1)
  Sig_genes_KO_v2$id <- sub(".*\\(([^)]+)\\).*", "\\1", Sig_genes_KO_v2$id)
  Sig_genes_KO_v3=unique(Sig_genes_KO_v2)
  gene_foldchange <- Sig_genes_KO_v3$log2FoldChange
  names(gene_foldchange) = Sig_genes_KO_v3$id
  for (i in Sig_KEGG_Enrichment$ID){
    strip_id <- sub("^[a-zA-Z]+", "", i)
    tryCatch({
    pathview(gene.data = gene_foldchange, pathway.id = i,
           species = Species,
           out.suffix = 'pathway',
           kegg.native = TRUE,
           gene.idtype = gene_type,  # 根据实际数据类型调整
           low = list(gene = gene_colors[3]),  # 下调基因颜色
           mid = list(gene = gene_colors[2]),  # 不变基因颜色
           high = list(gene = gene_colors[1])) # 上调基因颜色
    }, error = function(e) {
      message(sprintf("Error in pathway.id '%s': %s", strip_id, e$message))
      img_file <- sprintf("%s%s.pathway.png", Species,strip_id)
      if (file.exists(img_file)) {
        file.remove(img_file)
        message(sprintf("Deleted file: %s", img_file))
      }
    })
  }
}else{
  Sig_genes_KO_v2 <- subset(Sig_genes_KO_v1, !is.na(KO))
  KO_foldchange <- Sig_genes_KO_v2$log2FoldChange
  names(KO_foldchange) = Sig_genes_KO_v2$KO
  for (i in Sig_KEGG_Enrichment$ID){
    strip_id <- sub("^[a-zA-Z]+", "", i)
    print(strip_id)
    
    tryCatch({
    pathview(gene.data = KO_foldchange, pathway.id = i,
             species = Species,
             out.suffix = 'pathway',
             kegg.native = TRUE,
             gene.idtype = gene_type, 
             low = list(gene = gene_colors[3]),  # 下调基因颜色
             mid = list(gene = gene_colors[2]),  # 不变基因颜色
             high = list(gene = gene_colors[1])) # 上调基因颜色
    }, error = function(e) {
      message(sprintf("Error in pathway.id '%s': %s", strip_id, e$message))
      img_file <- sprintf("%s%s.pathway.png", Species,strip_id)
      if (file.exists(img_file)) {
        file.remove(img_file)
        message(sprintf("Deleted file: %s", img_file))
      }
    })
  }
}



