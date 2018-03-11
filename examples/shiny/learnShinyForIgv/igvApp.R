library(shiny)
library(igv)
library(htmlwidgets)

igvOutput <- function(outputId, width = "100%", height = "400px") {
  shinyWidgetOutput(outputId, "igv", width, height, package = "igv")
}

renderIgv <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, igvOutput, env, quoted = TRUE)
}

ui = shinyUI(fluidPage(
  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")
    ),
  checkboxInput("drawEdges", "Draw Edges", value = TRUE),
  checkboxInput("drawNodes", "Draw Nodes", value = TRUE),
  igvOutput('igv')
))

server = function(input, output) {
  output$igv <- renderIgv(
    igv("hello shinyApp")
  )
}

shinyApp(ui = ui, server = server)
