#!/usr/bin/env Rscript

library("docopt")

"Usage: PCoA.R  [options]  INPUT RESULT
Options:
  -m --method=...  method for construct distance matrix:euclidean/jaccard/bray... [default: bray]
Arguments:
   INPUT         the input matrix
   RESULT        the result filename" -> doc

library("docopt")

opts     <- docopt(doc)
input    <- opts$INPUT
distance <- opts$method;
output   <- opts$RESULT;

library(vegan)

dt       <- t(read.table(input, head = TRUE, row.names=1, sep="\t", check.names=F, quote = "", comment.char=""))
matrix   <- as.matrix( vegdist(dt, method=distance ) )
matrix   <- cbind('matrix' = rownames(dt), as.data.frame(matrix))

write.table(matrix, output , sep="\t", row.names=FALSE, quote=FALSE)