# server.R: explore creation and provision of gene models
#------------------------------------------------------------------------------------------------------------------------
library(rzmq)
library(jsonlite)
library(RPostgreSQL)
library(TReNA)
library(stringr)
library(graph)
library(RUnit)
library(igraph)
#------------------------------------------------------------------------------------------------------------------------
load("~/github/BDDS/trenadb/src/coryADpresentationNov2016/rosmap_counts_matrix_normalized_geneSymbols_25031x638.RData")
mtx.expression <- asinh(mtx)
genome.db.uri    <- "postgres://whovian/hg38"             # has gtf and motifsgenes tables
footprint.db.uri <- "postgres://whovian/brain_hint"        # has hits and regions tables
if(!exists("fpf"))
   fpf <- FootprintFinder(genome.db.uri, footprint.db.uri, quiet=TRUE)
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
  test.extractChromStartEndFromChromLocString()
  test.createGeneModel();
  test.tableToReducedGraph()
  test.tableToFullGraph()
  test.graphnelToCyjsJSON()

}  # runTests
#------------------------------------------------------------------------------------------------------------------------
extractChromStartEndFromChromLocString <- function(chromlocString)
{
   chromlocString <- gsub(",", "", chromlocString)

   mtx.match <- str_match(chromlocString, ("(.*):(\\d+)-(\\d+)"))
   chromosome <- tolower(mtx.match[1, 2])
   if(!grepl("chr", chromosome))
       chromosome <- sprintf("chr%s", chromosome)

   start <- as.integer(mtx.match[1, 3])
   end <- as.integer(mtx.match[1, 4])

   return(list(chrom=chromosome, start=start, end=end))

}  # extractChromStartEndFromChromLocString
#------------------------------------------------------------------------------------------------------------------------
test.extractChromStartEndFromChromLocString <- function()
{
   print("--- test.extractChromStartEndFromChromLocString")
   checkEquals(extractChromStartEndFromChromLocString("7:1010165577-101165615"),
               list(chrom="chr7", start=1010165577, end=101165615))

   checkEquals(extractChromStartEndFromChromLocString("chr7:1010165577-101165615"),
               list(chrom="chr7", start=1010165577, end=101165615))

   checkEquals(extractChromStartEndFromChromLocString("CHR7:1010165577-101165615"),
               list(chrom="chr7", start=1010165577, end=101165615))

   checkEquals(extractChromStartEndFromChromLocString("7:101,165,576-101,165,615"),
               list(chrom="chr7", start=101165576, end=101165615))

}  # test.extractChromStartEndFromChromLocString
#------------------------------------------------------------------------------------------------------------------------
createGeneModel <- function(target.gene, region)
{
   absolute.lasso.beta.min <- 0.2
   absolute.expression.correlation.min <- 0.2
   randomForest.purity.min <- 1.0

   region.parsed <- extractChromStartEndFromChromLocString(region)
   chrom <- region.parsed$chrom
   start <- region.parsed$start
   end <-   region.parsed$end

   tbl.fp <- getFootprintsInRegion(fpf, chrom, start, end)
   if(nrow(tbl.fp) == 0){
       printf("no footprints found within in region %s:%d-%d", chrom, start, end)
       return(NA)
       }

   tbl.fp <- mapMotifsToTFsMergeIntoTable(fpf, tbl.fp)
   candidate.tfs <- sort(unique(tbl.fp$tf))
   candidate.tfs <- intersect(rownames(mtx.expression), candidate.tfs)
   goi <- sort(unique(c(target.gene, candidate.tfs)))

   mtx.matched <- mtx.expression[goi,]

   trena.lasso <- TReNA(mtx.matched, solver="lasso")
   trena.ranfor <- TReNA(mtx.matched, solver="randomForest")

   out.lasso <- solve(trena.lasso, target.gene, candidate.tfs)
   out.ranfor <- solve(trena.ranfor, target.gene, candidate.tfs)

   tbl.01 <- out.lasso
   tbl.01 <- tbl.01[, -(grep("^intercept$", colnames(tbl.01)))]
   tbl.01$gene <- rownames(out.lasso)
   rownames(tbl.01) <- NULL
   tbl.01 <- subset(tbl.01, abs(beta) >= absolute.lasso.beta.min &
                            abs(gene.cor) >= absolute.expression.correlation.min)

   tbl.02 <- out.ranfor$edges
   tbl.02$gene <- rownames(tbl.02)
   rownames(tbl.02) <- NULL
   tbl.02 <- subset(tbl.02, IncNodePurity >= randomForest.purity.min  &
                            abs(gene.cor) >= absolute.expression.correlation.min)

   tbl.03 <- merge(tbl.01, tbl.02, all.y=TRUE)
   #rownames(tbl.03) <- tbl.03$gene
   tbl.03$beta[is.na(tbl.03$beta)] <- 0
   tbl.03$IncNodePurity[is.na(tbl.03$IncNodePurity)] <- 0

   fpStarts.list <- lapply(tbl.02$gene, function(gene) subset(tbl.fp, tf==gene)[, c("tf", "start")])
   tbl.fpStarts <-  unique(do.call('rbind', fpStarts.list))

   tbl.04 <- merge(tbl.03, tbl.fpStarts, by.x="gene", by.y="tf")
   tbl.04 <- tbl.04[order(abs(tbl.04$gene.cor), decreasing=TRUE),]

   # footprint.start <- unlist(lapply(rownames(tbl.04), function(gene) subset(tbl.fp, tfe==gene)$start[1]))

   gene.info <- subset(tbl.tss, gene_name==target.gene)[1,]
   if(gene.info$strand  == "+"){
      gene.start <- gene.info$start
      tbl.04$distance <- gene.start - tbl.04$start
   }else{
      gene.start <- gene.info$end
      tbl.04$distance <-  tbl.04$start - gene.start
      }

   tbl.04

} # createGeneModel
#------------------------------------------------------------------------------------------------------------------------
test.createGeneModel <- function()
{
   printf("--- test.createGeneModel")
   region <- "7:101,165,571-101,165,620"   # about 25bp up and downstream from the VGF (minus strand) tss, 2 hint brain footprints
   target.gene <- "VGF"
   tbl.gm <- createGeneModel(target.gene, region)
   checkEquals(dim(tbl.gm), c(2,6))
   checkEquals(colnames(tbl.gm), c("gene", "gene.cor", "beta", "IncNodePurity", "start", "distance"))
   checkEquals(sort(tbl.gm$gene), c("MAZ", "NRF1"))

} # test.createGeneModel
#------------------------------------------------------------------------------------------------------------------------
tableToReducedGraph <- function(tbl.list)
{
   g <- graphNEL(edgemode = "directed")
   nodeDataDefaults(g, attr = "type") <- "undefined"
   nodeDataDefaults(g, attr = "label") <- "default node label"
   nodeDataDefaults(g, attr = "degree") <- 0

   edgeDataDefaults(g, attr = "edgeType") <- "undefined"
   edgeDataDefaults(g, attr = "geneCor") <- 0
   edgeDataDefaults(g, attr = "beta") <- 0
   edgeDataDefaults(g, attr = "purity") <- 0
   edgeDataDefaults(g, attr = "fpCount") <- 0

   for(target.gene in names(tbl.list)){
      tbl <- tbl.list[[target.gene]]
      tbl.fpCounts <- as.data.frame(table(tbl$gene))
      tbl <- merge(tbl, tbl.fpCounts, by.x="gene", by.y="Var1")
      colnames(tbl)[grep("Freq", colnames(tbl))] <- "fpCount"
      dups <- which(duplicated(tbl$gene))
      if(length(dups) > 0)
         tbl <- tbl[-dups,]

      tfs <- unique(tbl$gene)
      all.nodes <- unique(c(target.gene, tfs))
      new.nodes <- setdiff(all.nodes, nodes(g))
      g <- addNode(new.nodes, g)

      nodeData(g, target.gene, "type") <- "targetGene"
      nodeData(g, tfs, "type")         <- "TF"
      nodeData(g, all.nodes, "label")  <- all.nodes

      g <- graph::addEdge(tbl$gene, target.gene, g)
      edgeData(g, tbl$gene, target.gene, "edgeType") <- "regulatorySiteFor"
      edgeData(g, tbl$gene, target.gene, "fpCount") <- tbl$fpCount
      edgeData(g, tbl$gene, target.gene, "geneCor") <- tbl$gene.cor
      edgeData(g, tbl$gene, target.gene, "purity") <- tbl$IncNodePurity
      edgeData(g, tbl$gene, target.gene, "beta") <- tbl$beta
      } # for target.gene

   node.degrees <- graph::degree(g)   # avoid collision with igraph::degree
   degree <- node.degrees$inDegree + node.degrees$outDegree
   nodeData(g, names(degree), attr="degree") <- as.integer(degree)
   g

} # tableToReducedGraph
#------------------------------------------------------------------------------------------------------------------------
test.tableToReducedGraph <- function()
{
   printf("--- test.tableToReducedGraph")
   genes <- c("STAT4", "STAT4", "STAT4", "STAT4", "TBR1", "HLF")
   gene.cors <- c(0.9101553, 0.9101553, 0.9101553, 0.9101553, 0.8947867, 0.8872238)
   betas <- c(0.1255503, 0.1255503, 0.1255503, 0.1255503, 0.1448829, 0.0000000)
   IncNodePurities <- c(35.77897, 35.77897, 35.77897, 35.77897, 23.16562, 19.59660)
   starts <- c(5627705, 5628679, 5629563, 5629581, 5629563, 5629100)
   distances <- c(-2995, -2021, -1137, -1119, -1137, -1600)

   tbl.1 <- data.frame(gene=genes, gene.cor=gene.cors, beta=betas, IncNodePurity=IncNodePurities,
                       start=starts, distance=distances, stringsAsFactors=FALSE)

   target.gene.1 <- "EPB41L3"
   tbl.list <- list(tbl.1)
   names(tbl.list) <- target.gene.1
   g1 <- tableToReducedGraph(tbl.list)

   checkTrue(all(c(genes, target.gene.1) %in% nodes(g1)))
   checkEquals(sort(edgeNames(g1)), c("HLF~EPB41L3", "STAT4~EPB41L3", "TBR1~EPB41L3"))

   checkEquals(as.integer(edgeData(g1, from="STAT4", to="EPB41L3", attr="fpCount")), 4)
   checkEquals(as.integer(edgeData(g1, from="HLF", to="EPB41L3", attr="fpCount")), 1)
   checkEquals(as.integer(edgeData(g1, from="TBR1", to="EPB41L3", attr="fpCount")), 1)

   checkEqualsNumeric(unlist(edgeData(g1, attr="purity"), use.names=FALSE), c(19.59660, 35.77897, 23.16562))
   checkEqualsNumeric(unlist(edgeData(g1, attr="geneCor"), use.names=FALSE), c(0.8872238, 0.9101553, 0.8947867))
   checkEqualsNumeric(unlist(edgeData(g1, attr="beta"), use.names=FALSE), c(0.0000000, 0.1255503, 0.1448829))

} # test.tableToReducedGraph
#------------------------------------------------------------------------------------------------------------------------
tableToFullGraph <- function(tbl.list)
{
   g <- graphNEL(edgemode = "directed")
   nodeDataDefaults(g, attr = "type") <- "undefined"
   nodeDataDefaults(g, attr = "label") <- "default node label"
   nodeDataDefaults(g, attr = "distance") <- 0
   nodeDataDefaults(g, attr = "gene.cor") <- 0
   nodeDataDefaults(g, attr = "beta") <- 0
   nodeDataDefaults(g, attr = "purity") <- 0
   nodeDataDefaults(g, attr = "xPos") <- 0
   nodeDataDefaults(g, attr = "yPos") <- 0

   edgeDataDefaults(g, attr = "edgeType") <- "undefined"
   edgeDataDefaults(g, attr = "beta") <- 0
   edgeDataDefaults(g, attr = "purity") <- 0

   for(target.gene in names(tbl.list)){
      tbl <- tbl.list[[target.gene]]
      tfs <- tbl$gene
      footprints <- unlist(lapply(tbl$distance, function(x)
         if(x < 0)
            sprintf("%s.fp.downstream.%05d", target.gene, abs(x))
         else
            sprintf("%s.fp.upstream.%05d", target.gene, x)))

      tbl$footprint <- footprints
      all.nodes <- unique(c(target.gene, tfs, footprints))
      new.nodes <- setdiff(all.nodes, nodes(g))
      g <- addNode(new.nodes, g)

      nodeData(g, target.gene, "type") <- "targetGene"
      nodeData(g, tfs, "type")         <- "TF"
      nodeData(g, footprints, "type")  <- "footprint"
      nodeData(g, all.nodes, "label")  <- all.nodes
      nodeData(g, footprints, "label") <- tbl$distance
      nodeData(g, footprints, "distance") <- tbl$distance

      nodeData(g, tfs, "gene.cor") <- tbl$gene.cor
      nodeData(g, tfs, "beta") <- tbl$gene.cor
      nodeData(g, tfs, "purity") <- tbl$IncNodePurity

      g <- graph::addEdge(tbl$gene, tbl$footprint, g)
      edgeData(g, tbl$gene, tbl$footprint, "edgeType") <- "bindsTo"

      g <- graph::addEdge(tbl$footprint, target.gene, g)
      edgeData(g, tbl$footprint, target.gene, "edgeType") <- "regulatorySiteFor"
      } # for target.gene

   g

} # tableToFullGraph
#------------------------------------------------------------------------------------------------------------------------
test.tableToFullGraph <- function()
{
   printf("--- test.tableToFullGraph")

       #---- first, just one target.gene, one tbl
   genes <- c("STAT4", "STAT4", "STAT4", "STAT4", "TBR1", "HLF")
   gene.cors <- c(0.9101553, 0.9101553, 0.9101553, 0.9101553, 0.8947867, 0.8872238)
   betas <- c(0.1255503, 0.1255503, 0.1255503, 0.1255503, 0.1448829, 0.0000000)
   IncNodePurities <- c(35.77897, 35.77897, 35.77897, 35.77897, 23.16562, 19.59660)
   starts <- c(5627705, 5628679, 5629563, 5629581, 5629563, 5629100)
   distances <- c(-2995, -2021, -1137, -1119, -1137, -1600)

   tbl.1 <- data.frame(gene=genes, gene.cor=gene.cors, beta=betas, IncNodePurity=IncNodePurities,
                       start=starts, distance=distances, stringsAsFactors=FALSE)

   target.gene.1 <- "EPB41L3"
   tbl.list <- list(tbl.1)
   names(tbl.list) <- target.gene.1
   g1 <- tableToFullGraph(tbl.list)

   checkTrue(all(c(genes, target.gene.1) %in% nodes(g1)))

   fp.nodes <- sort(grep("^fp", nodes(g1), v=TRUE))
   fp.nodes <- sub("fp.downstream.", "", fp.nodes, fixed=TRUE)
   fp.nodes <- as.integer(sub("fp.upstream.", "", fp.nodes, fixed=TRUE))
   checkTrue(all(fp.nodes %in% abs(distances)))

     # one edge from footprint to TF for every footprint
     # one edge from every unique footprint to the target.gene
   expectedEdgeCount <- length(tbl.1$distance) + length(unique(tbl.1$distance))
   checkEquals(length(edgeNames(g1)), expectedEdgeCount)
   checkEquals(length(nodes(g1)),
               1 + length(unique(tbl.1$gene)) + length(unique(tbl.1$distance)))

       #---- now, try a second target.gene and its tbl
   genes <- c("STAT4", "STAT4", "HLF", "TFEB", "HMG20B", "HMG20B")
   gene.cors <- c(0.9162040, 0.9162040, 0.9028613, -0.8256594, -0.8226802, -0.8226802)
   betas <- c(0.1988552, 0.1988552, 0.1492857, 0.0000000, 0.0000000, 0.0000000)
   IncNodePurities <- c(43.37913, 43.37913, 36.93302, 11.27543, 10.17957, 10.17957)
   starts <- c(4451334, 4451640, 4452647, 4453748, 4453489, 4453491)
   distances <- c(-4001, -3695, -2688, -1587, -1846, -1844)

   tbl.2 <- data.frame(gene=genes, gene.cor=gene.cors, beta=betas, IncNodePurity=IncNodePurities,
                       start=starts, distance=distances, stringsAsFactors=FALSE)
   target.gene.2 <- "DLGAP1"

   tbl.list <- list(tbl.2)
   names(tbl.list) <- target.gene.2

   g2 <- tableToFullGraph(tbl.list)

   checkTrue(all(c(genes, target.gene.2) %in% nodes(g2)))

   fp.nodes <- sort(grep("^fp", nodes(g2), v=TRUE))
   fp.nodes <- sub("fp.downstream.", "", fp.nodes, fixed=TRUE)
   fp.nodes <- as.integer(sub("fp.upstream.", "", fp.nodes, fixed=TRUE))
   checkTrue(all(fp.nodes %in% abs(distances)))

     # one edge from footprint to TF for every footprint
     # one edge from every unique footprint to the target.gene
   expectedEdgeCount <- length(tbl.2$distance) + length(unique(tbl.2$distance))
   checkEquals(length(edgeNames(g2)), expectedEdgeCount)
   checkEquals(length(nodes(g2)),
               1 + length(unique(tbl.2$gene)) + length(unique(tbl.2$distance)))

     # now try both tables and target genes together

   tbl.list <- list(tbl.1, tbl.2)
   names(tbl.list) <- c(target.gene.1, target.gene.2)
   g3 <- tableToFullGraph(tbl.list)

} # test.tableToFullGraph
#------------------------------------------------------------------------------------------------------------------------
# {elements: [
#    {data: {id: 'a', score:5}, position: {x: 100, y: 200}},
#    {data: {id: 'b', score:100}, position: {x: 200, y: 200}},
#    {data: {id: 'e1', source: 'a', target: 'b'}}
#    ],  // elements array
# layout: { name: 'preset'},
# style: [{selector: 'node', style: {'content': 'data(id)'}}]
# }
graphToJSON <- function(g)
{
    x <- '{"elements": [';
    nodes <- nodes(g)
    edgeNames <- edgeNames(g)
    edges <- strsplit(edgeNames, "~")  # a list of pairs
    edgeNames <- sub("~", "->", edgeNames)
    names(edges) <- edgeNames

    noa.names <- names(nodeDataDefaults(g))
    eda.names <- names(edgeDataDefaults(g))
    nodeCount <- length(nodes)
    edgeCount <- length(edgeNames)

    for(n in 1:nodeCount){
       node <- nodes[n]
       x <- sprintf('%s {"data": {"id": "%s"', x, node);
       nodeAttributeCount <- length(noa.names)
       for(i in seq_len(nodeAttributeCount)){
          noa.name <- noa.names[i];
          value <-  nodeData(g, node, noa.name)[[1]]
          if(is.numeric(value))
             x <- sprintf('%s, "%s": %s', x, noa.name, value)
          else
             x <- sprintf('%s, "%s": "%s"', x, noa.name, value)
          } # for noa.name
       x <- sprintf('%s}', x)     # close off this node data element
       if(all(c("xPos", "yPos") %in% noa.names)){
           xPos <- as.numeric(nodeData(g, node, "xPos"));
           yPos <- as.numeric(nodeData(g, node, "yPos"))
           x <- sprintf('%s, "position": {"x": %d, "y": %d}', x, xPos, yPos)
           #browser()
           #xyz <- 99
           } # add position element
       x <- sprintf('%s}', x)     # close off this node data element
       if(n != nodeCount)
           x <- sprintf("%s,", x)  # another node coming, add a comma
       } # for n

    for(e in seq_len(edgeCount)) {
       edgeName <- edgeNames[e]
       edge <- edges[[e]]
       sourceNode <- edge[[1]]
       targetNode <- edge[[2]]
       x <- sprintf('%s, {"data": {"id": "%s", "source": "%s", "target": "%s"', x, edgeName, sourceNode, targetNode);
       edgeAttributeCount <- length(eda.names)
       for(i in seq_len(edgeAttributeCount)){
          eda.name <- eda.names[i];
          value <-  edgeData(g, sourceNode, targetNode, eda.name)[[1]]
          if(is.numeric(value))
             x <- sprintf('%s, "%s": %s', x, eda.name, value)
          else
             x <- sprintf('%s, "%s": "%s"', x, eda.name, value)
          } # for each edgeAttribute
       x <- sprintf('%s}}', x)     # close off this edge data element
       } # for e

    x <- sprintf("%s]}", x)

    x

} # graphToJSON
#------------------------------------------------------------------------------------------------------------------------
test.graphToJSON <- function()
{
   printf("--- test.graphToJSON")
   g <- graphNEL(edgemode='directed')

   nodeDataDefaults(g, attr='label') <- 'default node label'
   nodeDataDefaults(g, attr='type') <- 'default node label'
   nodeDataDefaults(g, attr='count') <- 0
   nodeDataDefaults(g, attr='score') <- 0.0

   edgeDataDefaults(g, attr='edgeType') <- 'undefined'
   edgeDataDefaults(g, attr='count') <- 0
   edgeDataDefaults(g, attr='score') <- 0.0

   g <- graph::addNode('A', g)
   g <- graph::addNode('B', g)
   g <- graph::addNode('C', g)

   all.nodes <- nodes(g)
   nodeData(g, c('A', 'B', 'C'), 'type') <- c('t_one', 't_two', 't_three')
   nodeData(g, all.nodes, 'label') <- all.nodes
   nodeData(g, all.nodes, 'score') <- runif(3, 0, 1)
   nodeData(g, all.nodes, 'count') <- sample(1:10, 3)

     # now add 1 edge
   g <- graph::addEdge('A', 'B', g)
   g <- graph::addEdge('B', 'C', g)
   g <- graph::addEdge('C', 'A', g)

   edgeData(g, 'A', 'B', 'edgeType') <- 'et_one'
   edgeData(g, 'B', 'C', 'edgeType') <- 'et_two'

   edgeData(g, 'A', 'B', 'score') <- runif(1, 0, 1)
   edgeData(g, 'C', 'A', 'score') <- runif(1, 0, 1)

   edgeData(g, 'B', 'C', 'count') <- sample(1:10, 1)
   edgeData(g, 'C', 'A', 'count') <- sample(1:10, 1)

   g.json <- graphToJSON(g)
      # a pretty good check, but only an assist to the real test, which is to load this the
      # browser with cy.json(JSON.parse(<g.json string>))

   tbl <- fromJSON(g.json)[[1]][[1]]
   checkEquals(nrow(tbl), length(nodes(g)) + length(edgeNames(g)))
   checkEquals(colnames(tbl), c("id", "label", "type", "count", "score", "source", "target", "edgeType"))
   checkEquals(unlist(lapply(tbl, class), use.names=FALSE),
               c("character", "character", "character", "integer", "numeric", "character", "character", "character"))
   checkEquals(tbl$type[1:3], c("t_one", "t_two", "t_three"))
   checkEquals(tbl$edgeType[4:6], c("et_one", "et_two", "undefined"))

} # test.graphToJSON
#------------------------------------------------------------------------------------------------------------------------
addGeneModelLayout <- function(g)
{
   fp.nodes <- nodes(g)[which(unlist(nodeData(g, attr="type"), use.names=FALSE) == "footprint")]
   tf.nodes <- nodes(g)[which(unlist(nodeData(g, attr="type"), use.names=FALSE) == "TF")]
   targetGene.nodes <- nodes(g)[which(unlist(nodeData(g, attr="type"), use.names=FALSE) == "targetGene")]

   nodeData(g, fp.nodes, "xPos") <- as.numeric(nodeData(g, fp.nodes, attr="distance")) * 10
   nodeData(g, fp.nodes, "yPos") <- 0

   nodeData(g, tf.nodes, "xPos") <- 0
   nodeData(g, tf.nodes, "yPos") <- 400

   nodeData(g, targetGene.nodes, "xPos") <- 0
   nodeData(g, targetGene.nodes, "yPos") <- -500

   g

} # addGeneModelLayout
#------------------------------------------------------------------------------------------------------------------------
test.addGeneModelLayout <- function()
{
   printf("--- test.addGeneModelLayout")
   region <- "7:101,165,571-101,165,620"   # about 25bp up and downstream from the VGF (minus strand) tss, 2 hint brain footprints
   target.gene <- "VGF"
   tbl.gm <- createGeneModel(target.gene, region)
   tbl.list <- list(tbl.gm)
   names(tbl.list) <- target.gene

   g2 <- tableToFullGraph(tbl.list)
   g2.pos <- addGeneModelLayout(g2)
   g2.json <- graphToJSON(g2.pos)
   tbl <- fromJSON(g2.json)[[1]][[1]]

   checkEquals(nrow(tbl), length(nodes(g2)) + length(edgeNames(g2)))
   checkEquals(colnames(tbl),
           c("id", "type", "label", "distance", "gene.cor", "beta", "purity", "xPos", "yPos", "source", "target", "edgeType"))

   checkEquals(unlist(lapply(tbl, class), use.names=FALSE),
               c("character", "character", "character", "integer", "numeric", "numeric", "numeric", "integer", "integer",
                 "character", "character", "character"))

   checkEquals(tbl$type[1:3], c("targetGene", "TF", "TF"))
   checkEquals(tbl$edgeType[6:9], c("bindsTo", "bindsTo", "regulatorySiteFor", "regulatorySiteFor"))

   checkEquals(tbl$edgeType[4:6], c("et_one", "et_two", "undefined"))

      # now a larger graph

   region <- "7:101,165,600-101,165,700"   # about 25bp up and downstream from the VGF (minus strand) tss, 2 hint brain footprints
   region <- "7:101,165,560-101,165,630"
   target.gene <- "VGF"
   tbl.gm <- createGeneModel(target.gene, region)
   tbl.list <- list(tbl.gm)
   names(tbl.list) <- target.gene

   g2 <- tableToFullGraph(tbl.list)
   g2.pos <- addGeneModelLayout(g2)
   g2.json <- graphToJSON(g2.pos)
   print(g2.json)

} # test.addGeneModelLayout
#------------------------------------------------------------------------------------------------------------------------
graphnelToCyjsJSON <- function (graph) {

  igraphobj <- igraph::igraph.from.graphNEL(graph)


  # Extract graph attributes
  graph_attr = graph.attributes(igraphobj)

  # Extract nodes
  node_count = length(V(igraphobj))
  if('name' %in% list.vertex.attributes(igraphobj)) {
    V(igraphobj)$id <- V(igraphobj)$name
  } else {
    V(igraphobj)$id <-as.character(c(1:node_count))
  }


  nodes <- V(igraphobj)
  nds = list()

  v_attr = vertex.attributes(igraphobj)
  v_names = list.vertex.attributes(igraphobj)


  for(i in seq_len(node_count)){   #   1:node_count) {
    nds[[i]] = list(data = mapAttributes(v_names, v_attr, i))
    }

  edges <- get.edgelist(igraphobj)
  edge_count = ecount(igraphobj)
  e_attr <- edge.attributes(igraphobj)
  e_names = list.edge.attributes(igraphobj)

  attr_exists = FALSE
  e_names_len = 0
  if(identical(e_names, character(0)) == FALSE) {
    attr_exists = TRUE
    e_names_len = length(e_names)
    }
  e_names_len <- length(e_names)

  eds = list()
  if(edge_count > 0){
    for(i in 1:edge_count) {
       st = list(source=toString(edges[i,1]), target=toString(edges[i,2]))

    # Extract attributes
     if(attr_exists) {
       eds[[i]] = list(data=c(st, mapAttributes(e_names, e_attr, i)))
      } else {
      eds[[i]] = list(data=st)
      }
    }
   } # if edge_count > 0

  el = list(nodes=nds, edges=eds)

  x <- list(data = graph_attr, elements = el)
  #return (toJSON(x))
  return(x)

} # graphnelToCyjsJSON
#----------------------------------------------------------------------------------------------------
mapAttributes <- function(attr.names, all.attr, i)
{
  attr = list()
  cur.attr.names = attr.names
  attr.names.length = length(attr.names)

  for(j in 1:attr.names.length) {
    if(is.na(all.attr[[j]][i]) == FALSE) {
      attr <- c(attr, all.attr[[j]][i])
      }
    else {
      cur.attr.names <- cur.attr.names[cur.attr.names != attr.names[j]]
      }
    } # for j

  names(attr) = cur.attr.names
  return (attr)

} # mapAttributes
#----------------------------------------------------------------------------------------------------
test.graphnelToCyjsJSON <- function()
{
   printf("--- test.graphnelToCyjsJSON")

   region <- "7:101,165,571-101,165,620"   # about 25bp up and downstream from the VGF (minus strand) tss, 2 hint brain footprints
   target.gene <- "VGF"
   tbl.gm <- createGeneModel(target.gene, region)
   tbl.list <- list(tbl.gm)
   names(tbl.list) <- target.gene
   g1 <- tableToReducedGraph(tbl.list)
   json <- graphnelToCyjsJSON(g1)

      # a partial check:  convert back to R, which produces, not a graphNEL, but a list of node and edge tables

   list <- fromJSON(json)
   checkEquals(sort(names(list)), c("data", "elements"))
   checkEquals(sort(names(list$elements)), c("edges", "nodes"))
   tbl.nodes <- list$elements$nodes[[1]]
   checkEquals(dim(tbl.nodes), c(3,5))
   checkEquals(colnames(tbl.nodes), c("name", "type", "label",  "degree", "id"))
   checkEquals(sort(unlist(tbl.nodes$id)), c("MAZ", "NRF1", "VGF"))

   tbl.edges <- list$elements$edges[[1]]
   checkEquals(colnames(tbl.edges), c("source", "target", "edgeType", "geneCor", "beta", "purity", "fpCount"))

      # now test with a full graph, which include footprints between TFs and the target gene,
      # the more common use

    g2 <- tableToFullGraph(tbl.list)
    json <- graphnelToCyjsJSON(g2)

      # a partial check:  convert back to R, which produces, not a graphNEL, but a list of node and edge tables

   list <- fromJSON(json)
   checkEquals(sort(names(list)), c("data", "elements"))
   checkEquals(sort(names(list$elements)), c("edges", "nodes"))
   tbl.nodes <- list$elements$nodes[[1]]

   checkEquals(dim(tbl.nodes), c(5, 8))
   checkEquals(colnames(tbl.nodes), c("name", "type", "label", "distance", "gene.cor", "beta", "purity", "id"))
   checkEquals(sort(unlist(tbl.nodes$id)), c("MAZ", "NRF1", "VGF", "VGF.fp.downstream.00018", "VGF.fp.upstream.00009"))

   tbl.edges <- list$elements$edges[[1]]
   checkEquals(colnames(tbl.edges), c("source", "target", "edgeType", "beta", "purity"))

}  # test.graphnelToCyjsJSON
#----------------------------------------------------------------------------------------------------
getTSSTable <- function()
{
   db.gtf <- dbConnect(PostgreSQL(), user= "trena", password="trena", dbname="gtf", host="whovian")
   query <- "select * from hg38human where moleculetype='gene' and gene_biotype='protein_coding'"
   tbl <- dbGetQuery(db.gtf, query) [, c("chr", "gene_name", "start", "endpos", "strand")]

} # getTSSTable
#------------------------------------------------------------------------------------------------------------------------
if(!exists("tbl.tss"))
    tbl.tss <- getTSSTable()
#------------------------------------------------------------------------------------------------------------------------
if(!interactive()) {
   context = init.context()
   socket = init.socket(context,"ZMQ_REP")
   bind.socket(socket,"tcp://*:5557")
   while(TRUE) {
      printf("top of receive/send loop")
      raw.message <- receive.string(socket)
      msg = fromJSON(raw.message)
      printf("cmd: %s", msg$cmd)
      print(msg)
      if(msg$cmd == "ping") {
          response <- list(cmd=msg$callack, status="result", callback="", payload="pong")
          }
      else if(msg$cmd == "upcase") {
          response <- list(cmd=msg$callack, status="result", callback="", payload=toupper(msg$payload))
          }
      else if(msg$cmd == "getTestNetwork"){
         infile <- file("vgfModel.json")
         graphModel <- fromJSON(readLines(infile))
         response <- list(cmd=msg$callback, status="result", callback="", payload=graphModel)
         }
      else if(msg$cmd == "createGeneModel"){
         print(1)
         targetGene <- msg$payload$targetGene;
         print(2)
         footprintRegion <- msg$payload$footprintRegion;
         print(3)
         tbl.gm <- createGeneModel(targetGene, footprintRegion)
         print(4)
         tbl.list <- list(tbl.gm)
         print(5)
         names(tbl.list) <- targetGene
         print(6)
         graph <- tableToFullGraph(tbl.list)
         print(7)
         graph.pos <- addGeneModelLayout(graph)
         #json <- graphnelToCyjsJSON(graph)
         json.string <- graphToJSON(graph.pos)
         print(8)
         response <- list(cmd=msg$callback, status="success", callback="", payload=json.string)
         }
      else {
         response <- list(cmd="handleUnrecognizedCommand", status="error", callback="", payload=toupper(raw.message))
         }
      send.raw.string(socket, toJSON(response))
      Sys.sleep(1)
      } # while (TRUE)

} # if !interactive()
#------------------------------------------------------------------------------------------------------------------------
#   tbl <- createModel(target.gene, promoter.shoulder=100,
#                      mtx.expression=mtx.rosmap,
#                      #mtx.expression=mtx.mayoTCX,
#                      #mtx.expression=mtx.rosmap,
#                      absolute.lasso.beta.min=0.2,
#                      randomForest.purity.min=3,
#                     absolute.expression.correlation.min=0.2)
#print(dim(tbl))
#rcy <- renderAsNetwork(tbl, target.gene)
#layoutByFootprintPosition(rcy)
#httpSetStyle(rcy, "style-purityControlsNodeSize.js")
#
#gjson <- getJSON(rcy)
#out <- file("vgfModel.json", "w")
#writeChar(gjson, con=out, eos=NULL)
#close(out)
#
