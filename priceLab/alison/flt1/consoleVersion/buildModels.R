library(igvR)
library(trena)
library(RUnit)
#------------------------------------------------------------------------------------------------------------------------
# reduce the meaningless precsion in all of the numerical columns of trena models
round.numeric.columns.in.dataframe <- function(tbl, digits, pvalColumnNames=NA)
{
  tbl.pvals <- data.frame()
  tbl.main <- tbl

  if(!(all(is.na(pvalColumnNames)))){
     stopifnot(all(pvalColumnNames %in% colnames(tbl)))
     pval.cols <- grep(pvalColumnNames, colnames(tbl))
     stopifnot(length(pval.cols) == length(pvalColumnNames))
     tbl.pvals <- tbl[, pval.cols, drop=FALSE]
     tbl.main <- tbl[, -pval.cols, drop=FALSE]
     }

  numeric_columns <- sapply(tbl.main, mode) == 'numeric'
  tbl.main[numeric_columns] <-  round(tbl.main[numeric_columns], digits)

  if(ncol(tbl.pvals) > 0){
     tbl.pvals <- apply(tbl.pvals, 2, function(col) as.numeric(formatC(col, format = "e", digits = 2)))
     }

  tbl.out <- cbind(tbl.main, tbl.pvals)[, colnames(tbl)]
  tbl.out

} # round.numeric.columns.in.dataframe
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_round.numeric.columns.in.dataframe()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
test_round.numeric.columns.in.dataframe <- function()
{
   load("tbl.model.test.RData")
   tbl.fixed <- round.numeric.columns.in.dataframe(tbl.model.test, 3, "lassoPValue")
   checkEquals(dim(tbl.fixed), dim(tbl.model.test))
   checkEquals(as.list(tbl.fixed[1,]),
               list(gene="MXI1",
                    betaLasso=0.395,
                    lassoPValue=1.64e-27,
                    pearsonCoeff=0.675,
                    rfScore=10.298,
                    betaRidge=0.106,
                    spearmanCoeff=0.593,
                    concordance=0.518,
                    pcaMax=2.766,
                    bindingSites=17))


} # test_round.numeric.columns.in.dataframe
#------------------------------------------------------------------------------------------------------------------------
if(!exists("igv")){
   igv <- igvR()
   setGenome(igv, "hg38")
   showGenomicRegion(igv, "FLT1")
   }

if(!exists("mtx.expression")){
   load("../SRP094910GeneData.RData")
   tbl.expression <- GeneData  # 16407   199
   dups <- which(duplicated(tbl.expression$hgnc_symbol))  # 2019
   if(length(dups) > 0)
      tbl.expression <- tbl.expression[-dups,]
   rownames(tbl.expression) <- tbl.expression$hgnc_symbol
   tbl.expression <- tbl.expression[, -c(1,2)]
   mtx.expression <- as.matrix(tbl.expression)
   stopifnot(typeof(mtx.expression[1,1]) == "double")
   }   # 14388   197

#------------------------------------------------------------------------------------------------------------------------
# takes about 3 minutes, slightly more
buildEnhancersModel <- function(display=FALSE)
{
   chrom <- "chr13"
   start <- 28289173
   end <- 28693086
   tbl.bigRegion <- data.frame(chrom=chrom, start=start, end=end, stringsAsFactors=FALSE)
   bigRegion <- with(tbl.bigRegion, sprintf("%s:%d-%d", chrom, start, end))
   showGenomicRegion(igv, bigRegion)

   load("../FTL1-enhancer.RData")
   tbl.enhancer <- ftl1.enhancer
   gr.enhancer <- with(tbl.enhancer, GRanges(seqnames=chrom, IRanges(start=start, end=end)))
   track.enhancer <- GRangesAnnotationTrack("enhancers", gr.enhancer, color="purple")
   displayTrack(igv, track.enhancer)

   pfms <- as.list(query(query(MotifDb, "sapiens"),"jaspar2018"))
   mm <- MotifMatcher("hg38", pfms)
   tbl.motifs.enhancerAll <- findMatchesByChromosomalRegion(mm, tbl.enhancer[, c("chrom", "start", "end")],
                                                            pwmMatchMinimumAsPercentage=85)
   dim(tbl.motifs.enhancerAll) # 28343    13

   tbl.motifs.enhancerAll.mdb <- associateTranscriptionFactors(MotifDb, tbl.motifs.enhancerAll, source="MotifDb", expand.rows=TRUE)
   tbl.motifs.enhancerAll.tfc <- associateTranscriptionFactors(MotifDb, tbl.motifs.enhancerAll, source="TFClass", expand.rows=TRUE)

   length(unique(tbl.motifs.enhancerAll.mdb$geneSymbol))  # [1] 407
   length(unique(tbl.motifs.enhancerAll.tfc$geneSymbol))  # [1] 661

   solver.names <- c("lasso", "lassopv", "pearson", "randomForest", "ridge", "spearman")
   trena <- Trena("hg38")
   targetGene <- "FLT1"

   tbl.model.enhancerAll.mdb <- createGeneModel(trena, targetGene, solver.names, tbl.motifs.enhancerAll.mdb, mtx.expression)
   tbl.model.enhancerAll.tfc <- createGeneModel(trena, targetGene, solver.names, tbl.motifs.enhancerAll.tfc, mtx.expression)

   tbl.model.enhancerAll.mdb <- round.numeric.columns.in.dataframe(tbl.model.enhancerAll.mdb, 3, "lassoPValue")
   tbl.model.enhancerAll.mdb$lassoPValue <- sprintf("%5.2e", tbl.model.enhancerAll.mdb$lassoPValue)
   tbl.model.enhancerAll.tfc <- round.numeric.columns.in.dataframe(tbl.model.enhancerAll.tfc, 3, "lassoPValue")
   tbl.model.enhancerAll.tfc$lassoPValue <- sprintf("%5.2e", tbl.model.enhancerAll.tfc$lassoPValue)

   save(tbl.model.enhancerAll.mdb,
        tbl.model.enhancerAll.tfc,
        tbl.motifs.enhancerAll.mdb,
        tbl.motifs.enhancerAll.tfc,
        tbl.enhancer,
        file="../enhancerModels.RData")

} # buildEnhancersModel
#------------------------------------------------------------------------------------------------------------------------
