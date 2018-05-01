motifTrackForTF <- function(tbl.motifs, tf)
{
      tbl.bed <- subset(tbl.motifs, geneSymbol==tf)[, c("chrom", "start", "end", "motifName", "motifRelativeScore")]
      if(nrow(tbl.bed) == 0){
         printf("FRD3.data::motifTrackForTF error: no motifs for tf '%s'", tf)
         return(tbl.bed)
         }
      getLastToken <- function(longMotifName){
         tokens <- strsplit(longMotifName, "-")[[1]];
         return(tokens[length(tokens)])
         }
      names <-unlist(lapply(tbl.bed$motifName, getLastToken))
      tbl.bed$motifName <- names
      colnames(tbl.bed) <- c("chrom", "start", "end", "name", "score")
      rownames(tbl.bed) <- NULL
      invisible(tbl.bed)
      })

} # motifTrackForTf
