library(ggplot2)
library(scatterplot3d)
library(vegan)
library(ggrepel)

args<-commandArgs(T)
quan_txt=args[1]
sample_group=args[2]
outdir=args[3]
title=args[4]
quan=read.table(quan_txt,header=T,sep="\t", row.names = 1,check.names=F)
sample<-read.delim(sample_group, header=T,sep="\t",quote="",check.names=F,as.is=T)

color_list=c('blue','orange','forestgreen','gold','brown','oldlace','coral','aquamarine','cyan','lawngreen','linen','salmon','skyblue','tan','darkred','deeppink','lightyellow','green','ivory','mediumvioletred','navy','linen','salmon','skyblue','tan','darkred','deeppink','lightyellow','green','ivory','mediumvioletred','navy','peachpuff','red','violet','wheat')
sample$color <- color_list[match(sample$group, unique(sample$group))]


pca1 <- princomp(quan,cor = T)
summary(pca1,loadings=T)
pca.var <- pca1$sdev^2 
pca.var.per <- round(pca.var/sum(pca.var)*100, 1)

PCA1=pca1$loadings[,1]
PCA2=pca1$loadings[,2]
#PCA3=pca1$loadings[,3]

pca_2D.data <- data.frame(Sample=sample$sample_id,
                          PC1=PCA1,
                          PC2=PCA2,
                          group=sample$group)
#pca_2D.data
p1=ggplot(data=pca_2D.data,aes(x=PC1,y=PC2,color=group))+
  geom_point(size=3)+
  theme_bw()+theme(panel.grid=element_blank())+labs(title=title)+
  xlab(paste("PC1(",pca.var.per[1],"%","variance)",sep=""))+
  ylab(paste("PC2(",pca.var.per[2],"%","variance)",sep=""))
PCA_png=paste0(outdir,'/',title,"_PCA.png")
PCA_pdf=paste0(outdir,'/',title,"_PCA.pdf")
ggsave(filename = PCA_png,p1,width=6, height=6)
ggsave(filename = PCA_pdf,p1,width=6, height=6)



#unique_group=unique(sample$group)
#unique_color=unique(sample$color)
#PCA_3D_png=paste0(outdir,'/',title,"_PCA_3D.png")
#png(file=PCA_3D_png, width = 700, height = 700)
#scatterplot3d(PCA1,PCA2,PCA3,color=sample$color,main = title,
#              pch = 16,angle=30,
#              box=T,type="p",
#              lty.hide=2,lty.grid = 2)
#legend("topright",xpd=TRUE,unique_group,fill=unique_color,box.col=NA,bg = "transparent",text.width=0)
#dev.off()

#PCA_3D_pdf=paste0(outdir,'/',title,"_PCA_3D.pdf")
#pdf(file=PCA_3D_pdf, width =12, height = 12)
#scatterplot3d(PCA1,PCA2,PCA3,color=sample$color,main = title,
#              pch = 16,angle=30,
#              box=T,type="p",
#              lty.hide=2,lty.grid = 2)
#legend("topright",xpd=TRUE,unique_group,fill=unique_color,box.col=NA,bg = "transparent",text.width=0)
#dev.off()