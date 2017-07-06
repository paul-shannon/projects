library(gplots)
library(TrenaHelpers)
library(GOstats)
library(RSQLite)
library(GO.db)
library(Category)
library(org.Hs.eg.db)
library(KEGG.db)
library(graph)
#------------------------------------------------------------------------------------------------------------------------
source("~/github/projects/utils/geneIdMapping/symToGeneID.R"); test_assignGeneIDs()
#------------------------------------------------------------------------------------------------------------------------
load("/Users/paul/github/trenaHelpers/inst/demos/aqp4/labMeeting-22jun2017/mayo.rnaSeq.cer.and.tcx.matrices.RData") # mtx.tcx, mtx.cer
trn.mayoTcx <- readRDS("mayo.tcx.rds")
tbl.mod60 <- read.table("mod60CEB", stringsAsFactors=FALSE, sep=",", header=TRUE)
goi <- intersect(tbl.mod60$external_gene_name, rownames(mtx.cer)) # 253/265
goi <- intersect(goi, trn.mayoTcx$target.gene)  # 249 genes
setdiff(tbl.mod60$external_gene_name, rownames(mtx.cer))
# DHRS9 LILRA1 WDFY4 CD180 HPGDS TLR10 LILRB3 HSPA7 LINC01736 LINC01141 CLEC5A RP6-159A1.4
#------------------------------------------------------------------------------------------------------------------------
goReport <- function(genes, ontologies="BP")
{
   tbl.genes <- select(org.Hs.eg.db, keys=genes, keytype="SYMBOL", columns=c("SYMBOL", "GO"))
   tbl.goTerms <- select(GO.db, keys=tbl.genes$GO, keytype="GOID", columns=c("GOID", "TERM", "ONTOLOGY"))
   tbl.merged <- merge(subset(tbl.genes, ONTOLOGY=="BP"), tbl.goTerms, by.x="GO", by.y="GOID")
   #browser(); xyz <- 99
   dups <- which(duplicated(tbl.merged[, c(1,2)]))
   if(length(dups) > 0)
      tbl.merged <- tbl.merged[-dups,]

   tbl.merged

} # goReport
#------------------------------------------------------------------------------------------------------------------------
goEnrichment <- function(genes, gene.universe=character(0), pval.threshold=0.05, participation.threshold=0.75)
{
   symbol.entrez.map <- assignGeneIDs(genes)$mapped
   geneIDs <- unlist(symbol.entrez.map, use.names=FALSE)
   if(length(gene.universe) > 0){
      symbol.entrez.map <- assignGeneIDs(gene.universe)$mapped
      gene.universe <- unlist(symbol.entrez.map, use.names=FALSE)
      }

   printf("%d genes against background of %d genes", length(geneIDs), length(gene.universe))
   #browser()
   go.params <- new("GOHyperGParams", geneIds=unique(geneIDs),
                    universeGeneIds = gene.universe, annotation = "org.Hs.eg.db",
                    ontology = 'BP', pvalueCutoff = pval.threshold, conditional = FALSE,
                    testDirection = "over")
   go.bp.hgr <- hyperGTest(go.params)
   tbl.out <- summary(go.bp.hgr)
   subset(tbl.out, Count >= length(genes) * participation.threshold)

} # goEnrichment
#------------------------------------------------------------------------------------------------------------------------
regulatoryGraph <- function(mtx, tfs)
{
   threshold <- 5

   targetNodes <- c()
   for(tf in tfs){
      new.targets <- names(which(mtx[, tf] > threshold))
      targetNodes <- c(targetNodes, new.targets)
      } # for tf

   nodes <- unique(c(targetNodes, tfs))

   browser()
   g <- graphNEL(nodes, edgemode="directed")

   nodeDataDefaults(g, attr="nodeType") <- "target"
   nodeData(g, tfs, attr="nodeType") <- "TF"
   edgeDataDefaults(g, attr="edgeType") <- "regulates"
   edgeDataDefaults(g, attr="score1") <- 0


   for(tf in tfs){
      targets <- names(which(mtx[, tf] > threshold))
      scores <- mtx[targets, tf]
      g <- addEdge(tf, targets, g)
      edgeData(g, tf, targets, attr="score1") <- as.numeric(scores)
      } # for tf

   g

} # regulatoryGraph
#------------------------------------------------------------------------------------------------------------------------
test_regulatoryGraph <- function()
{
   printf("--- test_regulatoryGraph")
   tfs <- names(sort(colSums(mtx.model), decreasing=TRUE))[1:5]
   g <- regulatoryGraph(mtx.model, tfs)
   browser()
   xyz <- 99

} # test_regulatoryGraph
#------------------------------------------------------------------------------------------------------------------------
showHeatmaps <- function()
{
  heatmap.2(mtx.cer[goi,], trace='none')
  goiNeg <- setdiff(rownames(mtx.cer), goi)
  heatmap.2(mtx.cer[goiNeg,], trace='none')

} # showHeatmaps
#------------------------------------------------------------------------------------------------------------------------
buildModelMatrix <- function()
{
   # extract predictors of the 253 goi genes
   tf.counts <- sapply(goi, function(g)  nrow(subset(trn.mayoTcx, target.gene==g & pcaMax > 2.5)))
   fivenum(tf.counts)

   top.tfs.by.gene <- lapply(goi, function(g)  subset(trn.mayoTcx, target.gene==g & pcaMax > 2.5)[, c("target.gene", "gene", "pcaMax")])
   tbl.top <- do.call(rbind, top.tfs.by.gene)
   tbl.tfs <- as.data.frame(head(sort(table(tbl.top$gene), decreasing=TRUE), n=10))
   # shows top 8 regulators have markedly higher counts
   # as.data.frame(head(sort(table(tbl.top$gene), decreasing=TRUE), n=20))
   #      Var1 Freq
   # 1    SPI1  179
   # 2    IRF5  149
   # 3    TFEC  134
   # 4    LYL1  130
   # 5    IRF8  115
   # 6   IKZF1  105
   # 7   RUNX1   99
   # 8    ELF4   95
   # 9    TAL1   66
   # 10 NFATC2   41
   # 11  BACH1   35
   # 12  CEBPA   29
   # 13   ELK3   28
   # 14    REL   27
   # 15   FLI1   26
   # 16 POU2F2   23
   # 17   HHEX   21
   # 18 STAT5A   21
   # 19    MAF   13
   # 20   IRF7   12
   top.tfs <- as.character(subset(tbl.tfs, Freq > 90)$Var1)
   all.tfs <- sort(unique(trn.mayoTcx$gene))
   mtx.model <- matrix(data=0,nrow=length(goi), ncol=length(top.tfs), dimnames=list(goi, top.tfs))

   for(targetGene in rownames(mtx.model)){
      pcaMax.list <- as.list(subset(trn.mayoTcx, target.gene==targetGene & gene %in% top.tfs)[, c("pcaMax", "gene")])
      printf("%d pcaMax values found for %s", length(pcaMax.list$gene), targetGene)
      mtx.model[targetGene, pcaMax.list$gene] <- pcaMax.list$pcaMax
      #browser()
      #xyz <- 99
     } # for target.gene

   tbl.mds <- as.data.frame(cmdscale(dist(mtx.model), eig=FALSE,k=2))
   colnames(tbl.mds) <- c("x", "y")
   tbl.mds$gene <- rownames(tbl.mds)

    # plot(tbl.mds$x, tbl.mds$y)
    # text(tbl.mds$x, tbl.mds$y-0.3, labels=tbl.mds$gene, cex=0.7)
   list(mds=tbl.mds, mtx=mtx.model)

} # buildModelMatrix
#------------------------------------------------------------------------------------------------------------------------
run <- function()
{
   #x <- buildModelMatrix()
   #save(x, file="clusterModel.RData")
   load("clusterModel.RData")
   tbl.mds <- x$mds
   tv <- TrenaViz()
   nodes <- tbl.mds$gene
   g <- graphNEL(nodes=nodes, edgemode="directed")
   nodeDataDefaults(g, attr="xPos") <- 0
   nodeDataDefaults(g, attr="yPos") <- 0
   nodeDataDefaults(g, attr="label") <- "unassigned"
   nodeDataDefaults(g, attr="score1") <- 0
   nodeDataDefaults(g, attr="score2") <- 0
   nodeData(g, attr="xPos", nodes) <- tbl.mds$x * 200
   nodeData(g, attr="yPos", nodes) <- tbl.mds$y * 100
   nodeData(g, attr="label", nodes) <- nodes
   httpAddStructureGraph(tv, g)
   loadStructureStyle(tv, "style.js")
   fit(tv)
   tfs <- colnames(x$mtx)
   printf(tfs[1])
   tf1 <- "SPI1"
   tf2 <- "RUNX1"
   setNodeAttributes(tv, "score1", rownames(x$mtx), x$mtx[, tf1], "structureCy")
   setNodeAttributes(tv, "score2", rownames(x$mtx), x$mtx[, tf2], "structureCy")

   browser()

   list(tv=tv, mds=tbl.mds, mtx=mtx.model)

} # run
#------------------------------------------------------------------------------------------------------------------------
display.tfs <- function(tf1, tf2)
{
   setNodeAttributes(tv, "score1", rownames(x$mtx), x$mtx[, tf1], "structureCy")
   setNodeAttributes(tv, "score2", rownames(x$mtx), x$mtx[, tf2], "structureCy")

} # display.tfs
#------------------------------------------------------------------------------------------------------------------------
build.go.tables <- function(geneNames)
{
   symbol.entrez.map <- assignGeneIDs(nodes)$mapped

   gene.universe = character(0)
   geneIDs <- unlist(symbol.entrez.map, use.names=FALSE)

   go.params <- new("GOHyperGParams", geneIds=unique(geneIDs),
                    universeGeneIds = gene.universe, annotation = "org.Hs.eg.db",
                    ontology = 'BP', pvalueCutoff = 0.05, conditional = FALSE,
                    testDirection = "over")

   kegg.params <- new("KEGGHyperGParams", geneIds = unique(geneIDs),
                      universeGeneIds = character(0), annotation = "org.Hs.eg.db",
                      pvalueCutoff = 0.1, testDirection = "over")

   go.bp.hgr <- hyperGTest(go.params)
   kegg.hgr  <- hyperGTest(kegg.params)
   tbl.go <- summary(go.bp.hgr)
   tbl.kegg <- summary(kegg.hgr)
   save(tbl.go, tbl.kegg, file="go.kegg.tables.RData")

} # build.go.tables
#------------------------------------------------------------------------------------------------------------------------
createGO.gene.map <- function()
{
   load("clusterModel.RData")
   genes <- unique(x$mds$gene)

   tbl.gobp.byGene <- goReport(genes)
   tbl.gobp.enrichment <- goEnrichment(genes, gene.universe=character(0), pval.threshold=0.05, participation.threshold=0.1)
   tbl.gobp.enrichment.filtered <- subset(tbl.gobp.enrichment, GOBPID %in% tbl.gobp.byGene$GO)
     # "GO:0050900"
     #  subset(tbl.gobp.enrichment, GOBPID=="GO:0050900")
     #      GOBPID       Pvalue OddsRatio ExpCount Count Size                Term
     #  GO:0050900 1.244161e-22  9.743032 5.037428    38  362 leukocyte migration
     # length(subset(tbl.gobp.byGene, GO == "GO:0050900")$SYMBOL)  # 15
     # other 23 are implied by more specific terms?

   selectStructureNodes(tv, subset(tbl.gobp.byGene, GO=="GO:0050900")$SYMBOL)

   load("clusterModel.RData")
   tbl.go <- goReport(x$mds$gene)[, c("GO", "SYMBOL")]
   unique.ids <- unique(tbl.go$GO)
   go.list <- list()
   for(id in unique.ids){
      genes <- subset(tbl.go, GO==id)$SYMBOL
      go.list[[id]] <- genes
      }

   go.list

} # cerateGO.gene.map
#------------------------------------------------------------------------------------------------------------------------
# use org.Hs.egGO2ALLEGs, which maps child nodes to every parent GOBP node
identify.all.genes.annotated.to.leukocyte.activation <- function()
{
   leukocyte.aggregation <- "GO:0070486"
   subset(tbl.gobp.enrichment, GOBPID == leukocyte.aggregation)
     #        GOBPID       Pvalue OddsRatio ExpCount Count Size                  Term
     # 25 GO:0070486 3.346073e-23   8.81901 6.178503    42  444 leukocyte aggregation
     #
     # 444 genes mapped to leukocyte.aggregation, but only SEMA4D directly in org.Hs.egGO2EG:
   all.la.geneIDs <- unique(as.character(get(leukocyte.aggregation, org.Hs.egGO2ALLEGS))) # 444
   all.la.geneSymbols <- as.character(sapply(all.la.geneIDs, function(geneID) get(geneID, org.Hs.egSYMBOL))) # 42
   selectStructureNodes(tv, intersect(genes, all.la.geneSymbols))

} # identify.all.genes.annotated.to.leukocyte.activation
#------------------------------------------------------------------------------------------------------------------------
# need json data structure of GOBP term to all genes in the current set
create.go.to.gene.map <- function()
{
   stopifnot(length(genes) == 249)   # assigned above from cory's data
   geneIDs <- as.character(assignGeneIDs(genes)$mapped)
   stopifnot(nrow(tbl.gobp.enrichment) == 196)
   bp.terms <- unique(tbl.gobp.enrichment$GOBPID)
   geneIDs.by.term <- sapply(bp.terms, function(term)
                              intersect(geneIDs, as.character(get(term, org.Hs.egGO2ALLEGS))))
   genes.by.term <- lapply(names(geneIDs.by.term),
          function(term) as.character(mget(geneIDs.by.term[[term]], org.Hs.egSYMBOL)))
   names(genes.by.term) <- names(geneIDs.by.term)
   toJSON(genes.by.term)

} # create.go.to.gene.map
#------------------------------------------------------------------------------------------------------------------------
two.tf.score <- function(tf1, tf2)
{
} # two.tf.score
#------------------------------------------------------------------------------------------------------------------------
test_two.tf.score <- function()
{
   printf("--- test_two.tf.score")
   tf1 <- "SPI1"
   tf2 <- "RUNX1"
   gene <- "C3"
   gene <- "LAPTM5"

    # x$mtx["LAIR1",]
    #       SPI1      IRF5      TFEC      LYL1      IRF8     IKZF1     RUNX1      ELF4
    #  11.930483  3.304261  5.766403  3.404247  3.298862  0.000000 15.324002  2.624654

   denominator <- max(x$mtx)
   component.one <- 255 - round(255 * x$mtx[gene, tf1]/denominator)
   component.two <- 255 - round(255 * x$mtx[gene, tf2]/denominator)
   sprintf("#%02X%02X%02X", component.one, 0, component.two)

} # test_two.tf.score
#------------------------------------------------------------------------------------------------------------------------
