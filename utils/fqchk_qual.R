#!/usr/bin/env Rscript

library("docopt")
"Usage: base_quality_plt.R INPUT OUTPUT LABEL
Arguments:
   INPUT    the input file name  
   OUTPUT   the output filename
   LABEL     the title name" -> doc

opts   <- docopt(doc)
input  <- opts$INPUT
output <- opts$OUTPUT
name   <- opts$LABEL

library(ggplot2)

mydata <- read.table(input, header=T, sep="\t", comment.char = "", skip = 1)
mydata$X.POS <- factor(mydata$X.POS, level=unique(mydata$X.POS))

mystats <- function(x){
              x[x == 0] <- NA    
              qua <- c(1:length(x))
              t_data <-data.frame(x,qua)
              ndata <- na.omit(t_data)
              total <- apply(ndata, 2, sum)[1]
              prob <- c(0.1,0.25,0.5,0.75,0.9)
              y <-c()
              for (j in 1:5){
                  for( i in 1:nrow(ndata)){
                      k <- sum(ndata[(1:i),1])/total
                      if (k >= prob[j]){
                      y[j] <- ndata[i,2]
                      break}
                  }
              }
              return(y)
}

data_t <- t(mydata[, -(1:6)])
s_data <- apply(data_t, 2, mystats)

s_data <- t(s_data)
s_data <- as.data.frame(s_data)
s_data$POS <- mydata$X.POS


height_f <- 10

if ( nrow(s_data) < 100 )
   height_f <- 7

pdf(output, height = height_f, width  = as.integer(nrow(s_data)/301*40))

p <- ggplot(data=s_data, aes(  x      = POS, 
                               ymin   = s_data[,1],   #10th Percentile                     
                               ymax   = s_data[,5],   #90th Percentile
                               lower  = s_data[,2],   #Lower Quartile
                               middle = s_data[,3],   #Median
                               upper  = s_data[,4]))  #Upper Quartile
   
p <- p + geom_errorbar(aes(ymin   = s_data[,1], 
                           ymax   = s_data[,5],
                           colour = "red") )
p <- p + guides(color = F)
   
p <- p + geom_boxplot(stat="identity", colour="red") 
p <- p + geom_boxplot(stat="identity", aes( x      = POS, 
                                            ymin   = s_data[,3],
                                            ymax   = s_data[,3],
                                            lower  = s_data[,3],
                                            middle = s_data[,3],
                                            upper  = s_data[,3]),
                                            colour = "black") +
    scale_x_discrete(breaks=c(1, seq(0, nrow(s_data), 10)),
                     labels=c(1, seq(0, nrow(s_data), 10)))+
    scale_y_continuous(limits=c(0,42)) +
    theme_bw() +
    theme( text             = element_text(family="Times", face="bold", size = 20, colour = "black" ), 
          plot.title        = element_text(size = 20),
          axis.text.x       = element_text(size = 20, colour="black"),
          axis.text.y       = element_text(size = 20, colour="black"),
          strip.background  = element_blank(),
          ) +
    labs(x    = "Read Position", 
         y    = "Quality Score", 
         title= paste("Quality Scores for" , name))

p <- p + guides(fill=FALSE)

p

dev.off()