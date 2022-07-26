#!/usr/bin/env Rscript

library("docopt")

"Usage: lollipop  [options]  INPUT RESULT LABEL
Options:
Arguments:
   INPUT         The input matrix
   RESULT        The result filename
   LABEL         Label" -> doc

opts  <- docopt(doc)

input <- opts$INPUT
output<- opts$RESULT
label <- opts$LABEL

library(Cairo)
library(bbplot)
library(tidyverse)
library(hrbrthemes)
library(kableExtra)

abundance <- read.table(input, header=TRUE, sep="\t", quote = "", comment.char="")
names(abundance) <- c('level', 'abundance')

p <- abundance %>%
  arrange(abundance) %>%
  tail(10) %>%
  mutate(level=factor(level, level)) %>%
  mutate(abundance=abundance) %>%
  ggplot( aes(x=level, y=abundance) ) +
    geom_segment( aes(x=level , xend=level,  y = 0, yend=abundance), color="#1380A1", size=10) +
    coord_flip() +
    theme_ipsum() +
    theme(
      text               = element_text(family="Times", face="plain", size = 10),
      axis.title.x       = element_text(family="Times", face="plain", size = 10),
      axis.title.y       = element_text(family="Times", face="plain", size = 10),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.y = element_blank(),
      legend.position    = "none"
    ) +
    xlab(paste0(label, sep=" ")) +
    ylab("abundance")

ggsave(output, device = "pdf", width = 12, height = 5)
