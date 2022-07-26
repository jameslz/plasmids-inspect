#!/usr/bin/env Rscript

library("docopt")

"Usage: barplot.R  [options]  INPUT  RESULT LABEL
Options:
  -f --font=12  the font size [default: 7]
Arguments:
   INPUT         the input matrix
   RESULT        the result filename
   LABEL         label" -> doc

   
opts  <- docopt(doc)

input <- opts$INPUT
output<- opts$RESULT
label <- opts$LABEL
font  <- as.integer(opts$f)

library(grid)
library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(viridis)

cols<-c("#f44336","#2196f3","#9c27b0","#673ab7","#3f51b5","#00bcd4","#ff6e40",
        "#009688","#4caf50","#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800",
        "#ff5722","#795548","#9e9e9e","#607d8b","#455a64","#e57373","#f06292",
        "#ba68c8","#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac",
        "#81c784","#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65",
        "#bcaaa4","#eeeeee","#b0bec5","#ff5252","#e040fb","#7c4dff","#448aff",
        "#18ffff","#69f0ae","#eeff41","#ffd740")

matrix <- read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char="")
stack<-stack(matrix)

stack$taxon  <- rep(rownames(matrix), ncol(matrix))
stack$ind    <- factor(stack$ind, level = unique(stack$ind), ordered=TRUE)

pdf_w <-length(colnames(matrix))*45/155+8;
pdf_h <-length(rownames(matrix))/20+5;


p <- ggplot(stack, aes(x=ind, y=values, fill=taxon)) + 
     geom_bar(stat="identity", position="fill", width=0.7) + 
     theme_ipsum() +
     theme(text            = element_text(family="Times", face="plain", size = 12, colour="black" ),
         axis.text         = element_text(family="Times", face="plain"),
         axis.text.x       = element_text(family="Times", face="plain", size = 10, angle =45, vjust =1, hjust=1),
         axis.text.y       = element_text(family="Times", face="plain", size = 12 ) , 
         axis.title        = element_text(family="Times", face="plain", size = 12),
         axis.title.x      = element_text(family="Times", face="plain", size = 12),
         axis.title.y      = element_text(family="Times", face="plain", size = 12),
         plot.title        = element_text(family="Times", face="plain"),
         legend.text       = element_text(family="Times", face="plain"),
         legend.title      = element_text(family="Times", face="plain"),
         legend.position   = "bottom") +
    labs(x="Specimens", y="Relative Abundance") +
    scale_y_continuous(expand = c(0, 0)) + 
	guides(guide_legend(reverse = T))+
	scale_fill_manual(values=cols[1:length(unique(stack$taxon))], name = label)

ggsave(output, device = "pdf", width = ceiling(pdf_w), height = ceiling(pdf_h))
