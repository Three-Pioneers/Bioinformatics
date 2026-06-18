library(grid)
library(graphics)
library(ComplexHeatmap)
library(dplyr)
library(circlize)

args<-commandArgs(T)
circlize_input=args[1]
outdir=args[2]

data <- read.delim(circlize_input, sep = '\t', row.names = 1, stringsAsFactors = FALSE, check.names = FALSE)
head(data)
dat<- bind_rows(
  
  data %>%filter(category == 'BP') %>%arrange('-log10Pvalue') %>% head(6),
  
  data %>%filter(category == 'CC') %>%arrange('-log10Pvalue') %>% head(6),
  
  data %>%filter(category == 'MF') %>%arrange('-log10Pvalue') %>% head(6),
  
)


dat$id <- factor(rownames(dat), levels = rownames(dat))

pdf=paste0(outdir,'/GO_circlize.pdf')

pdf(file=pdf, width = 24, height = 12)
#dev.off() 
circle_size = unit(1, 'snpc')
circos.par(gap.degree = 0.5, start.degree = 90)
plot_data <- dat[c('id', 'gene_num.min', 'gene_num.max')] 
ko_color <- c(rep('#F7CC13',6), rep('#954572',6), rep('#0796E0',6))#各二级分类的颜色和数目

circos.genomicInitialize(plot_data, plotType = NULL, major.by = 1) 
circos.track(
  ylim = c(0, 1), track.height = 0.08, bg.border = NA, bg.col = ko_color,   #圈厚度
  panel.fun = function(x, y) {
    ylim = get.cell.meta.data('ycenter')  
    xlim = get.cell.meta.data('xcenter')
    sector.name = get.cell.meta.data('sector.index') 
    circos.axis(h = 'top', labels.cex = 0.4, labels.niceFacing = FALSE)    #最外围数字大小
    circos.text(xlim, ylim, sector.name, cex = 0.6, col="white",niceFacing = FALSE)  #GO大小和颜色
  } )

#第二圈
plot_data <- dat[c('id', 'gene_num.min', 'gene_num.rich', '-log10Pvalue')] 
label_data <- dat['gene_num.rich']  
p_max <- round(max(dat$'-log10Pvalue')) + 1 
colorsChoice <- colorRampPalette(c('#FF906F', '#861D30'))  
color_assign <- colorRamp2(breaks = 0:p_max, col = colorsChoice(p_max + 1))

circos.genomicTrackPlotRegion(
  plot_data, track.height = 0.08, bg.border = NA, stack = TRUE,  
  panel.fun = function(region, value, ...) {
    circos.genomicRect(region, value, col = color_assign(value[[1]]), border = NA, ...) ##区块的长度反映了富集基因的数量，颜色与 p 值有关
    ylim = get.cell.meta.data('ycenter') 
    xlim = label_data[get.cell.meta.data('sector.index'),1] / 2
    sector.name = label_data[get.cell.meta.data('sector.index'),1]
    circos.text(xlim, ylim, sector.name, cex = 0.4, niceFacing = FALSE)  
  } )


#第三圈
dat$all.regulated <- dat$up.regulated + dat$down.regulated
dat$up.proportion <- dat$up.regulated / dat$all.regulated
dat$down.proportion <- dat$down.regulated / dat$all.regulated

if (any(is.na(dat))) {
  xx <- 1
} else {
  xx <- 10
}
print(xx)

dat[is.na(dat)] <- 0

dat$up <- dat$up.proportion * dat$gene_num.max
plot_data_up <- dat[c('id', 'gene_num.min', 'up')]
names(plot_data_up) <- c('id', 'start', 'end')
plot_data_up$type <- 1  

dat$down <- dat$down.proportion * dat$gene_num.max + dat$up
plot_data_down <- dat[c('id', 'up', 'down')]
names(plot_data_down) <- c('id', 'start', 'end')
plot_data_down$type <- 2 

plot_data <- rbind(plot_data_up, plot_data_down)
label_data <- dat[c('up', 'down', 'up.regulated', 'down.regulated')]
color_assign <- colorRamp2(breaks = c(1, 2), col = c('red', 'blue'))

circos.genomicTrackPlotRegion(
  plot_data, track.height = 0.10, bg.border = NA, stack = TRUE, 
  panel.fun = function(region, value, ...) {
    circos.genomicRect(region, value, col = color_assign(value[[1]]), border = NA, ...)  
    ylim = get.cell.meta.data('cell.bottom.radius') - 0.5 
    xlim = label_data[get.cell.meta.data('sector.index'),1] / 2
    sector.name = label_data[get.cell.meta.data('sector.index'),3]
    circos.text(xlim, ylim, sector.name, cex = 0.4, niceFacing = FALSE)  
    xlim = (label_data[get.cell.meta.data('sector.index'),2]+label_data[get.cell.meta.data('sector.index'),1]) / 2
    sector.name = label_data[get.cell.meta.data('sector.index'),4]
    circos.text(xlim, ylim, sector.name, cex = 0.4, niceFacing = FALSE)
  } )

#第四圈
plot_data <- dat[c('id', 'gene_num.min', 'gene_num.max', 'rich.factor')]  
plot_data$rich.factor <- plot_data$rich.factor *xx
label_data <- dat['category'] 
color_assign <- c('BP' = '#F7CC13', 'CC' = '#954572', 'MF' = '#0796E0')#各二级分类的名称和颜色
circos.genomicTrack(
  plot_data, ylim = c(0, 1), track.height = 0.3, bg.col = 'gray95', bg.border = NA, 
  panel.fun = function(region, value, ...) {
    sector.name = get.cell.meta.data('sector.index')  
    circos.genomicRect(region, value, col = color_assign[label_data[sector.name,1]], border = NA, ytop.column = 1, ybottom = 0, ...) 
    circos.lines(c(0, max(region)), c(0.5, 0.5), col = 'gray', lwd = 0.3) 
})
    
    
category_legend <- Legend(
  title="Category",
  labels = c('BP', 'CC', 'MF'),#各二级分类的名称
  type = 'points', pch = NA, background = c('#F7CC13', '#954572', '#0796E0'),#各二级分类的颜色 
  labels_gp = gpar(fontsize = 8), grid_height = unit(0.5, 'cm'), grid_width = unit(0.5, 'cm'))

updown_legend <- Legend(
  labels = c('Up', 'Down'), 
  type = 'points', pch = NA, background = c('red', 'blue'), 
  labels_gp = gpar(fontsize = 8), grid_height = unit(0.5, 'cm'), grid_width = unit(0.5, 'cm'))
pvalue_legend <- Legend(
  col_fun = colorRamp2(round(seq(0, p_max, length.out = 6), 0), 
                       colorRampPalette(c('#FF906F', '#861D30'))(6)),
  legend_height = unit(3, 'cm'), labels_gp = gpar(fontsize = 8), 
  title_gp = gpar(fontsize = 9), title_position = 'topleft', title = '-Log10(Pvalue)')

lgd_list_vertical <- packLegend(category_legend, updown_legend, pvalue_legend)
grid.draw(lgd_list_vertical)
circos.clear()
dev.off()   
    
    
    
    
    
    
    
    
    