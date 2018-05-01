library(igvR)
library(trena)
library(RPostgreSQL)

if(!exists("igv")){
   igv <- igvR()
   setGenome(igv, "hg38")
   showGenomicRegion(igv, "FLT1")
   }

snps <- c("rs4769613", "rs12050029")
if(!exists("tbl.snps")){
   if(file.exists("tbl.snps.RData"))
      load("tbl.snps.RData")
   else{
      library(SNPlocs.Hsapiens.dbSNP150.GRCh38)
      tbl.snps <- as.data.frame(snpsById(SNPlocs.Hsapiens.dbSNP150.GRCh38, snps))
      save(tbl.snps, file="tbl.snps.RData")
      }
  } # if !tbl.snps

tbl.snps.2 <- data.frame(chrom=tbl.snps$seqnames, start=tbl.snps$pos, end=tbl.snps$pos, id=tbl.snps$RefSNP_id,
                         stringsAsFactors=FALSE)
track.snps <- DataFrameAnnotationTrack("snps", tbl.snps.2, color="red", displayMode="EXPANDED")
displayTrack(igv, track.snps)
showGenomicRegion(igv, "chr13:28,299,045-28,689,676")



database.host <- "khaleesi.systemsbiology.net"
db <- dbConnect(PostgreSQL(), user="trena", password="trena", host=database.host, dbname="hg38")
dboi <- grep("embryonic", dbGetQuery(db, "select datname from pg_database")$datname, v=TRUE, ignore.case=TRUE)
    #  "extraembryonic_structure_hint_16"
    #  "extraembryonic_structure_wellington_16"
    #  "extraembryonic_structure_hint_20"
    #  "extraembryonic_structure_wellington_20"

db.h16 <- dbConnect(PostgreSQL(), user="trena", password="trena", host=database.host, dbname="extraembryonic_structure_hint_16")
db.h20 <- dbConnect(PostgreSQL(), user="trena", password="trena", host=database.host, dbname="extraembryonic_structure_hint_20")
db.w16 <- dbConnect(PostgreSQL(), user="trena", password="trena", host=database.host, dbname="extraembryonic_structure_wellington_16")
db.w20 <- dbConnect(PostgreSQL(), user="trena", password="trena", host=database.host, dbname="extraembryonic_structure_wellington_20")
queryString <- with(getGenomicRegion(igv),
                     sprintf("select * from regions where chrom='%s' and start > %d and endpos < %d", chrom,start,end))
tbl.h16.regions <- dbGetQuery(db.h16, queryString)

#----------------------------------------------------------------------------------------------------
getHits <- function(db, chrom, start, stop)
{
    query.p0 <- "select loc, chrom, start, endpos from regions"
    query.p1 <- sprintf("where chrom='%s' and start > %d and endpos < %d", chrom, start, stop)

    query.regions <- paste(query.p0, query.p1)
    tbl.regions <- dbGetQuery(db, query.regions)
    if(nrow(tbl.regions) == 0)
       return(data.frame())
    loc.set <- sprintf("('%s')", paste(tbl.regions$loc, collapse="','"))
    query.hits <- sprintf("select * from hits where loc in %s", loc.set)
    invisible(dbGetQuery(db, query.hits))

} # getHits
#----------------------------------------------------------------------------------------------------
# 403kb
# showGenomicRegion(igv, "chr13:28,289,173-28,693,086")
chrom <- "chr13"
start <- 28289173
end <- 28693086
tbl.bigRegion <- data.frame(chrom=chrom, start=start, end=end, stringsAsFactors=FALSE)
bigRegion <- with(tbl.bigRegion, sprintf("%s:%d-%d", chrom, start, end))
showGenomicRegion(igv, bigRegion)

# +/- 5kb
chrom <- "chr13"
start <- 28490000
end   <- 28500000
showGenomicRegion(igv, sprintf("%s:%d-%d", chrom, start, end))

# chr13:28,488,572-28,669,899 covers 181 kb, including both snps
chrom <- "chr13"
start <- 28488572
end <- 28669899

dbs <- list(h16=db.h16,
            h20=db.h20,
            w16=db.w16,
            w20=db.w20)

fps <- list()
for(db in names(dbs)){
   tbl.hits <- getHits(dbs[[db]], chrom, start, end)
   tbl.hits$chrom <- unlist(lapply(strsplit(tbl.hits$loc, ":"), "[",  1))
   tbl.hits.clean <- tbl.hits[, c("chrom", "fp_start", "fp_end", "name")]
   fps[[db]] <- tbl.hits.clean
   #track <- DataFrameAnnotationTrack(db, tbl.hits.clean, color="darkblue", displayMode="SQUISHED")
   #displayTrack(igv, track)
   }

#save(fps, file="fps.RData")
#load("fps.RData")
load("fps.big.RData")
tbl.fp <- do.call(rbind, fps.big)   # 34930 x 4
gr.fp <- with(tbl.fp, GRanges(seqnames=chrom, IRanges(start=fp_start, end=fp_end)))
gr.fp.reduced <- reduce(gr.fp)  # 90
length(gr.fp)
length(gr.fp.reduced)
track.fp.reduced <- GRangesAnnotationTrack("fp.reduced", gr.fp.reduced)
displayTrack(igv, track.fp.reduced)


#--------------------------------------------------------------------------------
# get the dhs open chromatin regions, reduce with footprints
#--------------------------------------------------------------------------------
pfms <- as.list(query(query(MotifDb, "sapiens"),"jaspar2018"))
tbl.regions <- tbl.bigRegion
hdf <- HumanDHSFilter("hg38",
                      encodeTableName="wgEncodeRegDnaseClustered",
                      pwmMatchPercentageThreshold=85L,
                      geneInfoDatabase.uri=genome.db.uri    <- "postgres://bddsrds.globusgenomics.org/hg38",
                      region=tbl.regions,
                      pfms = pfms,
                      quiet=TRUE)

if(file.exists("tbl.dhs.candidates.RData"))
   load("tbl.dhs.candidates.RData")
else{
   tbl.dhs.candidates <- getCandidates(hdf)
   save(tbl.dhs.candidates, file="tbl.dhs.candidates.10kb.RData")
   }

tbl.dhs <- with(tbl.regions, getRegulatoryRegions(hdf, "wgEncodeRegDnaseClustered", chrom, start, end))
track.dhs <- DataFrameAnnotationTrack("dhs", tbl.dhs, color="darkblue", displayMode="SQUISHED")
displayTrack(igv, track.dhs)

gr.dhs <- with(tbl.dhs, GRanges(seqnames=chrom, IRanges(start=chromStart, end=chromEnd)))
gr.dhsfp <- reduce(c(gr.fp.reduced, gr.dhs))  # 42 regions
track.dhsfp <- GRangesAnnotationTrack("fp.dhs.reduced", gr.dhsfp, color="darkgreen")
displayTrack(igv, track.dhsfp)

save(tbl.fp, gr.fp, gr.fp.reduced, tbl.dhs, gr.dhs, gr.dhsfp, file="all.10kb.fp.dhs.RData")

#--------------------------------------------------------------------------------
# get the enhancers
#--------------------------------------------------------------------------------
print(load("../FTL1.RData"))
tbl.enhancer <- ftl1.enhancer
gr.enhancer <- with(tbl.enhancer, GRanges(seqnames=chrom, IRanges(start=start, end=end)))
track.enhancer <- GRangesAnnotationTrack("enhancers", gr.enhancer, color="purple")
displayTrack(igv, track.enhancer)

#--------------------------------------------------------------------------------
# find motifs in these enhancers, 339kb, using motifdb motif/db mapping
#--------------------------------------------------------------------------------
pfms <- as.list(query(query(MotifDb, "sapiens"),"jaspar2018"))
mm <- MotifMatcher("hg38", pfms)
tbl.motifs.enhancerAll <- findMatchesByChromosomalRegion(mm, tbl.enhancer[, c("chrom", "start", "end")], pwmMatchMinimumAsPercentage=85)
dim(tbl.motifs.enhancerAll) # 28343    13
tbl.motifs.enhancerAll.mdb <- associateTranscriptionFactors(MotifDb, tbl.motifs.enhancerAll, source="MotifDb", expand.rows=TRUE)
length(unique(tbl.motifs.enhancerAll.mdb$geneSymbol))  # [1] 407

solver.names <- c("lasso", "lassopv", "pearson", "randomForest", "ridge", "spearman")
trena <- Trena("hg38")
targetGene <- "FLT1"

tbl.model.enhancerAll.mdb <- createGeneModel(trena, targetGene, solver.names, tbl.motifs.enhancerAll.mdb, mtx.expression)
save(tbl.model.enhancerAll.mdb, file="tbl.model.enhancerAll.mdb.RData")

tfs <- tbl.model.enhancerAll.mdb$gene
colors <- heat.colors(16)
i <- 0
for(tf in tfs){
   i <- i + 1
   motif <- unique(subset(tbl.motifs.enhancerAll.mdb, geneSymbol==tf)$shortMotif)
   pfms <- as.list(query(mdb.h18, motif))
   mm <- MotifMatcher("hg38", pfms)
   tbl.motifs <- findMatchesByChromosomalRegion(mm, tbl.bigRegion, pwmMatchMinimumAsPercentage=80)
   if(nrow(tbl.motifs) == 0) next;
   tbl.motifs.bed <- tbl.motifs[, c("chrom", "motifStart", "motifEnd")]
   track <- DataFrameAnnotationTrack(tf, tbl.motifs.bed, color=colors[i], displayMode="SQUISHED")
   displayTrack(igv, track)
   }


#tbl.regions.tfc  <- associateTranscriptionFactors(MotifDb, tbl.dhs.candidates, source="tfclass", expand.rows=TRUE)

#--------------------------------------------------------------------------------
# find motifs in these enhancers, 339kb, using tfclass motif/db mapping
#--------------------------------------------------------------------------------
dim(tbl.motifs.enhancerAll) # 28343    13
tbl.motifs.enhancerAll.tfc <- associateTranscriptionFactors(MotifDb, tbl.motifs.enhancerAll, source="TFClass", expand.rows=TRUE)
length(unique(tbl.motifs.enhancerAll.tfc$geneSymbol))  # [1] 661

solver.names <- c("lasso", "lassopv", "pearson", "randomForest", "ridge", "spearman")
trena <- Trena("hg38")
targetGene <- "FLT1"

tbl.model.enhancerAll.tfc <- createGeneModel(trena, targetGene, solver.names, tbl.motifs.enhancerAll.tfc, mtx.expression)
tbl.model.enhancerAll.tfc <- tbl.model.enhancerAll.tfc[order(tbl.model.enhancerAll.tfc$rfScore, decreasing=TRUE),]
tbl.model.enhancerAll.tfc <- tbl.model.enhancerAll.tfc[1:15,]
save(tbl.model.enhancerAll.tfc, file="tbl.model.enhancerAll.tfc.RData")

tfs <- tbl.model.enhancerAll.tfc$gene
colors <- heat.colors(16)
i <- 0
for(tf in tfs){
   i <- i + 1
   motif <- unique(subset(tbl.motifs.enhancerAll.tfc, geneSymbol==tf)$shortMotif)
   pfms <- as.list(query(mdb.h18, motif))
   mm <- MotifMatcher("hg38", pfms)
   tbl.motifs <- findMatchesByChromosomalRegion(mm, tbl.bigRegion, pwmMatchMinimumAsPercentage=80)
   if(nrow(tbl.motifs) == 0) next;
   tbl.motifs.bed <- tbl.motifs[, c("chrom", "motifStart", "motifEnd")]
   track <- DataFrameAnnotationTrack(tf, tbl.motifs.bed, color=colors[i], displayMode="SQUISHED")
   displayTrack(igv, track)
   }




#--------------------------------------------------------------------------------
# find motifs and then TFs in the reduced fp/dhs regions
#--------------------------------------------------------------------------------
tbl.dhsfp.regions <- as.data.frame(gr.dhsfp)[, c(1,2,3)]
colnames(tbl.dhsfp.regions) <- c("chrom", "start", "end")

mm <- MotifMatcher("hg38", pfms)
if(!exists("tbl.motifs.dhsfp90.RData")){
   tbl.motifs.dhsfp <- findMatchesByChromosomalRegion(mm, tbl.dhsfp.regions, pwmMatchMinimumAsPercentage=90)
   #shortMotifNames <- unlist(lapply(tbl.motifs.dhsfp$motifName,
   #                       function(name) {tokens <- strsplit(name, "-")[[1]]; return(tokens[length(tokens)])}))
   #tbl.motifs.dhsfp$shortMotif <- shortMotifNames
   save(tbl.motifs.dhsfp, file="tbl.motifs.dhsfp90.RData")
   }

x <- associateTranscriptionFactors(MotifDb, tbl.motifs.dhsfp, source="MotifDb", expand.rows=TRUE)
colnames(x)[grep("geneSymbol", colnames(x))] <- "mdb.geneSymbol"
deleters <- grep("pubmedID", colnames(x))
if(length(deleters) > 0)
   x <- x[, -deleters]



tbl.mdbFreq <- as.data.frame(sort(table(x$geneSymbol), decreasing=TRUE))

# y <- associateTranscriptionFactors(MotifDb, x, source="TFClass", expand.rows=TRUE)
# colnames(y)[grep("geneSymbol", colnames(y))] <- "tfc.geneSymbol"
# tbl.tfcFreq <- as.data.frame(sort(table(y$tfc.geneSymbol), decreasing=TRUE))
#
# mdb.top.30 <- tbl.mdbFreq$Var1[1:30]
# tfc.top.30 <- tbl.tfcFreq$Var1[1:30]
# length(intersect(mdb.top.30, tfc.top.30))  # 16
#
# tfoi.mdb <- sort(unique(x$mdb.geneSymbol))
# tfoi.tfc <- sort(unique(y$tfc.geneSymbol))
#
# why do both have length 201?  makes no sense!

#----------------------------------------------------------------------------------------------------
# load the expression data
#----------------------------------------------------------------------------------------------------
load("../SRP094910GeneData.RData")
tbl.expression <- GeneData  # 16407   199
dups <- which(duplicated(tbl.expression$hgnc_symbol))  # 2019
if(length(dups) > 0)
   tbl.expression <- tbl.expression[-dups,]

rownames(tbl.expression) <- tbl.expression$hgnc_symbol
tbl.expression <- tbl.expression[, -c(1,2)]
mtx.expression <- as.matrix(tbl.expression)
stopifnot(typeof(mtx.expression[1,1]) == "double")


solver.names <- c("lasso", "lassopv", "pearson", "randomForest", "ridge", "spearman")
trena <- Trena("hg38")
targetGene <- "FLT1"

# coi <- grep("mdb.geneSymbol", colnames(x))
# if(length(coi) ==1)
#   colnames(x)[coi] <- "geneSymbol"

#--------------------------------------------------------------------------------
# create gene mode for MotifDb associations to

tbl.geneModel.mdb <- createGeneModel(trena, targetGene, solver.names, x, mtx.expression)
save(tbl.geneModel.mdb, file="tbl.geneModels.mdb.RData")
print(load("tbl.geneModels.mdb.RData"))


mdb.h18 <- query(query(MotifDb, "sapiens"), "jaspar2018")
tfs <- tbl.geneModel.mdb$gene
# showGenomicRegion(igv, "chr13:28,289,173-28,693,086")
#tbl.bigRegion <- data.frame(chrom="chr13", start=28289173, end=28693086, stringsAsFactors=FALSE)
colors <- heat.colors(16)
i <- 0
for(tf in tfs){
   i <- i + 1
   motif <- unique(subset(x, geneSymbol==tf)$shortMotif)
   pfms <- as.list(query(mdb.h18, motif))
   mm <- MotifMatcher("hg38", pfms)
   tbl.motifs <- findMatchesByChromosomalRegion(mm, tbl.bigRegion, pwmMatchMinimumAsPercentage=90)
   tbl.motifs.bed <- tbl.motifs[, c("chrom", "motifStart", "motifEnd")]
   track <- DataFrameAnnotationTrack(tf, tbl.motifs.bed, color=colors[i], displayMode="SQUISHED")
   displayTrack(igv, track)
   }



#--------------------------------------------------------------------------------
tbl.geneModel.tfc <- createGeneModel(trena, targetGene, solver.names, tbl.regions.tfc, mtx.expression)

tbl.regions.mdb.clean <- subset(tbl.regions.mdb, geneSymbol %in% tbl.geneModel.mdb$gene)  # 978 -> 66

tf.track.mdb <- DataFrameAnnotationTrack("tf.mdb", tbl.regions.mdb.clean[, c(2,3,4,1,7)], color="magenta", displayMode="SQUISHED")
displayTrack(igv, tf.track.mdb)

tbl.regions.tfc.clean <- subset(tbl.regions.tfc, geneSymbol %in% tbl.geneModel.tfc$gene)  # 978 -> 66
tf.track.tfc <- DataFrameAnnotationTrack("tf.tfc", tbl.regions.tfc.clean[, c(2,3,4,1,7)], color="magenta", displayMode="SQUISHED")
displayTrack(igv, tf.track.tfc)


# all dna strategy, region near rs12050029
# chr13:28,652,866-28,653,955
# chr13:28,653,361-28,653,414
tbl.region.rs12050029 <- data.frame(chrom="chr13", start=28653361, end=28653414, stringsAsFactors=FALSE)
mm <- MotifMatcher("hg38", pfms)
tbl.motifs.rs12050029 <- findMatchesByChromosomalRegion(mm, tbl.region.rs12050029, pwmMatchMinimumAsPercentage=80)
tbl.motifs.rs12050029.mdb <- associateTranscriptionFactors(MotifDb, tbl.motifs.rs12050029, source="MotifDb", expand.rows=TRUE)
shortMotifNames <- unlist(lapply(tbl.motifs.rs12050029.mdb$motifName,
                          function(name) {tokens <- strsplit(name, "-")[[1]]; return(tokens[length(tokens)])}))

tbl.motifs.rs12050029$shortMotif <- shortMotifNames

tbl.motifs.rs12050029.tfc <- associateTranscriptionFactors(MotifDb, tbl.motifs.rs12050029, source="tfclass", expand.rows=TRUE)


# all dna strategy, region near rs4769613
# chr13:28,564,432-28,564,524  93bp
# chr13:28,564,460-28,564,484  25bp
loc <- getGenomicRegion(igv)
tbl.region.rs4769613 <- with(loc, data.frame(chrom=chrom, start=start, end=end, stringsAsFactors=FALSE))
mm <- MotifMatcher("hg38", pfms)
tbl.motifs.rs4769613 <- findMatchesByChromosomalRegion(mm, tbl.region.rs4769613, pwmMatchMinimumAsPercentage=80)
tbl.motifs.rs4769613 <- associateTranscriptionFactors(MotifDb, tbl.motifs.rs4769613, source="MotifDb", expand.rows=TRUE)
sort(unique(tbl.motifs.rs4769613$geneSymbol))
