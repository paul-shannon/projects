library(affy)
library(org.At.tair.db)
library(ag.db)

sampleNames <- c("zinc.absent.01", "zinc.absent.02", "zinc.absent.03", "zinc.absent.04",
                 "zinc.present.01", "zinc.present.02", "zinc.present.03", "zinc.present.041")
tbl.pheno <- data.frame(tissue=factor(rep("Root", 8)),
                        status=factor(rep("WT",   8)),
                        zinc=factor(c(rep("-", 4), rep("+", 4))))
rownames(tbl.pheno) <- sampleNames

data <- ReadAffy(celfile.path="geoExpressionData",
                 phenoData=tbl.pheno,
                 sampleNames=sampleNames)
eset <- rma(data)
boxplot(data)
sampleNames(data)
probeNames <- geneNames(data)
pm(data, geneNames[100])          # perfect match


#----------------------------------------------------------------------------------------------------
# head(probeNames)  "244901_at" "244902_at" "244903_at" "244904_at" "244905_at" "244906_at"
# map probes to canonical gene symbols
# ls("package:ag.db")
# head(ls(agGENENAME))  # [1] "11986_at"   "11987_at"   "11988_at"   "11989_at"   "11990_at"   "11991_g_at"
# query <- "SELECT gene_id FROM genes LIMIT 10;"   # result = dbGetQuery(org.Hs.eg_dbconn(), query)
# columns(ag.db)  # same as keytypes(ag.db)
#  [1] "ARACYC"       "ARACYCENZYME" "ENTREZID"     "ENZYME"       "EVIDENCE"     "EVIDENCEALL"  "GENENAME"
#  [8] "GO"           "GOALL"        "ONTOLOGY"     "ONTOLOGYALL"  "PATH"         "PMID"         "PROBEID"
# [15] "REFSEQ"       "SYMBOL"       "TAIR"
#
# might have the wrong (too recent) chip annotation:
# length(unique(probeNames))  # [1] 22810
#  length(setdiff(probeNames, keys(ag.db))) # 22777
#
# -- found this table at the geo webpage for the experiment
#   https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GPL198
#  where a mapping table download is offered:
tbl.geneAnnotation <- read.table("geoExpressionData/GPL198-17390.txt", sep="\t", as.is=TRUE, fill=TRUE, quote="", header=TRUE)
length(setdiff(probeNames, tbl.geneAnnotation$ID))  # 0
# but some duplicated gene symbols
length(which
dups <- which(duplicated(tbl.geneAnnotation$Gene.Symbol))  # [1] 1609
if(length(dups) > 0){
   tbl.annoNoDups <- tbl.geneAnnotation[-dups,]
   mtx <- mtx[-dups,]    # row by row, same order of probes in mtx as tbl.geneAnnotation
   }
rownames(mtx) <- tbl.geneAnnotation$Gene.Symbol

