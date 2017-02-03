library(jsonlite)
tbl <- read.table("../earlyExampleWithMaxsData/one-chr6.ecp", header=TRUE, as.is=TRUE, sep="\t")
dim(tbl) # [1] 173172     20
max <- 100
text = sprintf("data = %s", toJSON(tbl[1:max,])) #[, c("EC1", "EC2", "EC3")]))
#text = sprintf("data = %s", toJSON(tbl[, c("EC1", "EC2", "EC3")]))
writeLines(text, "data.js")
