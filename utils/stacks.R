#!/usr/bin/env Rscript

library("docopt")

"Usage: barplot.R  [options]  INPUT  RESULT LABEL
Arguments:
   INPUT         the input matrix
   RESULT        the result filename
   LABEL         label" -> doc

opts  <- docopt(doc)

input <- opts$INPUT
output<- opts$RESULT
label <- opts$LABEL

library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(viridis)

dt    <- read.table(input, header=T, sep="\t", colClasses = 'character', stringsAsFactors = F, quote = "", comment.char = "", row.names=1)
stack <-stack(dt)

stack$catalog  <- rep(rownames(dt), ncol(dt))
stack$values   <- as.numeric(stack$values )

cols<-c("#f44336","#2196f3","#9c27b0","#673ab7","#3f51b5","#00bcd4","#ff6e40",
        "#009688","#4caf50","#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800",
        "#ff5722","#795548","#9e9e9e","#607d8b","#455a64","#e57373","#f06292",
        "#ba68c8","#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac",
        "#81c784","#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65",
        "#bcaaa4","#eeeeee","#b0bec5","#ff5252","#e040fb","#7c4dff","#448aff",
        "#18ffff","#69f0ae","#eeff41","#ffd740")

pdf_w = ncol(dt)*45/155 + 8;

p <- ggplot(stack, aes(x=ind, y=values, fill=catalog)) + 
     geom_bar(stat="identity", position="stack", width=0.7) + 
     theme_ipsum() +
     theme(text        = element_text(family="Times", face="plain", size = 12, colour="black" ),
         axis.text     = element_text(family="Times", face="plain", size = 12),
         axis.text.x   = element_text(family="Times", face="plain", angle =45, vjust =1, hjust=1),
         axis.text.y   = element_text(family="Times", face="plain", size = 12 ) , 
         axis.title.x  = element_text(family="Times", face="plain", size = 12),
         axis.title.y  = element_text(family="Times", face="plain", size = 12)) +
    labs(x="catalog", y="values") +
    scale_y_continuous(expand = c(0, 0)) + 
  guides(guide_legend(reverse = T))+
  scale_fill_manual(values=cols, name = label)

ggsave(output, device = "pdf", width = ceiling(pdf_w))
