source("http://bioconductor.org/biocLite.R");
biocLite("devtools")
library(devtools)
install_github("Bioconductor-mirror/RCyjs")
library(RCyjs)
stopifnot(packageVersion("RCyjs") == "1.9.4")
stopifnot(packageVersion("graph") == "1.54.0")
stopifnot(packageVersion("httpuv") == "1.3.5")
stopifnot(packageVersion("BrowserViz") == "1.9.1")
stopifnot(packageVersion("jsonlite") == "1.5")

print(load("network_df_forPaul.RData"))
PORTS=9047:9097

rcy <- RCyjs(portRange=PORTS, quiet=FALSE);
setBrowserWindowTitle(rcy, "cory's tf network")

tbl <- olig.targets
tbl <- neuro.targets

tf.nodes <- unique(tbl$gene)
targetGene.nodes <- unique(tbl$target.gene)
length(intersect(tf.nodes, targetGene.nodes))

nodes <- unique(c(tf.nodes, targetGene.nodes))
g <- graphNEL(nodes, edgemode="directed")

nodeDataDefaults(g, attr = "label") <- "default node label"
nodeDataDefaults(g, attr = "type") <- "unspecified"
edgeDataDefaults(g, attr = "rank") <- 0

edgeDataDefaults(g, attr = "edgeType") <- "undefined"
edgeDataDefaults(g, attr = "pcaMax") <- 0

nodeData(g, nodes, "label") <- nodes
nodeData(g, tf.nodes, "type") <- "TF"
nodeData(g, targetGene.nodes, "type") <- "targetGene"

g <- addEdge(tbl$gene, tbl$target.gene, g)
edgeData(g, tbl$gene, tbl$target.gene, "edgeType") <- "regulates"
edgeData(g, tbl$gene, tbl$target.gene, "pcaMax") <- tbl$pcaMax
edgeData(g, tbl$gene, tbl$target.gene, "rank") <- tbl$Rank

setGraph(rcy, g)
httpSetStyle(rcy, "style.js")

# select all the TFs
# selectNodes(rcy, names(which(nodeData(g, attr="type") == "TF")))
layout(rcy, "breadthfirst")
