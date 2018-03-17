library(GenomicRanges)
library(RUnit)
library(MEF2C.data)
#------------------------------------------------------------------------------------------------------------------------
if(!exists("mef2c"))
   mef2c <- MEF2C.data()
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_shoulder.0()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
useFilters <- function(session, filters, trena.model, snpShoulder)
{
   stopifnot(trena.model %in% c("model_cer", "model_tcx", "model_ros"))
   stopifnot(snpShoulder >= 0 & snpShoulder < 250)
   stopifnot(all(filters %in% c("footprints", "dhs", "enhancers")))

   #browser()
   tbl.activeSnps <-  mef2c@misc.data[["IGAP.snpChip"]] # 228
   tbl.activeSnps$start <- tbl.activeSnps$start - snpShoulder
   tbl.activeSnps$end <- tbl.activeSnps$start + snpShoulder

   tbl.enhancers <- mef2c@misc.data$enhancer.locs
   study.roi <- list(chrom="chr5", start=min(tbl.enhancers$start) - 10000, end=max(tbl.enhancers$end) + 10000)
   load("tbl.fp.geneSymbolsAndShortMotifAdded.RData")

   # tbl.fp <- getFootprints(mef2c, study.roi)
   # getLastToken <- function(string){
   #    tokens <- strsplit(string, "-")[[1]]; return(tokens[length(tokens)])
   #    }

   # tbl.fp$shortMotif <- unlist(lapply(tbl.fp$motifName, getLastToken))
   # colnames(tbl.fp)[grep("geneSymbol", colnames(tbl.fp))] <- "geneSymbol.orig"

   #  tbl.fp <- associateTranscriptionFactors(MotifDb, tbl.fp, source="MotifDb", expand.rows=TRUE)
   # colnames(tbl.fp)[grep("^geneSymbol$", colnames(tbl.fp))] <- "geneSymbol.motifdb"
   # tbl.fp <- associateTranscriptionFactors(MotifDb, tbl.fp, source="TFClass", expand.rows=TRUE)
   # colnames(tbl.fp)[grep("^geneSymbol$", colnames(tbl.fp))] <- "geneSymbol.tfclass"
   # save(tbl.fp, file="tbl.fp.geneSymbolsAndShortMotifAdded.RData")
   # browser()

   if("footprints" %in% filters){
      tbl.activeSnps <- intersect(tbl.activeSnps, tbl.fp)
      tbl.activeFp <- intersect(tbl.fp, tbl.activeSnps)
      }

   tbl.model <- switch(trena.model,
      "model_cer" = getModels(mef2c)[["mef2c.cory.wgs.cer.tfClass"]],
      "model_tcx" = getModels(mef2c)[["mef2c.cory.wgs.tcx.tfClass"]],
      "model_ros" = getModels(mef2c)[["mef2c.cory.wgs.ros.tfClass"]])

   tfoi <- tbl.model$gene[1:10]
   tbl.activeFpInModel <- subset(tbl.activeFp, geneSymbol.tfclass %in% tfoi | geneSymbol.motifdb %in% tfoi)
   rownames(tbl.activeFpInModel) <- NULL

   if(nrow(tbl.activeFpInModel) > 0){
      tbl.activeSnpsInModel <- intersect(tbl.activeSnps, tbl.activeFpInModel)
      }

   tbl.activeFpInModel$name <- with(tbl.activeFpInModel,
                          sprintf("%s.%s.%s", shortMotif, geneSymbol.tfclass, geneSymbol.motifdb))

   tbl.cleanedUp <- tbl.activeFpInModel[, c("chrom", "start", "end", "name", "score", "strand")]

   if(!is.null(session)){
      temp.filename <- sprintf("igvdata/tmp%d.bed", as.integer(Sys.time()))
      write.table(tbl.cleanedUp, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
      trackName <- sprintf("snp+%d/fp/model", snpShoulder)
      session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName=trackName,
                                              color="blue",
                                              trackHeight=40)))
      } # is session

   invisible(list(fp=tbl.activeFpInModel, snp=tbl.activeSnpsInModel, fpClean=tbl.cleanedUp))

} # useFilters
#------------------------------------------------------------------------------------------------------------------------
test_shoulder.0 <- function()
{
   printf("--- test_shoulder.0")
   x <- useFilters(session=NULL, filters="footprints", trena.model="model_cer", snpShoulder=0)
   checkEquals(names(x), c("fp", "snp", "fpClean"))
   browser()
   xyz <- 99

} # test_shoulder.0
#------------------------------------------------------------------------------------------------------------------------
