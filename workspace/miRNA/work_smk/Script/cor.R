library(ggcorrplot)
args<-commandArgs(T)
quan=args[1]
outdir=args[2]
title=args[3]
data  <- read.table(quan,header = TRUE, row.names = 1,check.names=F)
data_cor=cor(data)
lower_limit <- min(data_cor)  # 获取相关系数的最小值
upper_limit <- max(data_cor)  # 获取相关系数的最大值


cor_png=paste0(outdir,'/',title,'_cor.png')
cor_pdf=paste0(outdir,'/',title,'_cor.pdf')

labs = T  #加相关性结果

if (dim(data_cor)[1] > 20){
  labs=F
}


pdf(file=cor_pdf, width = 12, height = 12)
ggcorrplot(data_cor,hc.order=F,outline.color="white",type="lower",show.diag = TRUE,lab = labs,title =title,digits=3)+
  scale_fill_gradient(low = "#BBFFFF", high = "red", limits = c(lower_limit,upper_limit), name = "Cor") +
  scale_color_gradient(low = "#BBFFFF", high = "red", limits = c(lower_limit,upper_limit), name = "Cor")+ 
  scale_y_discrete(position='right')+
  theme(panel.grid = element_blank())+
  theme(panel.background = element_blank())
dev.off()

png(file=cor_png, width = 1000, height = 1000)
ggcorrplot(data_cor,hc.order=F,outline.color="white",type="lower",show.diag = TRUE,lab = labs,title =title,digits =3)+
  scale_fill_gradient(low = "#BBFFFF", high = "red", limits = c(lower_limit,upper_limit), name = "Cor") +
  scale_color_gradient(low = "#BBFFFF", high = "red", limits = c(lower_limit,upper_limit), name = "Cor")+ 
  scale_y_discrete(position='right')+
  theme(panel.grid = element_blank())+
  theme(panel.background = element_blank())
dev.off()


