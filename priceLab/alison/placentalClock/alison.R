print(load("SRP094910GeneData.RData"))   # 16407 x 199
mtx.rna <- as.matrix(GeneData[, 3:199])
fivenum(mtx.rna) # [1]  0.000000  1.411374  1.992753  2.648852 13.378017
# give rownames to the matrx.  incautiously, use gene symbols, removing duplicates
geneSymbols <- GeneData$hgnc_symbol
rows.to.remove <- which(duplicated(geneSymbols))
length(rows.to.remove)
if(length(rows.to.remove) > 0){
   mtx.rna <- mtx.rna[-rows.to.remove,]
   geneSymbols <- geneSymbols[-rows.to.remove]
   }

rownames(mtx.rna) <- geneSymbols
dim(mtx.rna)   # 14388 197
fivenum(mtx.rna)  #  0.000000  1.495579  2.061975  2.708345 13.378017

library(RPostgreSQL)
database.host <- "khaleesi.systemsbiology.net"
dbname <- "extraembryonic_structure_hint_20"
db <- dbConnect(PostgreSQL(), user= "trena", password="trena", host=database.host, dbname=dbname)
dbName <- "brain_hint"


