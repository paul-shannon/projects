library(shiny)
library(DT)
library(igvShiny)
library(htmlwidgets)
library(GenomicRanges)
#--------------------------------------------------------------------------------
load("../enhancerModels.RData")
#--------------------------------------------------------------------------------
ui <- fluidPage(

  titlePanel("Explore FTL1 snps"),

  sidebarLayout(
     sidebarPanel(
     selectInput("variable", "Variable:",
                 c("Cylinders" = "cyl",
                   "Transmission" = "am",
                   "Gears" = "gear"))
        ),
     mainPanel()
     )

) # fluidPage
#----------------------------------------------------------------------------------------------------
server <- function(input, output){

  #output$data <- renderTable({
  #    mtcars[, c("mpg", input$variable), drop = FALSE]
  #  }, rownames = TRUE)

}
#----------------------------------------------------------------------------------------------------
shinyApp(ui, server)
