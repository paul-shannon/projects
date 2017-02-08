library(jsonlite)
file <- "~/github/TReNA/inst/extdata/ampAD.58genes.mef2cTFs.278samples.RData"
stopifnot(file.exists(file))
print(load(file))
mtx.dist <- dist(mtx.sub)
mtx.xyz <-cmdscale(mtx.dist, eig=FALSE, k=3)
tbl.mds <- as.data.frame(mtx.xyz)
tbl.mds$gene <- rownames(tbl.mds)
rownames(tbl.mds) <- NULL
colnames(tbl.mds) <- c("x", "y", "z", "gene")
tbl.mds <- tbl.mds[, c("gene", "x", "y", "z")]
toJSON(tbl.mds)
