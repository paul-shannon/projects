igv <- function(message, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    message = message
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'igv',
    x,
    width = width,
    height = height,
    package = 'igv',
    elementId = elementId,
    htmlwidgets::sizingPolicy(padding = 50, browser.fill = TRUE, browser.defaultHeight=1500))
    #sizingPolicy(viewer.suppress = TRUE,
    #         knitr.figure = FALSE,
    #         browser.fill = TRUE,
    #         browser.padding = 75,
    #         knitr.defaultWidth = 800,
    #         knitr.defaultHeight = 500)
    #)
} # igv ctor

#----------------------------------------------------------------------------------------------------
igvOutput <- function(outputId, width = '100%', height = '400px')
{
  htmlwidgets::shinyWidgetOutput(outputId, 'igv', width, height, package = 'igv')
}
#----------------------------------------------------------------------------------------------------
renderIgv <- function(expr, env = parent.frame(), quoted = FALSE)
{
   if (!quoted){
     expr <- substitute(expr)
     } # force quoted

  htmlwidgets::shinyRenderWidget(expr, igvOutput, env, quoted = TRUE)

}
#----------------------------------------------------------------------------------------------------
showRegion <- function(id, roiString, options)
{
   message <- list(id=id, roiString=roiString)
   if(!missing(options))
      message['options'] <- options

   session <- shiny::getDefaultReactiveDomain()

   session$sendCustomMessage("timevis:setWindow", message)

} # showRegion
#----------------------------------------------------------------------------------------------------
