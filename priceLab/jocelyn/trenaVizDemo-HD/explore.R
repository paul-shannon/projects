library(trena)
library(trenaViz)
library(colorspace)
library(annotate)
library(org.Hs.eg.db)
library(MotifDb)
#----------------------------------------------------------------------------------------------------
printf <- function(...) print(noquote(sprintf(...)))
#----------------------------------------------------------------------------------------------------
stopifnot(packageVersion("trena")    >= "0.99.157")
stopifnot(packageVersion("trenaViz") >= "0.99.13")
stopifnot(packageVersion("httpuv")   >= "1.3.5")
#----------------------------------------------------------------------------------------------------
if(!exists("trena"))
   trena <- Trena("hg38")

PORT.RANGE <- 8000:8020

if(!exists("tv")) {
   tv <- trenaViz(PORT.RANGE, quiet=FALSE)
   setGenome(tv, "hg38")
   }
#----------------------------------------------------------------------------------------------------
create.htt.model <- function()
{
   target.gene <- "HTT"
   gene.tss <- 3074510
   showGenomicRegion(tv, target.gene)
   chrom.loc <- parseChromLocString(getGenomicRegion(tv))
   shoulder <- 10000
   loc.chrom <- chrom.loc$chrom
   loc.start <- chrom.loc$start - shoulder
   loc.end   <- chrom.loc$end   + shoulder

   expanded.region <- with(chrom.loc, sprintf("%s:%d-%d", chrom, start-shoulder, end+shoulder))
   showGenomicRegion(tv, expanded.region)

   db.hint.20 <- sprintf("postgres://%s", "whovian/brain_hint_20")
   sources <- c(hint20=db.hint.20)
   tbls.regions <- getRegulatoryChromosomalRegions(trena, loc.chrom, loc.start, loc.end, as.character(sources),
                                                   target.gene, gene.tss)

   for(sourceName in names(sources)){
      tbl.regions <- tbls.regions[[sourceName]]
      addBedTrackFromDataFrame(tv, source.name,
                               tbl.regions[, c(1,2,3,4,6)], color=colors[i])

} # create.hdd.model
#----------------------------------------------------------------------------------------------------
