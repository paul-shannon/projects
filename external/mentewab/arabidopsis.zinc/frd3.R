# FRD3
# A. thaliana
# Chr3:2566277-2572151
# Gene ID: AT3G08040
#------------------------------------------------------------------------------------------------------------------------
library(trena)
library(trenaViz)
#------------------------------------------------------------------------------------------------------------------------
PORTS <- 10000:10020
frd3.roi <- "3:2566277-2572151"
frd3.extended.roi <- "3:2,563,340-2,575,089"
#------------------------------------------------------------------------------------------------------------------------
if(!exists("tv")){
  tv <- trenaViz(PORTS, title="FRD3", quiet=TRUE)
  setGenome(tv, "tair10")
  Sys.sleep(5)
  showGenomicRegion(tv, frd3.roi)
  }
#------------------------------------------------------------------------------------------------------------------------
if(!exists("pfms"))
   pfms <- as.list(query(query(MotifDb, "jaspar2018"), "athaliana"))  # 452
if(!exists("mm")){
   mm <- MotifMatcher("tair10", pfms)
   }

#------------------------------------------------------------------------------------------------------------------------
findMotifs <- function(mm, chrom="Chr3", start=2563340, end=2575089, minMatch=90)
{
  tbl.regions <- data.frame(chrom=chrom, start=start, end=end, stringsAsFactors=FALSE)
  tbl.motifs <- findMatchesByChromosomalRegion(mm, tbl.regions, pwmMatchMinimumAsPercentage=minMatch)

  tbl.motifs.tf <- associateTranscriptionFactors(MotifDb, tbl.motifs, source="MotifDb", expand.rows=TRUE)
  tbl.motifs.tf

} # findMotifs
#------------------------------------------------------------------------------------------------------------------------

