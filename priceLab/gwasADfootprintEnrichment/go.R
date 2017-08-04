library(trenaUtilities)
print(load("tbl.gwas.level_1.RData"))
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
chrom.lengths <- as.list(seqlengths(seqinfo(TxDb.Hsapiens.UCSC.hg38.knownGene))[paste("chr", c(1:22, "X", "Y"), sep="")])
library(RPostgreSQL)
chromLoc <- list(chrom="chr1", start=1, end=100000L)
#encode.table.name <- "wgEncodeRegDnaseClustered"
target.gene <- "MPZL1"
target.gene.tss <- 500
sources <- list(hint20="postgres://whovian/brain_hint_20",
                hint16="postgres://whovian/brain_hint_16")

snp.count.in.footprints <- 0
total.snps <- 0



snps.in.footprints <- list()

for(chrom in names(chrom.lengths)[1]){
   chunk.size <- 100000
   chunks <- as.integer(ceiling(chrom.lengths[[chrom]]/chunk.size))
   for(i in seq_len(chunks)){
      start <- 1 + ((i-1)* chunk.size)
      end <- start + chunk.size
      pval.threshold <- 0.01
      chromLocString <- sprintf("%s:%d-%d", chrom, start, end)
      tbl.gwasSub <- subset(tbl.gwas, CHR==chrom & BP >= start & BP <= end) #  & P <= pval.threshold)
      if(nrow(tbl.gwasSub) == 0){
         printf("no gwas snps in %s:%d-%d, skipping ahead", chrom, start, end)
         next;
         }
      prep <- TrenaPrep(target.gene, target.gene.tss, chrom, start, end,
                        regulatoryRegionSources=as.list(unlist(sources, use.names=FALSE)), quiet=FALSE)
      x <- getRegulatoryRegions(prep, combine=FALSE, quiet=FALSE)  # the default
      x2 <- lapply(seq_len(length(x)), function(i){ x[[i]]$source <- names(sources)[i]; return(x[[i]])})
      tbl.regions <- do.call(rbind,x2)
      tbl.regions$signature <- with(tbl.regions, sprintf("%s:%d-%d", chrom, motifStart, motifEnd))
      dups <- which(duplicated(tbl.regions$signature))
      if(length(dups) > 0)
         tbl.regions <- tbl.regions[-dups,]
      shoulder <- 8
      gr.fp <- with(tbl.regions, GRanges(seqnames=chrom, IRanges(start=motifStart-8, end=motifEnd+8)))
      gr.gwas <- with(tbl.gwasSub, GRanges(seqnames=CHR, IRanges(start=BP, end=BP)))
      tbl.overlaps <- as.data.frame(findOverlaps(gr.fp, gr.gwas, type="any"))
      hits <- unique(tbl.overlaps$subjectHits)
      if(length(hits) > 0){
         snps.in.footprints[[chromLocString]] <- tbl.gwasSub[hits,]
         save(snps.in.footprints, file="snps.in.footprints.RData")
         }
      hit.count <- length(unique(tbl.overlaps$subjectHits))
      snp.count.in.footprints <- snp.count.in.footprints + hit.count
      total.snps <- total.snps + nrow(tbl.gwasSub)
      running.score <- snp.count.in.footprints/total.snps
      printf("%s] %d regions, %d gwas snps, %d overlaps: %5.2f",
             chromLocString, nrow(tbl.regions), nrow(tbl.gwasSub), hit.count, running.score * 100)
      xyz <- 99
      db.connections <- dbListConnections(RPostgreSQL::PostgreSQL())
      printf("db.connections count: %d", length(db.connections))
      lapply(db.connections, dbDisconnect)
      } # for i
   } # for chrom

