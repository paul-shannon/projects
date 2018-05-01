library(shiny)
library(DT)
library(igvShiny)
library(htmlwidgets)
library(GenomicRanges)
#----------------------------------------------------------------------------------------------------
#library(MEF2C.data)
load("../enhancerModels.RData")
  # "tbl.model.enhancerAll.mdb"  "tbl.model.enhancerAll.tfc"
  # "tbl.motifs.enhancerAll.mdb" "tbl.motifs.enhancerAll.tfc"
  # "tbl.enhancer"
load("../SRP094910.mtx.RData")   # "mtx"
tbl.pheno <- read.table("../SRPCovariateData.tsv", sep="\t", as.is=TRUE, header=TRUE)
rownames(tbl.pheno) <- tbl.pheno$Sample_ID
tbl.pheno <- tbl.pheno[, -1]
addResourcePath("tmp", "tmp") # so the shiny webserver can see, and return track files for igv
#----------------------------------------------------------------------------------------------------
#currentTracks <- list()
currentFilters <- list()
currentShoulder <- 0
currentModel <- "model_cer"
filter.result <- list(fp=data.frame(), snp=data.frame(), fpClean=data.frame())

state <- new.env(parent=emptyenv())
state[["currentModel"]] <- tbl.model.enhancerAll.mdb
state[["optionalTracks"]] <- c()

#----------------------------------------------------------------------------------------------------
ui <- fluidPage(

  includeScript("message-handler.js"),
  tags$head(tags$link(rel = "stylesheet", type = "text/css",
                     href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")
     ),

  titlePanel("Explore FTL1 snps"),

  sidebarLayout(
     sidebarPanel(
        width=3,
        selectInput("geneModel", "Choose model:",
                    c("Enhancers with MotifDb TF mapping" = "Enhancers.MotifDb",
                      "Enhancers with TFClass TF mapping" = "Enhancers.TFClass")),

        sliderInput("snpShoulder",
                    "SNP shoulder",
                    value = 0,
                    min = 0,
                    max = 100),
        actionButton("showFLT1Button", "Show FLT1"),
        actionButton("showSNPsButton", "SNPs"),
        actionButton("showEnhancersButton", "Enhancers")
        ),

     mainPanel(
       tabsetPanel(type="tabs",
                   id="trenaTabs",
                   tabPanel(title="IGV",     value="igvTab",       igvShinyOutput('igvShiny')),
                   tabPanel(title="Summary", value="summaryTab",   verbatimTextOutput("summary")),
                   tabPanel(title="TRN",     value="snpTableTab",  DTOutput("geneModelTable")),
                   tabPanel(title="tf/target plot",  value="plotTab",      plotOutput("xyPlot", height=800))
                   )
       ) # mainPanel
    ) # sidebarLayout
  ) # fluidPage

#--------------------------------------------------------------------------------
server <- function(input, output, session) {

   session$sendCustomMessage(type="showGenomicRegion", message=(list(region="FLT1")))

    # define a reactive conductor. it returns a function, is
    # redefined with a change to dist or n
    # has reactive children  plot, summary, table, below, which mention it
    # thereby establishing the reactive chain.

   observeEvent(input$geneModel, {
      printf("geneModel event: %s", input$geneModel);
      })

   observeEvent(input$showFLT1Button, {
     roi <- "chr13:28,173,549-28,689,676"   # includes all enhancers and 2 snps
     session$sendCustomMessage(type="showGenomicRegion", message=(list(region=roi)))
     })

   observeEvent(input$showSNPsButton, {
     trackName <- "snp"
     optionalTracks <- state[["optionalTracks"]]
     printf("entering button toggle, optionalTracks: ")
     print(optionalTracks);
     if(trackName %in% optionalTracks){
        removeTrack(session, trackName)
        optionalTracks <- optionalTracks[-grep(trackName, optionalTracks)]
        }
     else{
        displayTrack(session, trackName)
        optionalTracks <- c(trackName, optionalTracks)
        }
      printf("--- updating optionalTracks: ")
      print(optionalTracks)
      state[["optionalTracks"]] <- optionalTracks
      })

   observeEvent(input$showEnhancersButton, {
     trackName <- "enhancers"
     optionalTracks <- state[["optionalTracks"]]
     printf("entering button toggle, optionalTracks: ")
     print(optionalTracks);
     if(trackName %in% optionalTracks){
        removeTrack(session, trackName)
        optionalTracks <- optionalTracks[-grep(trackName, optionalTracks)]
        }
     else{
        displayTrack(session, trackName)
        optionalTracks <- c(trackName, optionalTracks)
        }
      printf("--- updating optionalTracks: ")
      print(optionalTracks)
      state[["optionalTracks"]] <- optionalTracks
      })

   observeEvent(input$findSnpsInModelButton, {
      trena.model <- isolate(input$model.trn)
      filters <- isolate(input$filters)
      snpShoulder <- isolate(input$snpShoulder)
      filter.result <- applyFilters(session, filters, trena.model, snpShoulder)
      })

   observeEvent(input$snpShoulder, {
      currentShoulder <- input$snpShoulder
      })

   observeEvent(input$tracks, {
     trackNames <- isolate(input$tracks)
     printf("currentTracks: %s", paste(trackNames, collapse=","))
     #newTracks <- setdiff(trackNames, currentTracks)
     newTracks <-  trackNames
     printf("newTracks: %s", paste(newTracks, collapse=","))
     if(length(newTracks) > 0){
        displayTrack(session, newTracks)
        }
     currentTracks <<- sort(unique(unlist(c(currentTracks, newTracks))))
     })

   observeEvent(input$filters, {
      currentFilters <- input$filters
      print(paste(currentFilters, collapse=","))
      })

   observeEvent(input$model.trn, {
      currentModel <- input$model.trn
      print(paste(currentFilters, collapse=","))
      })

   observeEvent(input$roi, {
     currentValue = input$roi
     tss <- 88884466;   # get from MEF2C.data
     roi.string <- switch(currentValue,
                          tss_2kb = sprintf("chr5:%d-%d", tss-2000, tss+2000),
                          tss_5kb = sprintf("chr5:%d-%d", tss-5000, tss+5000),
                          studyRegion = "chr5:88391000-89322000")
     session$sendCustomMessage(type="roi", message=(list(roi=roi.string)))
     })

   observeEvent(input$geneModelTable_cell_clicked, {
      printf("--- input$geneModelTable_cell_clicked")
      selectedTableRow <- input$geneModelTable_row_last_clicked
      tbl.model <- state$currentModel
      tf <- tbl.model$gene[selectedTableRow]
      printf("table row clicked: %s", tf );
      })

   output$xyPlot = renderPlot(
       {#x <- input$geneModelTable_rows_selected
        print(" ---- renderPlot");
        #model.name <- input$geneModel;
        selectedTableRow <- input$geneModelTable_row_last_clicked
        tbl.model <- state$currentModel
        tf <- tbl.model$gene[selectedTableRow]
        printf("want an xyplot of %s vs. FLT1", tf)
        #tbl.model <- state$currentModel
        #tf <- tbl.model$gene[selectedTableRow]
        vec <- sample(1:100, 10)
        plot(vec, vec^2)
        })

  output$summary <- renderPrint({
    print(input$targetGene)
    print(input$roi)
    print(input$filters)
    print(input$snpShoulder)
    print(input$model.trn)
    })

   output$geneModelTable <- renderDT(
      {model.name <- input$geneModel;
       printf("    rendering DT, presumably because input$geneModel changes");
       selection="single"
       tbl.model <- switch(model.name,
          "Enhancers.TFClass" = tbl.model.enhancerAll.tfc,
          "Enhancers.MotifDb" = tbl.model.enhancerAll.mdb
          )
      tbl.model <- tbl.model[order(tbl.model$rfScore, decreasing=TRUE),]
      if(nrow(tbl.model) > 20)
         tbl.model <- tbl.model[1:20,]
      rownames(tbl.model) <- NULL
      state[["currentModel"]] <- tbl.model
      return(tbl.model)
      },
    selection = 'single',
    options=list(pageLength=25, dom="t"))

   output$igvShiny <- renderIgvShiny({
     igvShiny("hello shinyApp")
     })

  } # server

#----------------------------------------------------------------------------------------------------
calculateVisibleSNPs <- function(targetGene, roi, filters, snpShoulder)
{
   #return(sprintf("calculateVisibleSNPs(%s), %s, %s, %d", date(), targetGene, roi, snpShoulder))
   tbl.mayo.snps <- mef2c@misc.data$MAYO.eqtl.snps[, c("chrom", "start", "end", "score")]
   tbl.mayo.snps <- tbl.mayo.snps[order(tbl.mayo.snps$start, decreasing=FALSE),]

   tbl.igap.snps <- mef2c@misc.data[["IGAP.snpChip"]][, c("chrom", "start", "end", "score")]
   tbl.igap.snps <- tbl.igap.snps[order(tbl.igap.snps$start, decreasing=FALSE),]

   temp.filename <- sprintf("igvdata/tmp%d.bedGraph", as.integer(Sys.time()))
   write.table(tbl.igap.snps, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
   return(temp.filename)

} # calculateVisibleSNPs
#----------------------------------------------------------------------------------------------------
removeTrack <- function(session, trackName)
{
  session$sendCustomMessage(type="removeTrack", message=list(trackName=trackName))

} # removeTrack
#----------------------------------------------------------------------------------------------------
displayTrack <- function(session, trackName)
{
   if("snp" %in% trackName){
      tbl.snps <- data.frame(chrom=c("chr13", "chr13"),
                             start=c(28564472, 28653382),
                             end=c(28564472, 28653382),
                             name="rs4769613", "rs12050029",
                             stringsAsFactors=FALSE);

      temp.filename <- tempfile(tmpdir="./tmp", fileext=".bed")
      write.table(tbl.snps, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
      file.exists(temp.filename)
      session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName="snp",
                                              displayMode="EXPANDED",
                                              color="red",
                                              trackHeight=40)))
      } # snps

   if("enhancers" %in% trackName){
      load("../FTL1-enhancer.RData")
      tbl.enhancers <- ftl1.enhancer[, c("chrom", "start", "end")]
      temp.filename <- tempfile(tmpdir="./tmp", fileext=".bed")
      write.table(tbl.enhancers, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
      printf(" enhancers, custom message, displayBedTrack: %s", temp.filename);
      session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName="enhancers",
                                              color="black",
                                              displayMode="SQUISHED",
                                              trackHeight=40)))
      } # enhancers

   if("tss" %in% trackName) {
      tss <- mef2c@misc.data$TSS
      tbl.tss <- data.frame(chrom="chr5", start=tss, end=tss, stringsAsFactors=FALSE)
      temp.filename <- sprintf("igvdata/tmp%d.bed", as.integer(Sys.time()))
      write.table(tbl.tss, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
      session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName="TSS",
                                              color="blue",
                                              trackHeight=40)))
     } # tss

    if("dhs" %in% trackName){
      tbl.dhs <- mef2c@misc.data$tbl.dhs
      temp.filename <- sprintf("igvdata/tmp%d.bed", as.integer(Sys.time()))
      write.table(tbl.dhs, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
      session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName="DHS",
                                              color="darkGreen",
                                              trackHeight=40)))
      } # dhs

    if("fp" %in% trackName){
      roi <- list(chrom="chr5", start=88391000, end=89322000)
      tbl.fp <- getFootprints(mef2c, roi)[, c("chrom", "start", "end", "shortMotifName", "score")]
      temp.filename <- sprintf("igvdata/tmp%d.bed", as.integer(Sys.time()))
      write.table(tbl.fp, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
      session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName="Footprints",
                                              color="gray",
                                              trackHeight=40)))
      } # fp

    if("tfbs.model.1" %in% trackName){
      tbl.motifs <- mef2c@misc.data[["allDNA-jaspar2018-human-mouse-motifs"]]
      tfs <- getModels(mef2c)[["mef2c.cory.wgs.cer.tfClass"]]$gene[1:5]
      for(tf in tfs){
        tbl.tfbs <- get.tf.bindingSites(tf)
        temp.filename <- sprintf("igvdata/tmp%d.bed", as.integer(Sys.time()))
        write.table(tbl.tfbs, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
        session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName=tf,
                                              color="darkRed",
                                              trackHeight=40)))
        } # for tf
      } # tfbs.model.1

    if("tfbs.model.2" %in% trackName){
      tbl.motifs <- mef2c@misc.data[["allDNA-jaspar2018-human-mouse-motifs"]]
      tfs <- getModels(mef2c)[["mef2c.cory.wgs.tcx.tfClass"]]$gene[1:5]
      for(tf in tfs){
        tbl.tfbs <- get.tf.bindingSites(tf)
        temp.filename <- sprintf("igvdata/tmp%d.bed", as.integer(Sys.time()))
        write.table(tbl.tfbs, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
        session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName=tf,
                                              color="darkRed",
                                              trackHeight=40)))
        } # for tf
      } # tfbs.model.2

    if("tfbs.model.3" %in% trackName){
      tbl.motifs <- mef2c@misc.data[["allDNA-jaspar2018-human-mouse-motifs"]]
      tfs <- getModels(mef2c)[["mef2c.cory.wgs.ros.tfClass"]]$gene[1:5]
      for(tf in tfs){
        tbl.tfbs <- get.tf.bindingSites(tf)
        temp.filename <- sprintf("igvdata/tmp%d.bed", as.integer(Sys.time()))
        write.table(tbl.tfbs, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
        session$sendCustomMessage(type="displayBedTrack",
                                message=(list(filename=temp.filename,
                                              trackName=tf,
                                              color="darkRed",
                                              trackHeight=40)))
        } # for tf
      } # tfbs.model.3

} # displayTrack
#------------------------------------------------------------------------------------------------------------------------
# shinyApp(ui, server)
