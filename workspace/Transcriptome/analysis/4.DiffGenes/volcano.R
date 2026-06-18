library(ggplot2)
args<-commandArgs(T)
data=read.table(args[1],header=T,sep="\t",quote="",check.names=F,as.is=T) 
outdir=args[2]
#data[1,]
data<-subset(data,data$log2FoldChange !="NA") 
data<-subset(data,data$pvalue !="NA")
data$color <- ifelse(data$pvalue<0.05 & abs(data$log2FoldChange)>= 1,
                     ifelse(data$log2FoldChange > 1,'red','blue'),'gray')
color <- c(red = "red",blue = "blue")

p <- ggplot(data, aes(log2FoldChange, -log10(pvalue), col = color)) +
  geom_point() +
  theme_bw() +
  scale_color_manual(values = color) +
  labs(x="log2(fold change)",y="-log10 (pvalue)") +
  geom_hline(yintercept = -log10(0.05), lty=5,col="grey",lwd=0.6) +
  geom_vline(xintercept = c(-1, 1), lty=4,col="grey",lwd=0.6) +
  theme(legend.position = "none",
        panel.grid=element_blank(),
        axis.title = element_text(size = 16),
        axis.text = element_text(size = 14))

png=paste0(outdir,"/volcano.png")
pdf=paste0(outdir,"/volcano.pdf")
ggsave(file=png,p, width=10, height=10, units="in")
ggsave(file=pdf,p, width=10, height=10, units="in")
