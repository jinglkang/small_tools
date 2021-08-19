# This my first R script, and this script still has many limitations

#!/usr/bin/env Rscript
library(DESeq2)
library("BiocParallel")
register(MulticoreParam(4))
library(ggplot2)
library(ggsci)
library(ggpubr)

args <- commandArgs(trailingOnly=TRUE)
cts <- read.table(args[1],header=TRUE,row.names = 1) # args[1]: total_Blenny.gene.matrix
total_ind <- ncol(cts)
coldata <- read.table(args[2]) # args[2]: coldata_Blenny.txt

dds <- DESeqDataSetFromMatrix(countData = cts,
                              colData = coldata,
                              design= ~Site_1) # a string

keep <- rowSums(counts(dds)) >= total_ind*10
dds <- dds[keep,]
dds <- DESeq(dds)
vsd <- vst(dds, blind=FALSE)
pcaData <- plotPCA(vsd, intgroup=c("Site_1"), returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))

output<-paste(args[3], ".pdf", sep="")
pdf(file = output, width = 11.69, height = 8.27)

ggplot(pcaData, aes(PC1, PC2,color=Site_1)) +
  geom_point(size=6)  + theme_bw() +
  geom_text(aes(label=""), hjust=1, vjust=2, show.legend = FALSE, family="Times", colour="black",size=8) + # 去掉legend中产生的"a"
  theme(panel.grid=element_blank()) +
  geom_text(aes(label=name, colour=Site_1), hjust=1, vjust=2, show.legend = FALSE, family="Times", colour="black",size=4) +
  theme(legend.position = "top", legend.title = element_blank()) +
  theme(axis.text.x=element_text(colour = "black", family="Times",size=20), #设置x轴刻度标签的字体显示倾斜角度为15度，并向下调整1(hjust = 1)，字体簇为Times大小为20
        axis.text.y=element_text(family="Times",size=20,colour = "black"), #设置y轴刻度标签的字体簇，字体大小，字体样式为plain
        axis.title.y=element_text(family="Times",size = 25,face="bold"), #设置y轴标题的字体属性
        axis.title.x=element_text(family="Times",size = 25,face="bold"), #设置x轴标题的字体属性
        # panel.border = element_blank(),axis.line = element_line(colour = "black"), #去除默认填充的灰色，并将x=0轴和y=0轴加粗显示(size=1)
        legend.text=element_text(face="bold", family="Times", colour="black",size=18),  #设置图例的子标题的字体属性
        # legend.title=element_text(face="plain", family="Times", colour="black",size=8), #设置图例的总标题的字体属性
  ) +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance")) +
  scale_color_manual(values=c('#DC0000FF','#F39B7F99','#7E6148FF','#00A087FF'))

dev.off()
