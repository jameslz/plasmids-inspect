#!/usr/bin/env Rscript

"Usage: fqchk_base.R INPUT OUTPUT NAME
Arguments:
   INPUT    the input file name  
   OUTPUT   the output filename
   NAME     the title name" -> doc

library("docopt")
opts     <- docopt(doc)
input    <- opts$INPUT
output   <- opts$OUTPUT
name     <- opts$NAME

library(ggplot2)
mydata <- read.table(input, header=T, sep="\t", comment.char = "",skip = 1)

b_data <- mydata[, c(2:6)]
x2     <- stack(b_data)

x2$group <- rep(mydata$X.POS, ncol(b_data))

x2$group <- factor(x2$group, level=unique(x2$group))
x2$ind   <- factor(x2$ind,   level=unique(x2$ind))

height_f <- 11
if ( nrow(mydata) < 100 )
   height_f <- 7

pdf(output, height = height_f, width=as.integer(nrow(mydata)/6))

ggplot(x2,aes(x=group, y=values, fill=ind)) + 
    geom_bar(stat="identity", position="fill") + 
    theme_bw() +
    theme(text            = element_text(family="Times", face="bold", size = 20, colour = "black" ),
        legend.title      = element_blank(),
        legend.key.size   = unit(0.4, "cm"),
        legend.text  = element_text(size = 20),
        axis.text.x  = element_text(size = 20, colour="black"),
        axis.text.y  = element_text(size = 20, colour="black")) +
    labs( x     = "Position in read(bp)",
  	      y     = "% of total (per read position)",
          title = paste("Nucleotides distribution for", name, sep=" ")) +
  scale_x_discrete(breaks=c(1, seq(0, nrow(x2), 10)),
  	               labels=c(1, seq(0, nrow(x2), 10))) + 
  scale_y_continuous(expand=c(0, 0))
  

dev.off()