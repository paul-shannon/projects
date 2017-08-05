# table2.R: analysis of
# "summary of stage 1, stage 2 and overall meta-analyses for sNPs reaching genome-wide significance after stages 1 and 2"
# Meta-analysis of 74,046 individuals identifies 11 new susceptibility loci for Alzheimer’s disease
# PMID: 24162737 PMCID: PMC3896259 DOI: 10.1038/ng.2802
#------------------------------------------------------------------------------------------------------------------------
tbl <- read.table("table2-cleaned.tsv", header=TRUE, sep="\t", as.is=TRUE)
