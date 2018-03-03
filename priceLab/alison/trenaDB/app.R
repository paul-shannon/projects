library(shiny)
library(DT)

load("placenta.draft.RData")
tbl.models <- placenta.rank
tfs <- c("any", sort(unique(tbl.models$gene)))
targetGenes <- c("any",sort(unique(tbl.models$target.gene)))

ui = fluidPage(
   titlePanel("query trena models (from placental tissue dnase footprints and expression)"),
   sidebarLayout(
      sidebarPanel(
         selectInput("tf", "Transcription Factor:", tfs, selectize=FALSE),
         selectInput("targetGene", "Target Gene:", targetGenes, selectize=FALSE),
         width=1),
      mainPanel(
         DTOutput("table")
         )
      ) # sidebarLayout
   ) # fluidPage

server = function(input, output) {
   output$table <- renderDT({
      tbl <- tbl.models
      if(input$tf != "any")
         tbl <- subset(tbl, gene == input$tf)
      if(input$targetGene != "any")
         tbl <- subset(tbl, target.gene == input$targetGene)
      tbl
      })
   }

shinyApp(ui=ui, server=server)




