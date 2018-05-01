load("../SRP094910GeneData.RData")
tbl <- GeneData
deleters <- which(tbl$hgnc_symbol == "")
if(length(deleters) > 0)
   tbl <- tbl[-deleters,]
dups <- which(duplicated(tbl$hgnc_symbol))
if(length(dups) > 0)
   tbl <- tbl[-dups,]


mtx <- tbl[, 3:ncol(tbl)]
rownames(mtx) <- tbl$hgnc_symbol
stopifnot(nrow(mtx) == 14387)
stopifnot(ncol(mtx) == 197)

save(mtx, file="SRP094910.mtx.RData")

