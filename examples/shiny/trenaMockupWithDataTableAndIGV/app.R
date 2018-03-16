library(shiny)
library(DT)
library(igv)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
library(MEF2C.data)
mef2c <- MEF2C.data()
addResourcePath("igvdata", "igvdata")
#----------------------------------------------------------------------------------------------------
ui <- fluidPage(

  includeScript("message-handler.js"),
  tags$head(tags$link(rel = "stylesheet", type = "text/css",
                     href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")
     ),

  titlePanel("Evaluate IGAP eQTLs"),

  sidebarLayout(
     sidebarPanel(
        width=3,
        selectInput("targetGene", "Target gene:",
                    c("MEF2C" = "MEF2C",
                      "TREM2" = "TREM2")),

        radioButtons("roi", "Genomic Region of Interest:",
                     c("Set Manually" = "manualSelection",
                       "TSS +/- 2kb" = "tss_2kb",
                       "TSS +/- 5kb" = "tss_5kb",
                       "Study region" = "studyRegion")),
        br(),

        radioButtons("motifTfMapping", "Map Motifs to TFs Using",
                     c("MotifDb (parsimonious)" = "motifdb",
                       "TFClass (expansive)" = "tfclass",
                       "Both" = "both")),
        br(),

        checkboxGroupInput("filters", "Filters - one or more",
                           c("None" = "noFilters",
                             "Enhancers" = "enhancers",
                             "Footprints" = "footprints",
                             "Model 1" = "model_1",
                             "Model 2" = "model_2",
                             "Model 3" = "model_3"),
                             "noFilters"),

        sliderInput("snpShoulder",
                    "SNP shoulder", #"SNP shoulder (upstream and down):",
                    value = 0,
                    min = 0,
                    max = 100),
        actionButton("showSNPsButton", "Find intersecting SNPs")
        ),
     mainPanel(
       tabsetPanel(type="tabs",
                   id="trenaTabs",
                   tabPanel(title="IGV",     value="igvTab",       igvOutput('igv')),
                   tabPanel(title="Summary", value="summaryTab",   verbatimTextOutput("summary")),
                   tabPanel(title="SNPs",    value="snpTableTab",  DTOutput("snpSummaryTable")),
                   tabPanel(title="debug",   value="debugTab",     verbatimTextOutput("debug"))
                   )
       ) # mainPanel
    ) # sidebarLayout
  ) # fluidPage

#--------------------------------------------------------------------------------
server <- function(input, output, session) {

    # define a reactive conductor. it returns a function, is
    # redefined with a change to dist or n
    # has reactive children  plot, summary, table, below, which mention it
    # thereby establishing the reactive chain.

   observeEvent(input$showSNPsButton, {
      #updateTabsetPanel(session, "trenaTabs", selected="debugTab")
      temp.filename <- calculateVisibleSNPs(isolate(input$targetGene),
                                     isolate(input$roi),
                                     isolate(input$filters),
                                     isolate(input$snpShoulder))
     #temp.filename <- "tmp1521154368.bedGraph"
     session$sendCustomMessage(type="displaySnps", message=(list(filename=temp.filename)))
     #session$sendCustomMessage(type="roi", message=(list(roi="TREM2")))
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


  output$summary <- renderPrint({
    print(input$targetGene)
    print(input$roi)
    print(input$filters)
    print(input$snpShoulder)
    })

   output$snpSummaryTable <- renderDT({
     tbl <- mtcars
     return(tbl)
     })

   output$igv <- renderIgv({
     igv("hello shinyApp")
     })

  } # server

#--------------------------------------------------------------------------------
calculateVisibleSNPs <- function(targetGene, roi, filters, snpShoulder)
{
   #return(sprintf("calculateVisibleSNPs(%s), %s, %s, %d", date(), targetGene, roi, snpShoulder))
   tbl.snps <- mef2c@misc.data$MAYO.eqtl.snps[, c("chrom", "start", "end", "score", "name")]
   temp.filename <- sprintf("igvdata/tmp%d.bedGraph", as.integer(Sys.time()))
   write.table(tbl.snps, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE, file=temp.filename)
   return(temp.filename)

} # calculateVisibleSNPs
#--------------------------------------------------------------------------------
shinyApp(ui, server)
