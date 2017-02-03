library(jsonlite)
tbl <- read.table("one-chr6.ecp", header=TRUE, as.is=TRUE, sep="\t")
dim(tbl) # [1] 173172     20
max <- 1000
text = sprintf("data = %s", toJSON(tbl)) #[, c("EC1", "EC2", "EC3")]))
#text = sprintf("data = %s", toJSON(tbl[, c("EC1", "EC2", "EC3")]))
writeLines(text, "data.js")
