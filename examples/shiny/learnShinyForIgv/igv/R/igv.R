#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
#library(htmlwidgets)
#html_dependency_font_awesome <- function() {
#  htmlDependency(
#    "font-awesome",
#    "4.5.0",
#    src = rmarkdown_system_file("rmd/h/font-awesome-4.5.0"),
#    stylesheet = "css/font-awesome.min.css"
#  )
#}


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

#' Shiny bindings for igv
#'
#' Output and render functions for using igv within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a igv
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name igv-shiny
#'
#' @export
igvOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'igv', width, height, package = 'igv')
}

#' @rdname igv-shiny
#' @export
renderIgv <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, igvOutput, env, quoted = TRUE)
}
