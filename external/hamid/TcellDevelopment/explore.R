library(trena)
library(trenaViz)
library(colorspace)
# library(MotifDb)
#--------------------------------------------------------------------------------
printf <- function(...) print(noquote(sprintf(...)))
PORT.RANGE <- 8000:8020
#--------------------------------------------------------------------------------
stopifnot(packageVersion("trena")    >= "0.99.141")
stopifnot(packageVersion("trenaViz") >= "0.99.7")

tv <- trenaViz(PORT.RANGE, quiet=FALSE)
setGenome(tv, "mm10")

tbl <- read.table("cytoscapeEdgeAnnot_11July2017.txt", sep="\t", header=TRUE, as.is=TRUE)
tbl.xtab <- as.data.frame(table(c(tbl$Source, tbl$Target)))
tbl.xtab <- tbl.xtab[order(tbl.xtab$Freq, decreasing=TRUE),]
head(tbl.xtab)
# DNMT3A is the most connected gene, a methyl transferase.
# extended location: chr12:3,751,728-3,970,655  (218kb)

gene <- "Dnmt3a"
chrom <- "chr12"
loc.start <- 3751728
loc.end   <- 3970655


# ifng: Chr10:118441047-118445892 bp, + strand
gene <- "Ifng"
chrom <- "chr10"
loc.start <- 118441047
loc.end   <- 118445892

#----------------------------------------------------------------------------------------------------
#    The are 3 replicates for each of expression and ATAC-seq peaks for 'naive' T cells:
#
#     GSM2365761 	RNA_N1
#     GSM2365762 	RNA_N2
#     GSM2365763 	RNA_N3
#
#     GSM2365799 	ATAC_N1
#     GSM2365800 	ATAC_N2
#     GSM2365801 	ATAC_N3
#
#   These define the starting state of the T cells (point of
#   reference). At this point the cells are mature but "inexperienced".
#
#   Then there are expression and peak data sets with identifier like
#   RNA_L5_1, etc. The L stands for Liver tumor and the number after
#   the L is how many days after the naive cells (starting state) were
#   stimulated with antigen. What I am doing is building a gene
#   regulatory network of interactions that start in state naive and go
#   through states L5, L7, ... till L28. The data includes later days
#   (35 and 60), in these late stages a second differentiation process
#   starts (memory cell formation) and for now we can skip that stage.
#
#   So you have 4 developmental stages (L5, 7, 14, 21) with RNA and
#   ATAC-seq. The genes that I think are the most likely players are
#   listed in the attached Cytoscape annot file.
#
#----------------------------------------------------------------------------------------------------


files <- list(N1_1="GSM2365799_ATAC_N1_normalizedCounts.txt",         # naive
              N2_1="GSM2365800_ATAC_N2_normalizedCounts.txt",
              N3_1="GSM2365801_ATAC_N3_normalizedCounts.txt",
              L5_1="GSM2365810_ATAC_L5_1_normalizedCounts.txt",       # liver tumor, 5 days after stimulation
              L5_2="GSM2365811_ATAC_L5_2_normalizedCounts.txt",
              L5_3="GSM2365812_ATAC_L5_3_normalizedCounts.txt",
              L5_4="GSM2365813_ATAC_L5_4_normalizedCounts.txt",
              L7_1="GSM2365814_ATAC_L7_1_normalizedCounts.txt",       # 7 days after
              L7_2="GSM2365815_ATAC_L7_2_normalizedCounts.txt",
              L7_3="GSM2365816_ATAC_L7_3_normalizedCounts.txt",
              L14_1="GSM2365817_ATAC_L14_1_normalizedCounts.txt",     # 14 days
              L14_2="GSM2365818_ATAC_L14_2_normalizedCounts.txt",
              L14_3="GSM2365819_ATAC_L14_3_normalizedCounts.txt",
              L21_1="GSM2365820_ATAC_L21_1_normalizedCounts.txt",     # 21 days
              L21_2="GSM2365821_ATAC_L21_2_normalizedCounts.txt",
              L21_3="GSM2365822_ATAC_L21_3_normalizedCounts.txt")


chrom.locs.list <- list()
i <- 0



# tcf7
gene <- "Tcf7"
chrom <- "chr11"
loc.start <- 52275902
loc.end   <- 52293058
#upstream.shoulder <- 5000
#downstream.shoulder <- 2000

showGenomicRegion(tv, sprintf("%s:%d-%d", chrom, loc.start, loc.end))

#----------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------
file.count <- length(files)
colors <- rainbow_hcl(file.count)
i <- 0

tbls.regions <- list()

for(id in names(files)[1:file.count]){
   i <- i + 1
   filename <- files[[id]]
   tbl.tmp <- read.table(filename, header=TRUE, sep="\t", as.is=TRUE)
     # Tcf7 is on the minus strand
   track.start <- loc.start
   track.end   <- loc.end
   tbl.gene <- subset(tbl.tmp, chr==chrom & start >= track.start & end <= track.end)
   tbl.gene$sample = id
   colnames(tbl.gene)[7] <- "score"
   printf("colors[%d]: %s", i, colors[i])
   tbls.regions[[id]] <- tbl.gene
   addBedGraphTrackFromDataFrame(tv, id, tbl.gene[, c(1,2,3,7,5)], color=colors[i], minValue=0, maxValue=750)
   }

tbl.regions <- do.call(rbind, tbls.regions)[, c(1,2,3,7,8)]
tbl.regions <- tbl.regions[order(tbl.regions$start, decreasing=FALSE),]
rownames(tbl.regions) <- NULL

#----------------------------------------------------------------------------------------------------
# plot ataq-seq scores for each open region
# a possible trend:
#          first three samples are high:    N1-3
#     next seven are about half as much:    L5, L7
#     final six are at about 10% of max:    L14, L21
#----------------------------------------------------------------------------------------------------
plot(tbl.regions[1:16, "score"], type="b", col="blue")
plot(tbl.regions[17:32, "score"], type="b", col="darkgreen")
plot(tbl.regions[33:48, "score"], type="b", col="red")

#----------------------------------------------------------------------------------------------------
# what motifs are found in these open chromatin regions?
#----------------------------------------------------------------------------------------------------
mm <- MotifMatcher(genomeName="mm10")

tbl.regions.uniq <- unique(tbl.regions[, 1:3])
tmp <- lapply(seq_len(nrow(tbl.regions.uniq)), function(i) getSequence(mm, tbl.regions.uniq[i,]))
tbl.seq <- do.call(rbind, tmp)
tbl.seq$width <- 1 + tbl.seq$end - tbl.seq$start
tbl.seq <- tbl.seq[, c("chr", "start", "end", "width", "seq")]
motif.info <- findMatchesByChromosomalRegion(mm, tbl.regions.uniq, pwmMatchMinimumAsPercentage=92)
tbl.motifs <- motif.info$tbl
motif.tfs <- motif.info$tfs
dim(tbl.motifs)

#----------------------------------------------------------------------------------------------------
# lay these out as an igv track
#----------------------------------------------------------------------------------------------------
addBedTrackFromDataFrame(tv, "motifs.92", tbl.motifs[, c("chrom", "motifStart", "motifEnd", "motifName", "motifRelativeScore")],
                         color="red")


#----------------------------------------------------------------------------------------------------
# read in the early-stage RNA, N1-3, L5_1-3, in which the ataq-seq data suggests the chromatin
# is open
#----------------------------------------------------------------------------------------------------
files <- grep("RNA", list.files(), v=TRUE)
sample.names <- unlist(lapply(strsplit(files, "_"), "[", 3))
names(files) <- sample.names
files <- as.list(files)

tbls.rna <- list()
for(i in seq_len(length(files))){
   file.name <- files[[i]]
   sample.name <- names(files)[i]
   tbl.tmp <- read.table(file.name, sep="\t", header=FALSE)
   colnames(tbl.tmp) <- c("geneID", sample.names[i])
   rownames(tbl.tmp) <- tbl.tmp$geneID
   tbl.tmp <- tbl.tmp[, 2, drop=FALSE]   # drop the geneID column
   tbls.rna[[i]] <- tbl.tmp
   }

#----------------------------------------------------------------------------------------------------
# ensure that all geneIDs are the same, in the same order
# then combine column-wise
#----------------------------------------------------------------------------------------------------
for(i in 2:6)
   stopifnot(all(tbls.rna[[1]][, "geneID"] == tbls.rna[[i]][, "geneID"]))

tbl.rna <- do.call(cbind, tbls.rna)

#----------------------------------------------------------------------------------------------------
# use the "inparanoid" package to map mouse entrez ids to human gene symbols, by way of ensemble
# ortholog protein ids
# first, lookup the ensembl protein ids, make them a new column in the table
# for now duplicates are summarily (perhaps improperly) removed
#----------------------------------------------------------------------------------------------------
libary(org.Mm.eg.db)
#tbl.mouseIDs <- select(org.Mm.eg.db, keys=rownames(tbl.rna), keytype="ENTREZID", columns=c("SYMBOL", "ENSEMBLPROT"))
tbl.mouseIDs <- select(org.Mm.eg.db, keys=rownames(tbl.rna), keytype="ENTREZID", columns=c("SYMBOL"))
dups <- which(duplicated(tbl.mouseIDs$ENTREZID))
if(length(dups) > 0)
   tbl.mouseIDs <- tbl.mouseIDs[-dups,]
nas <- which(is.na(tbl.mouseIDs$ENSEMBLPROT))
if(length(nas) > 0)
   tbl.mouseIDs <- tbl.mouseIDs[-nas, , drop=FALSE]
stopifnot(all(tbl.mouseIDs$ENTREZID == rownames(tbl.rna)))
rownames(tbl.mouseIDs) <- tbl.mouseIDs$ENTREZID
tbl.mouseIDs <- tbl.mouseIDs[, -1, drop=FALSE]
colnames(tbl.mouseIDs) <- c("MmSYMBOL", "MmENSEMBLPROT")
#----------------------------------------------------------------------------------------------------
# now find the human ensembl protein id
#----------------------------------------------------------------------------------------------------
tbl.MmHs.prot <- select(hom.Mm.inp.db, keys=tbl.mouseIDs$MmENSEMBLPROT, columns="HOMO_SAPIENS", keytype="MUS_MUSCULUS")
nas <- which(is.na(tbl.MmHs.prot$MUS_MUSCULUS))
if(length(nas) > 0)
   tbl.MmHs.prot <- tbl.MmHs.prot[-nas, , drop=FALSE]

nas <- which(is.na(tbl.MmHs.prot$HOMO_SAPIENS))
if(length(nas) > 0)
   tbl.MmHs.prot <- tbl.MmHs.prot[-nas, , drop=FALSE]

#----------------------------------------------------------------------------------------------------
# only about 1 in 4 of the original mouse entrez ids map onto human proteins
#----------------------------------------------------------------------------------------------------
dim(tbl.MmHs.prot) # [1] 4959    2

#----------------------------------------------------------------------------------------------------
# get the human gene symbols for these proteins
#----------------------------------------------------------------------------------------------------
tbl.HsSYMBOL <- select(org.Hs.eg.db, keys=tbl.MmHs.prot$HOMO_SAPIENS, keytype="ENSEMBLPROT", columns=c("SYMBOL"))
mapped.to.Hs.genes <- tbl.HsSYMBOL$SYMBOL
nas <- which(is.na(mapped.to.Hs.genes))
length(nas) # [1] 2876
mapped.to.Hs.genes <- mapped.to.Hs.genes[-nas]
length(mapped.to.Hs.genes) # [1] 2098
length(intersect(mapped.to.Hs.genes, motif.tfs))  # just 76

#----------------------------------------------------------------------------------------------------
# the utterly naive approach - capitalizing the mouse gene symbols,
# intersects 270/292 tfs returned by motif matcher.  use that for now, pending Hamid's disbelief!
#----------------------------------------------------------------------------------------------------
dups <- which(duplicated(tbl.rna$MmSYMBOL))
if(lenth(dups) > 0)
   tbl.rna <- tbl.rna[-dups, , drop=FALSE)
nas <- which(is.na(tbl.rna$MmSYMBOL))
if(length(nas) > 0)
   tbl.rna <- tbl.rna[-nas, , drop=FALSE]

mtx.rna <- tbl.rna[, 1:6]
colnames(mtx.rna) <- c("N1", "N2", "N3", "L5.1", "L5.2", "L5.3")
rownames(mtx.rna) <- toupper(tbl.rna$MmSYMBOL)
save(mtx.rna, file="mtx.rna.3N3L5.RData")

printf("possible motifs for which we have expression: %d/%d", length(intersect(motif.tfs, rownames(mtx.rna))), length(motif.tfs))
