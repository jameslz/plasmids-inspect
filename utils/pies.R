#!/usr/bin/env Rscript

"Usage:pies  [options] INPUT  OUTPUT  NAME
Options:
Arguments: 
   INPUT    the input file name
   OUTPUT   the output filename
   NAME     the title name" -> doc

library("docopt")
opts      <- docopt(doc)
input     <- opts$INPUT
output    <- opts$OUTPUT
label     <- opts$NAME   

library(Cairo)
library(tidyverse)
library(hrbrthemes)
library(viridis)

dt <-read.table(input,header=F, comment.char="#", check.name=F, sep="\t", quote = "")

cols<-c("#f44336","#2196f3","#9c27b0","#673ab7","#3f51b5","#00bcd4","#ff6e40",
        "#009688","#4caf50","#8bc34a","#cddc39","#ffeb3b","#ffc107","#ff9800",
        "#ff5722","#795548","#9e9e9e","#607d8b","#455a64","#e57373","#f06292",
        "#ba68c8","#9575cd","#7986cb","#64b5f6","#4fc3f7","#4dd0e1","#4db6ac",
        "#81c784","#aed581","#dce775","#fff176","#ffd54f","#ffb74d","#ff8a65",
        "#bcaaa4","#eeeeee","#b0bec5","#ff5252","#e040fb","#7c4dff","#448aff",
        "#18ffff","#69f0ae","#eeff41","#ffd740")

colnames(dt)<-c("catalog","values")


p <- ggplot(data = dt, aes(x = catalog, y = values, fill = catalog)) +
         geom_bar(stat= 'identity', width = 1) +
         scale_fill_manual(values=cols[1:length(unique(dt$catalog))]) +
         theme_ipsum() +     
         theme(text        = element_text(family="Times", face="plain", size = 12, colour="black" ),
             axis.text     = element_text(family="Times", face="plain", size = 12),
             axis.text.x   = element_blank(),
             axis.text.y   = element_text(family="Times", face="plain", size = 12 ), 
             axis.title    = element_text(family="Times", face="plain", size = 12 ),
             axis.title.x  = element_blank(),
             axis.title.y  = element_text(family="Times", face="plain", size = 12),
             plot.title    = element_text(family="Times", face="plain", size = 12 )) +
         labs(title = label) +
         coord_polar(theta = 'x') +
         geom_text(aes(label = values), size = 2, nudge_y = 12)
 
ggsave(output, device = "pdf", height=5, width = 10)
