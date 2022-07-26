#!/usr/bin/env Rscript

library("docopt")

"Usage: upgma.R  [options]  INPUT METADATA PHYLUM RESULT LABEL
Options:
Arguments:
   INPUT         the input matrix
   METADATA      the catalog file.
   PHYLUM        the phylum taxonomy profile.
   RESULT        the result.
   LABEL         distance type." -> doc

opts  <- docopt(doc)

input    <- opts$INPUT
metadata <- opts$METADATA
output   <- opts$RESULT
phylum   <- opts$PHYLUM
type     <- opts$LABEL

library(RColorBrewer)
library(colorspace)
library(dendextend)

distance  <- read.table(input, row.names= 1, header=T, check.name=F, comment.char = "")
upgma     <- hclust(as.dist(distance),"ave")
dend      <- as.dendrogram(upgma)

#color from QIIME1 
cols  <-c("#ff0000","#0000ff","#f27304","#008000","#91278d","#a02d00","#7cecf4",
          "#f49ac2","#5da09e","#6b440b","#808080","#02f40e","#f79679","#7da9d8",
          "#fcc688","#80c99b","#a287bf","#fff899","#c0c0c0","#ed008a","#00b6ff",
          "#c49c6b","#808000","#8c3fff","#bc828d","#008080","#800000","#2b4200",
          "#a54700","#331500","#3b0070","#ffff00")

catalog <- read.table(metadata, header = F, sep="\t",comment.char="", check.names=F, stringsAsFactors=F)
colnames(catalog)<-c("sample","group")

catalog$group <- factor(catalog$group, level=unique(catalog$group), ordered=TRUE)

dend<-set(dend, "leaves_pch", 15)
labels_colors(dend) <-cols[1 : length(unique(catalog$group))][sort_levels_values(as.numeric(catalog$group)[order.dendrogram(dend)])]

taxon <- read.table(phylum, row.names= 1, header=T, check.name=F,comment.char = "")
n  <- upgma$order
m  <- colnames(distance)[c(upgma$order)]
g  <- matrix(ncol=ncol(taxon), nrow=nrow(taxon))

for(i in 1:ncol(taxon))
   g[, i] <- taxon[, n[i]]

colnames(g) <- m
rownames(g) <- rownames(taxon)

pdf_h   <-nrow(taxon)*10/155 + 5
pdf_w   <-ncol(taxon)/8 + 10

pdf(output, width=pdf_w, height=pdf_h )

layout(matrix(c(1, 1, 1, 1, 2, 2, 2, 3, 3), nrow = 1))

par(mar=c(3, 1, 2, 6), cex = 0.5, font=2, lwd=0.1)
dend %>% plot(horiz=T, axes=T, main=paste(type , "tree", sep=" "), nodePar = list(cex = 0.5))

par(mar=c(3, 1, 2, 1), cex = 0.5)
barplot(g,col=cols[1:(nrow(taxon) + 1)], horiz=T, axisnames=F,axes=T, main="Taxonomy:Phylum",border = NA )

par(mar=c(3, 0, 2, 1), cex = 1)
plot(1:3, rnorm(3), pch = 1, lty = 1, ylim=c(-2, 2), type = "n", axes = FALSE, ann = FALSE)

legend(1, 2, legend=rownames(taxon), bty="n", fill=cols[1: nrow(taxon)])

dev.off()
