library(shiny)
library(igvShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(
  includeScript("message-handler.js"),
  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")),
  sidebarLayout(
     sidebarPanel(
        actionButton("randomRoiButton", "Random roi"),
        hr(),
        width=2
        ),
     mainPanel(
        igvOutput('igv'),
        width=10
     )
     ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session) {

   observeEvent(input$randomRoiButton, {
      input$randomRoiButton
      tss <- 88883200
      shoulder <- as.integer(runif(1, 0, 10000))
      roi.string <- sprintf("chr5:%d-%d", tss - shoulder, tss + shoulder)
      session$sendCustomMessage(type="testmessage", message=(list(roi=roi.string)))
      })

  output$value <- renderPrint({ input$action })
  output$igv <- renderIgv(
    igv("hello shinyApp")
    )

} # server
#----------------------------------------------------------------------------------------------------
showRegion <- function(roi)
{

} # showRegion
#----------------------------------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
