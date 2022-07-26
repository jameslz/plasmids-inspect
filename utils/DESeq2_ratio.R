#!/usr/bin/env Rscript

"Usage: DESeq_ratio [options] INPUT CASE  CONTROL OUTPUT LABEL
Options:
   -w --width=width    the width of viewport [default: 7] 
   -h --height=width    the height of viewport [default: 7]
Arguments:
   INPUT   the input file name
   CASE    case condition
   CONTROL control condition
   OUTPUT  the output file name
   LABEL   label the qvalue."->doc

library(docopt)

opts    <- docopt(doc)
case    <- opts$CASE
control <- opts$CONTROL
output  <- opts$OUTPUT
label   <- opts$LABEL

library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(vegan)
library(viridis)
library(ggplot2)
library(ggrepel) ##该包能够解决散点图样品标签重叠的问题，方便筛选样品


dt  <- read.table(opts$INPUT, header=TRUE, sep="\t", check.name=F, quote="", comment.char="", stringsAsFactors=F,  fill=TRUE)

dt <-dt %>%
     mutate(ID=replace(ID, regulation=='Not DE', NA)) %>%
     as.data.frame()

p <-  ggplot(dt, aes(x  =log2FoldChange, y = -log10(padj), colour=regulation)) +
      geom_point(size = 3) +
      geom_hline(yintercept=-log10(0.01),
                 linetype=4, 
                 color = 'gray', 
                 size = 0.25) +
      geom_vline(xintercept=c(-1,1),
                 linetype=4, 
                 color = 'gray', 
                 size = 0.25) +
      theme_classic() +
      theme( text              = element_text(family="Times", face="plain", size = 12, colour="black" ),
             axis.text         = element_text(family="Times", face="plain"),
             axis.text.x       = element_text(family="Times", face="plain"),
             axis.text.y       = element_text(family="Times", face="plain", size = 12 ) , 
             axis.title        = element_text(family="Times", face="plain", size = 12),
             axis.title.x      = element_text(family="Times", face="bold",  size = 18),
             axis.title.y      = element_text(family="Times", face="bold",  size = 18),
             plot.title        = element_text(family="Times", face="plain"),
             legend.text       = element_text(family="Times", face="plain"),
             legend.title      = element_text(family="Times", face="plain"),
             legend.position   = c(0.25, 0.85)) +
      scale_x_continuous(limits = c(-15,15), breaks = seq(-10, 10, 2), labels = seq(-10, 10, 2)) +
      geom_text_repel(data=dt, 
                      aes(x=log2FoldChange, y=-log10(padj), label=ID), 
                      hjust=0.5, 
                      vjust=0.5, 
                      size=2) +
      scale_color_manual(name=bquote(paste(FDR <= .(label) , " and " ,  '|log2ratio| >= 1')),
                breaks= c("Up", "Down", "Not DE"),
                values = c("Up" = "#F8766D", "Down" = "#09BA38", "Not DE" = "#619CFF"), 
                labels = c("Up-regulated", "Down-regulated", "Not DE")) +
      labs(x= "log2FoldChange", y= "-log10(padj)") +
      ggtitle(paste( case, control, sep = " vs. "))


ggsave(output, device = "pdf", width=as.numeric(opts$w), height=as.numeric(opts$h))