library(ggplot2)
args<-commandArgs(T)
stats=args[1]
outdir=args[2]

df2 <- read.table(stats,header=T,sep='\t')
p <- ggplot(df2,aes(x=group, y=sum,fill=direction))+
     geom_bar(stat = 'identity',position="dodge")+
     theme_bw()+theme(panel.grid=element_blank())+
     geom_text(aes(label = sum), position = position_dodge(width = 0.9), vjust = -0.5)

png=paste0(outdir,"/diffExprGene_stats.png")
pdf=paste0(outdir,"/diffExprGene_stats.pdf")
ggsave(file=png,p, width=6, height=6, units="in")
ggsave(file=pdf,p, width=6, height=6, units="in")