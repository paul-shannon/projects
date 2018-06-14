library(RUnit)
#------------------------------------------------------------------------------------------------------------------------
people <- c("jane", "joe", "george", "ann")
interaction.types <- c("data-help", "programming-help", "biology-help", "administrative-help")
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_generateRandomData()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
generateRandomData <- function(interaction.count, people, interaction.types)
{
     # pre-allocate a data.frame with the right number of rows
   tbl <- data.frame(a=vector("character", interaction.count),
                     b=vector("character", interaction.count),
                     type=vector("character", interaction.count),
                     startTime=vector("integer", interaction.count),
                     duration=vector("integer", interaction.count),
                     stringsAsFactors=FALSE)

   tbl$a <- sample(people, interaction.count, replace=TRUE)

   now <- as.integer(as.numeric(Sys.time()))
   for(i in seq_len(nrow(tbl))){
      this.person <- tbl$a[i]
      other.people <- people[-grep(this.person, people)]
      tbl$b[i] <- sample(other.people, 1)
      tbl$type[i] <- sample(interaction.types, 1)
      tbl$startTime[i] <- now + round(runif(n=1, min=1, max=60))
      tbl$duration[i] <- round(runif(n=1, min=1, max=90))
      }

     # tip: convert msec times to human readable:
     #    as.POSIXct(tbl$startTime[1], origin = "1970-01-01")  [1] "2018-06-14 12:22:47 PDT"

   return(tbl)

} # generateRandomData
#------------------------------------------------------------------------------------------------------------------------
test_generateRandomData <- function()
{
   printf("--- test_generateRandomData")
   tbl.1 <- generateRandomData(5, people, interaction.types)
   checkEquals(dim(tbl.1), c(5, 5))

   tbl.big <- generateRandomData(100, people, interaction.types)
   checkEquals(dim(tbl.big), c(100, 5))
     # make sure a != b
   checkTrue(all(apply(tbl.big, 1, function(row) row["a"] != row["b"])))

} # test_generateRandomData
#------------------------------------------------------------------------------------------------------------------------
