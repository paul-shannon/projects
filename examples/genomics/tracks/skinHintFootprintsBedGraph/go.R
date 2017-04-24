library(TReNA)  # for FootprintFinder
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(RUnit)
#------------------------------------------------------------------------------------------------------------------------
genome.db.uri    <- "postgres://whovian/hg38"                  # has gtf and motifsgenes tables
footprint.db.uri <- "postgres://whovian/skin_hint"             # has hits and regions tables

if(!exists("fpf"))
   fpf <- FootprintFinder(genome.db.uri, footprint.db.uri, quiet=FALSE)

#------------------------------------------------------------------------------------------------------------------------
# reduce the footprint table to a bed format, with just one row per unique loc
# and a score which counts the number of samples at that exact loc.
# the incoming tbl.fp will also have a unique row for every motif assigned
# to the loc, and is sometimes further inflated by palindromic motifs
# mapped to both strands.  ignore all of that.
condense.footprints <- function(tbl.fp)
{
   tbl.fp.uniq <- unique(tbl.fp[, c("loc", "sample_id")])  # the only two relevant fields
   tbl.reps <- as.data.frame(table(tbl.fp.uniq$loc), stringsAsFactors=FALSE)  # find their distrution
   tbl.repsOfInterest <- subset(tbl.reps, Freq > 0)  # get rid of all singleton locs
   indices <- match(tbl.repsOfInterest$Var1, tbl.fp$loc)   # find out their first occurence
   tbl.chromStartEnd <- tbl.fp[indices, c("chrom", "start", "endpos")]   # extract chrom, start, end
   tbl.out <- cbind(tbl.repsOfInterest, tbl.chromStartEnd)     # broaden loc, sampleCount with chrom,start,end
   colnames(tbl.out) <- c("loc", "score", "chrom", "start", "end")   # fix the colnames

   tbl.out[, c("chrom", "start", "end", "score")]

} # condense.footprints
#------------------------------------------------------------------------------------------------------------------------
test.condense.footprints <- function()
{
   printf("--- test.condense.footprints")
   if(!exists("tbl.fp22"))
      load("tbl.fp.chr22.RData", envir=.GlobalEnv())
   tbl.test <- tbl.fp22; # [1:100,]  # has a 2-dup, a 4-dup and 5 singles
   tbl.condensed <- condense.footprints(tbl.test)

   checkTrue(nrow(tbl.condensed) < 80000)
   checkEquals(ncol(tbl.condensed), 4)
   checkEquals(colnames(tbl.condensed), c("chrom", "start", "end", "score"))

} # test.condense.footprints
#------------------------------------------------------------------------------------------------------------------------
saveBed <- function(tbl.fp, filename)
{
   dim(tbl.fp)   # 4105 17
   tbl.bed <- tbl.fp[, c("chrom", "start", "endpos", "name", "score3")]
   write.table(tbl.bed, sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE, file="test.bed")


} # saveBed
#------------------------------------------------------------------------------------------------------------------------
iterate <- function()
{
   chrom.lengths <- as.list(seqlengths(seqinfo(TxDb.Hsapiens.UCSC.hg38.knownGene))[paste("chr", c(1:22, "X", "Y"), sep="")])
   chroms <- names(chrom.lengths)

   for(chrom in chroms){
      end.loc <- chrom.lengths[[chrom]]
      printf("%s: %d", chrom, end.loc)
      tbl.fp <- getFootprintsInRegion(fpf, chrom, 1, end.loc)
      tbl.fpReduced <- condense.footprints(tbl.fp)
      filename <- sprintf("%s.bed", chrom)
      write.table(tbl.fpReduced, sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE, file=filename)
      }

} # iterate
#------------------------------------------------------------------------------------------------------------------------

