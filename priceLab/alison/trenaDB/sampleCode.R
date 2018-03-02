library(trena)
library(dplyr)
library(data.table)

# pull out the top TFs for a given target gene

getTarget <- function(trn, geneA)
{
  temp <- subset(trn, target.gene == geneA)
  temp[order(temp$pcaMax, decreasing=TRUE),]
}

# pull out the top targets for a given TF (without rank)
getTF <- function(trn, geneA)
{
  temp <- subset(trn, gene == geneA)
  temp[order(temp$pcaMax, decreasing=TRUE),]
}


print(load("placenta.draft.RData"))
placenta.rank<-unique(placenta.rank) #note: for some reason the matrix corey sent over has duplicated rows, need to remove for now

TFactors<-as.data.frame(table(placenta.rank$gene))
rownames(TFactors)<-TFactors$Var1


MyTF<-"SOX4"

CheckTF<-function(MyTF,TFactors){
check<-intersect(MyTF,rownames(TFactors))
if (length(check)<1) {
  print("Selected Gene is NOT a Transcription Factor in this model")
}
if (length(check)>1) {
  print("Selected Gene IS a Transcription Factor in this model")
}
}
CheckTF(MyTF,TFactors)

X<-getTF(placenta.rank,MyTF)
print(X)#Whole Outupt
print(X$target.gene)

##Module 2: Identify transcriptional regulators of your gene of interest

MyGene<-"BMP2"

X<-getTarget(placenta.rank,MyGene)
print(X)#Whole Outupt
print(X$gene)


