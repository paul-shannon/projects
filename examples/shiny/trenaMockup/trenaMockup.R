library(shiny)
#--------------------------------------------------------------------------------
ui <- fluidPage(
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
                   tabPanel(title="IGV",     value="igvTab",      verbatimTextOutput("igv")),
                   tabPanel(title="Summary", value="summaryTab",  verbatimTextOutput("summary")),
                   tabPanel(title="debug",   value="debugTab",    verbatimTextOutput("debug"))
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
      input$showSNPsButton
      updateTabsetPanel(session, "trenaTabs", selected="debugTab")
      result <- calculateVisibleSNPs(isolate(input$targetGene),
                                     isolate(input$roi),
                                     isolate(input$filters),
                                     isolate(input$snpShoulder))
      output$debug <- renderPrint({result})
      })

#   observe({
#      input$showSNPsButton
#      updateTabsetPanel(session, "trenaTabs", selected="debugTab")
#      result <- calculateVisibleSNPs(isolate(input$targetGene),
#                                     isolate(input$roi),
#                                     isolate(input$filters),
#                                     isolate(input$snpShoulder))
#      output$debug <- renderPrint({result})
#      })

  output$igv <- renderPrint({
    print(input$roi)
    }) # renderPlot

  output$summary <- renderPrint({
    print(input$targetGene)
    print(input$roi)
    print(input$filters)
    print(input$snpShoulder)
    })

  output$table <- renderTable({
    #d()
    })

  } # server

#--------------------------------------------------------------------------------
calculateVisibleSNPs <- function(targetGene, roi, filters, snpShoulder)
{
   return(sprintf("calculateVisibleSNPs(%s), %s, %s, %d", date(), targetGene, roi, snpShoulder))

} # calculateVisibleSNPs
#--------------------------------------------------------------------------------
shinyApp(ui, server)
