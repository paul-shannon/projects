library(RUnit)
library(Biostrings)
library(MotifDb)
#------------------------------------------------------------------------------------------------------------------------
#uri <- "http://jaspar.genereg.net/html/DOWNLOAD/JASPAR_CORE/pfm/nonredundant/pfm_all.txt";
uri <- "http://jaspar.genereg.net/html/DOWNLOAD/JASPAR_CORE/pfm/nonredundant/pfm_vertebrates.txt"
#------------------------------------------------------------------------------------------------------------------------
# for comparison with fimo
# from "Highly recurrent TERT promoter mutations in human melanoma"  http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4423787/
tert.sequences <-  list(tert_wt1="CCCGGAGGGGG", tert_wt2="CCCGGGAGGGG", tert_mut= "CCCCTTCCGGG")
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test.parseLine()
   test.parsePwm()
   test.matchMotif()
   test.findHits()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
parseLine <- function(textOfLine)
{
     # first delete the leading A, C, G or T.  then the square brackets.  then convert
  x <- substr(textOfLine, 2, nchar(textOfLine))
  x2 <- sub(" *\\[ *", "", x)
  x3 <- sub(" *\\] *", "", x2)
  counts <- as.integer(strsplit(x3, "\\s+", perl=TRUE)[[1]])

  return(counts)

} # parseLine
#------------------------------------------------------------------------------------------------------------------------
test.parseLine <- function()
{
    printf("--- test.parseLine")
    counts <- parseLine("A  [ 287  234  123   57    0   87    0   17   10  131  500 ]");
    checkEquals(counts, c(287, 234, 123, 57, 0, 87, 0, 17, 10, 131, 500))
    counts <- parseLine("T  [10 41 58 39  3 16 10 48 38 60 25 63  3  3 33 31 14 24 ]");
    checkEquals(counts, c(10, 41, 58, 39, 3, 16, 10, 48, 38, 60, 25, 63, 3, 3, 33, 31, 14, 24))

} # test.parseLine
#------------------------------------------------------------------------------------------------------------------------
parsePwm = function (lines)
{
   #browser()
   stopifnot(length(lines)==5) # title line, one line for each base
   motif.name.raw = strsplit(lines[1], "\t")[[1]][1]
   motif.name <- gsub(">", "", motif.name.raw, fixed=TRUE)

     # expect 4 rows, and a number of columns we can discern from
     # the incoming text.
  a.counts <- parseLine(lines[[2]])
  c.counts <- parseLine(lines[[3]])
  g.counts <- parseLine(lines[[4]])
  t.counts <- parseLine(lines[[5]])
  stopifnot(length(a.counts) == length(c.counts))
  stopifnot(length(a.counts) == length(g.counts))
  stopifnot(length(a.counts) == length(t.counts))

  cols <- length(a.counts)
  mtx <- matrix (nrow=4, ncol=cols, dimnames=list(c('A','C','G','T'), as.character(1:cols)))
  mtx[1,] <- a.counts
  mtx[2,] <- c.counts
  mtx[3,] <- g.counts
  mtx[4,] <- t.counts

  return(list(title=motif.name, matrix=mtx))

} # parsePwm
#----------------------------------------------------------------------------------------------------
test.parsePwm <- function()
{

   printf("--- test.parsePwm")
   all.lines <- scan (uri, what=character(0), sep='\n', quiet=TRUE)

   x <- parsePwm(all.lines[1:5])
   checkEquals(x$title, "MA0002.2")
   pcm <- x$matrix
   checkTrue(all(apply(pcm, 2, sum) == 2000))
   pwm <- apply(pcm, 2, function(col) col/sum(col))
   checkTrue(all(apply(pwm, 2, sum) == 1))

} # test.parsePwm
#----------------------------------------------------------------------------------------------------
readRawMatrices = function (uri, test=FALSE)
{
  all.lines <- scan(uri, what=character(0), sep='\n', quiet=TRUE)
  title.lines <- grep ('^>', all.lines)
  title.line.count <- length (title.lines)
  max <- title.line.count - 1

  if(test)
     max <- 5

  pwms <- list()

  for(i in 1:max){
    start.line <- title.lines [i]
    end.line <- title.lines [i+1] - 1
    x <- parsePwm (all.lines [start.line:end.line])
    pwms[[i]] <- list(title=x$title, matrix=x$matrix)
    } # for i

  invisible (pwms)

} # readRawMatrices
#------------------------------------------------------------------------------------------------------------------------
test.matchMotif <- function()
{
   printf("--- test.matchMotif")

     # the first vertebrate motif
   text <- c(">MA0002.2\tRUNX1",
             "A  [ 287  234  123   57    0   87    0   17   10  131  500 ]",
             "C  [ 496  485 1072    0   75  127    0   42  400  463  158 ]",
             "G  [ 696  467  149    7 1872   70 1987 1848  251   81  289 ]",
             "T  [ 521  814  656 1936   53 1716   13   93 1339 1325 1053 ]")

   pcm <- parsePwm(text)
   pwm <- apply(pcm$matrix, 2, function(col) col <- col/sum(col))

   sequence <- "GTCTGTGGTTT"   # hand calculateed from the abundances above
   x <- matchPWM(pwm, sequence, with.score=TRUE, min.score="60%")
   tbl <- data.frame(ranges(x), score=mcols(x)$score)
   checkEquals(tbl$start, 1)
   checkEquals(tbl$end, 11)
   checkEquals(tbl$width, 11)
   checkEqualsNumeric(tbl$score, 7.829, tol=1e3)

} # test.matchMotif
#------------------------------------------------------------------------------------------------------------------------
run <- function()
{
   x <- readRawMatrices(uri, test=FALSE)
   pfms <- lapply(x, function(e) apply(e$matrix, 2, function(col) col/sum(col)))
   names(pfms) <- as.character(lapply(x, function(e) e$title))

   invisible(pfms)

} # run
#------------------------------------------------------------------------------------------------------------------------
findHits <- function(sequence, pfms, min.match=0.80)
{
   min.match.as.string <- sprintf("%02d%%", 100 * min.match)

   search <- function(motifName, mtx, seq){
      hits.fwd <- matchPWM(mtx, seq, with.score=TRUE, min.score=min.match.as.string);
      seq.revcomp <- as.character(reverseComplement(DNAString(seq)))
      hits.rev <- matchPWM(mtx, seq.revcomp, with.score=TRUE, min.score=min.match.as.string);
      tbl <- data.frame()
      if(length(hits.fwd) > 0){
          #printf("%d +", length(hits.fwd))
          match <- substring(as.character(subject(hits.fwd)), start(ranges(hits.fwd)), end(ranges(hits.fwd)))
          tbl <- data.frame(ranges(hits.fwd), score=mcols(hits.fwd)$score, motif=motifName, seq=seq, match=match, strand="+")
          }
      if(length(hits.rev) > 0){
          #printf("%d -", length(hits.rev))
          match <- substring(as.character(subject(hits.rev)), start(ranges(hits.rev)), end(ranges(hits.rev)))
          tbl.rev <- data.frame(ranges(hits.rev), score=mcols(hits.rev)$score, motif=motifName, seq=seq, match=match, strand="-")
          tbl <- rbind(tbl, tbl.rev)
          }
       return(tbl)
       }

    count <- length(pfms)
    xx <- lapply(1:count, function(i) search(names(pfms)[i], pfms[[i]], sequence))
   tbl.result <- do.call("rbind", xx)
   if(nrow(tbl.result) == 0){
     return(data.frame())
     }
   else{
      tbl.result$motif <- as.character(tbl.result$motif)
      tbl.result$seq <- as.character(tbl.result$seq)
      tbl.result$match <- as.character(tbl.result$match)
      tbl.result$strand <- as.character(tbl.result$strand)
      return(tbl.result[order(tbl.result$score,decreasing=TRUE),])
      }

}  # findHits
#------------------------------------------------------------------------------------------------------------------------
test.findHits <- function()
{
   printf("--- test.findHits")

   pfms <- run()

     # the consensus sequence (without ambiguity codes) from the first vertebrate matrix, MA0002.2
   sequence <- "GTCTGTGGTTT"
   tbl.1 <- findHits(sequence, pfms)
   checkTrue(! "factor" %in% as.character(lapply(tbl.1, class)))

   checkEquals(tbl.1$motif[1], "MA0002.2")

     # choose slighly less favored bases for the first two position
   sequence <- "TCCTGTGGTTT"
   tbl.2 <- findHits(sequence, pfms)
   checkEquals(tbl.2$motif[1], "MA0002.2")

     # expect a better score with the first sequence
   checkTrue(tbl.1$score[1] > tbl.2$score[1])

   tbl.wt1 <- findHits(tert.sequences$tert_wt1, pfms, min.match=0.8)
   checkEquals(dim(tbl.wt1), c(1, 8))
   tbl.wt2 <- findHits(tert.sequences$tert_wt2, pfms, min.match=0.8)
   checkEquals(nrow(tbl.wt2), 0)
   tbl.wt2b <- findHits(tert.sequences$tert_wt2, pfms, min.match=0.7)
   checkTrue(nrow(tbl.wt2b) > 15)

   tbl.mut <- findHits(tert.sequences$tert_mut, pfms, min.match=0.8)
   checkTrue(nrow(tbl.mut) > 12)
   checkEquals(subset(tbl.mut, score > 7)$motif, c("MA0076.2", "MA0028.2"))

} # test.findHits
#------------------------------------------------------------------------------------------------------------------------
fimo.comparison <- function()
{
   library(FimoClient)
   FIMO_HOST <- "whovian"
   FIMO_PORT <- 5558
   if(!exists("fc"))
      fc <<- FimoClient(FIMO_HOST, FIMO_PORT, quiet=TRUE)

   tbl.fimo <<- requestMatch(fc, tert.sequences)

} # fimo.comparison
#------------------------------------------------------------------------------------------------------------------------
