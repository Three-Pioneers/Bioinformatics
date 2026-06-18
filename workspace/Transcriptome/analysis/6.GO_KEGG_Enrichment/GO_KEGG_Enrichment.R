library(clusterProfiler)
library(stringr)
library(dplyr)
library(ggplot2)
library(stringr)
library(scales)
library(pathview)

args <- commandArgs(T)

Sig_genes_exprData_txt <- args[1]
all_go_function <- args[2]
all_kegg_function <- args[3]
outdir <- args[4]



# 导入基因列表
Sig_genes <- read.table(Sig_genes_exprData_txt,header=T,sep="\t",quote="",check.names=F,as.is=T)
gene_id=Sig_genes$id
go_function <- read.table(all_go_function,header=T,sep="\t",quote="",check.names=F,as.is=T)
go_type=unique(data.frame(GO = go_function$go, Classification = go_function$class))

go_gene = data.frame(Term = go_function$go, Gene = go_function$ID)
go_name = data.frame(Term = go_function$go, Name = go_function$name)

# 富集分析
GO_enrichment <- enricher(gene_id,TERM2GENE=go_gene,TERM2NAME=go_name,pvalueCutoff = 0.05, pAdjustMethod = "BH", qvalueCutoff = 0.05)
GO_enrichment_result=GO_enrichment@result
GO_enrichment_result_add_type = merge(GO_enrichment_result,go_type,by.x='ID',by.y='GO',all.x=FALSE,all.y=FALSE)
#Sig_GO_Enrichment <- GO_enrichment_result_add_type[GO_enrichment_result_add_type$pvalue<0.05,]
Sig_GO_Enrichment <- GO_enrichment_result_add_type[GO_enrichment_result_add_type$p.adjust<0.05,]
Sig_GO_Enrichment_txt=paste0(outdir,"/Sig_GO_Enrichment_test.txt")
All_GO_Enrichment_txt=paste0(outdir,"/All_GO_Enrichment.txt")
write.table(Sig_GO_Enrichment, file=Sig_GO_Enrichment_txt,quote=F,row.names = F,sep = "\t")
write.table(GO_enrichment_result_add_type, file=All_GO_Enrichment_txt,quote=F,row.names = F,sep = "\t")

if (nrow(Sig_GO_Enrichment)==0){
  GO_Enrichment <- GO_enrichment_result_add_type %>% arrange(pvalue) %>%   group_by(Classification) %>% do(head(., n = 15)) %>% arrange(Classification,Count)  #取每一个分类前15个
}else{
  GO_Enrichment <- Sig_GO_Enrichment %>% arrange(pvalue) %>%   group_by(Classification) %>% do(head(., n = 15)) %>% arrange(Classification,Count)  #取每一个分类前15
}

##plot bar
lable_name <- GO_Enrichment$Classification[!duplicated(GO_Enrichment$Classification)]
p1 <- ggplot(GO_Enrichment, aes(y = Count, x = Description)) +
  geom_bar(stat = "identity", aes(fill = Classification), alpha = 1) +
  facet_grid(Classification ~ ., scales = "free", space = "free",margins = F) +
  coord_flip()  +
  scale_fill_discrete(name = "Ontology", labels = lable_name) +
  theme_light() +
  theme(axis.text = element_text(size = 10), legend.text = element_text(size = 10)) +
  labs(y = "Number of Genes", x = "Term")+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank()) +
  labs(title = " GO barplot")+
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(breaks = pretty_breaks())

filename1 = paste0(outdir,"/GO_barplot.pdf")
ggsave(file=filename1,p1, width=15, height=10, units="in")
filename2 = paste0(outdir,"/GO_barplot.png")
ggsave(file=filename2,p1, width=15, height=10, units="in")

kk <- GO_Enrichment %>% mutate(BgCount=str_split(BgRatio,"/",simplify=T)[,1]) %>% mutate(richfactor =as.numeric(Count) / as.numeric( BgCount) ) 
p2 <- ggplot(kk, aes(x = richfactor, y = Description)) + geom_point(aes(size=Count, color=pvalue)) +
  scale_size("Count") +
  scale_color_continuous(low="red", high='green') +
  theme_light() +
  theme(axis.text = element_text(size = 10), legend.text = element_text(size = 10)) +
  labs(x="Rich factor", y = "Term")+
  labs(title = paste(" GO dotplot",sep=""))+
  theme(plot.title = element_text(hjust = 0.5))

filename3=paste0(outdir,"/GO_dotplot.pdf")
ggsave(file=filename3,p2, width=15, height=10, units="in")
filename4=paste0(outdir,"/GO_dotplot.png")
ggsave(file=filename4,p2, width=15, height=10, units="in")


kegg_function <- read.table(all_kegg_function,header=T,sep="\t",quote="",check.names=F,as.is=T,fill=T)
kegg_gene = data.frame(Term = kegg_function$Pathway_id, Gene = kegg_function$ID)
kegg_name = data.frame(Term = kegg_function$Pathway_id, Name = kegg_function$Pathway_name)

# 富集分析
KEGG_enrichment <- enricher(gene_id,TERM2GENE=kegg_gene,TERM2NAME=kegg_name,pvalueCutoff = 1, pAdjustMethod = "BH", qvalueCutoff = 1,minGSSize = 3,maxGSSize = 10000)
KEGG_enrichment_result=KEGG_enrichment@result
Sig_KEGG_Enrichment <- KEGG_enrichment_result[KEGG_enrichment_result$pvalue<0.05,]
Sig_KEGG_Enrichment_txt = paste0(outdir,"/Sig_KEGG_Enrichment.txt")
All_KEGG_Enrichment_txt = paste0(outdir,"/All_KEGG_Enrichment.txt")
write.table(Sig_KEGG_Enrichment, file=Sig_KEGG_Enrichment_txt,quote=F,row.names = F,sep = "\t")
write.table(KEGG_enrichment_result, file=All_KEGG_Enrichment_txt,quote=F,row.names = F,sep = "\t")

if (nrow(Sig_KEGG_Enrichment)==0){
  KEGG_Enrichment <- KEGG_enrichment_result %>% arrange(pvalue)  %>% do(head(., n = 20))  #取每一个分类前20个
}else{
  KEGG_Enrichment <- Sig_KEGG_Enrichment %>% arrange(pvalue)  %>% do(head(., n = 20))  #取每一个分类前20
  if (nrow(Sig_KEGG_Enrichment)<10){
    width=8
    height=4
  }else{
    width=15
    height=10
  }
}


##plot bar

p3 <- ggplot(KEGG_Enrichment, aes(y = Count, x = Description)) +
  geom_bar(stat = "identity",  alpha = 1,fill="#9ACD32") +
  coord_flip()  +
  theme_light() +
  theme(axis.text = element_text(size = 10), legend.text = element_text(size = 10)) +
  labs(y = "Number of Genes", x = "Term")+
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank()) +
  labs(title = " KEGG barplot")+
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_y_continuous(breaks = pretty_breaks())

filename5 = paste0(outdir,"/KEGG_barplot.pdf")
ggsave(file=filename5,p3, width=width, height=height, units="in")
filename6 = paste0(outdir,"/KEGG_barplot.png")
ggsave(file=filename6,p3, width=width, height=height, units="in")

kk <- KEGG_Enrichment %>% mutate(BgCount=str_split(BgRatio,"/",simplify=T)[,1]) %>% mutate(richfactor =as.numeric(Count) / as.numeric( BgCount) ) 
p4 <- ggplot(kk, aes(x = richfactor, y = Description)) + geom_point(aes(size=Count, color=pvalue)) +
  scale_size("Count") +
  scale_color_continuous(low="red", high="green") +
  theme_light() +
  theme(axis.text = element_text(size = 10), legend.text = element_text(size = 10)) +
  labs(x="Rich factor", y = "Term")+
  labs(title = paste(" KEGG dotplot",sep=""))+
  theme(plot.title = element_text(hjust = 0.5))

filename7=paste0(outdir,"/KEGG_dotplot.pdf")
ggsave(file=filename7,p4, width=width, height=height, units="in")
filename8=paste0(outdir,"/KEGG_dotplot.png")
ggsave(file=filename8,p4, width=width, height=height, units="in")



