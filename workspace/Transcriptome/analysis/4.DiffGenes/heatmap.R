library(pheatmap)
args<-commandArgs(T)
count=args[1]
group=args[2]
outdir=args[3]


data  <- read.table(count,header = TRUE, row.names = 1,check.names=F)
groups  <- read.table(group,header = TRUE,row.names = 1,check.names=F)

heatmap_png=paste0(outdir,'/heatmap.png')
heatmap_pdf=paste0(outdir,'/heatmap.pdf')

png(file=heatmap_png,width = 900, height = 800)
pheatmap(data, #表达数据
         cluster_rows = T,#行聚类
         cluster_cols = T,#列聚类
         annotation_col =groups, #样本分类数据
         annotation_legend=TRUE, # 显示样本分类
         show_rownames = T,# 显示行名
         show_colnames = T,# 显示列名
         scale = "row" #对行标准化
)
dev.off()



pdf(file=heatmap_pdf,width = 11, height = 10)
pheatmap(data, #表达数据
         cluster_rows = T,#行聚类
         cluster_cols = T,#列聚类
         annotation_col =groups, #样本分类数据
         annotation_legend=TRUE, # 显示样本分类
         show_rownames = T,# 显示行名
         show_colnames = T,# 显示列名
         scale = "row" #对行标准化
)
dev.off()


