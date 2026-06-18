library(tidyverse)
library(data.table)

args<-commandArgs(T)


COUNT_file = args[1]
coldata_file=args[2]
outdir = args[3]
title=args[4]

colData=read.table(coldata_file,header=T,sep="\t",quote="",check.names=F,as.is=T)
data <- fread(COUNT_file,header=T,data.table=F)
colnames(data)[1] <- "ID"

#按分组算每组的FPKM均值
groups = as.character(unique(colData$group))

getGroupMean <- function(group){
    rows = dplyr::filter(colData, group == group) %>% select("sample_id") %>% unlist %>% as.character
	data[[group]] <<- rowMeans(data[,rows,F], na.rm = TRUE)
    return (1)
    }
sapply(groups, getGroupMean)



#melt转换
data1 <- select(data,any_of(groups),ID)
data2 <- as.data.table(data1)
data3 <- melt(data2, id.vars = "ID")
colnames(data3)  <- c("ID", "Group", 'number')
#log
data4 <- mutate(data3, log=log10(number+1))

ylab_name=paste0('log10(',title,'+1)')

p <- ggplot(data4, aes(x = Group, y = log, fill = Group)) + 
geom_violin(alpha = 0.5) +  scale_y_log10() +
geom_boxplot(width=0.1, aes(fill=Group)) +
theme_classic() +
ylab(ylab_name) +
xlab(NULL) +
theme(axis.text.x = element_text(angle=90, hjust=1, vjust=.5))
#由于scale_y_log10()，作图去掉了FPKM为0的值

png=paste0(outdir,'/',title,'_violin.png')
pdf=paste0(outdir,'/',title,'_violin.pdf')
ggsave(file=png,p, width=6, height=6, units="in")
ggsave(file=pdf,p, width=6, height=6, units="in")
