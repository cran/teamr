#' Create a \code{connector_card} Structure With \code{teamr}
#'
#' @description \code{connector_card} is at the very heart of the \code{teamr} package.
#'
#' @details Assemble \code{connector_card} objects into a \code{connector_card}
#' structure and use the methods to append, modify or send your card to the webhook specified.
#'
#' @docType class
#' @importFrom R6 R6Class
#'
#' @section Methods:
#'
#' \describe{
#'   \item{\code{connector_card$new(hookurl, proxies, http_timeout)}}{Creates a new \code{connector_card}.}
#'   \item{\code{text(mtext)}}{Change the \code{text} field of the card}
#'   \item{\code{title(mtitle)}}{Change the \code{title} field of the card}
#'   \item{\code{summary(msummary)}}{Change the \code{summary} field of the card.}
#'   \item{\code{color(mcolor)}}{Change the default theme color.}
#'   \item{\code{add_link_button(btext, burl)}}{Add button with links.}
#'   \item{\code{newhook(nurl)}}{Change webhook address.}
#'   \item{\code{print()}}{Print out the current hookurl and payload}
#'   \item{\code{send()}}{Send \code{connector_card} to specified Microsoft Teams incomeing webhook URL.}
#' }
#'
#' @section Properties:
#'
#' \describe{
#'  \item{\code{hookurl}}{Microsoft Teams incoming webhooks url.}
#'  \item{\code{payload}}{R list of payloads(will be parsed into json)\link[httr]{POST}}
#'  \item{\code{proxies}}{Proxy objects from \link[httr]{use_proxy}}
#'  \item{\code{http_timeout}}{Timeout of the HTTP request. Default to 3 seconds.\link[httr]{timeout}}
#' }
#'
#' @usage # cc <- connector_card$new("https://outlook.office.com.....")
#'
#' @examples
#' \dontrun{
#' library(teamr)
#'
#' cc <- connector_card$new(hookurl = "https://outlook.office.com/webhook/...")
#' #' cc$text("Of on affixed civilly moments promise explain")
#' cc$title("This is a title")
#' cc$summary("This is a summary")
#' cc$add_link_button("This is the button Text", "https://github.com/wwwjk366/teamr")
#' cc$color("#008000")
#' cc$print()
#' cc$send()
#' }
#'
#' @export
#' @format An \code{\link{R6Class}} generator object

connector_card <- R6Class("connector_card", list(
  payload = list(),
  hookurl = NULL,
  proxies = NULL,
  http_timeout = NULL,

  initialize = function(hookurl, proxies=NULL, http_timeout = httr::timeout(3)) {
    self$hookurl <- hookurl
    if(!is.null(proxies)) self$proxies <- proxies
    self$http_timeout <- http_timeout
  },

  print = function(...) {
    cat("Card: \n")
    cat("  hookurl: ", self$hookurl, "\n", sep = "")
    cat("  payload:  ", jsonlite::toJSON(self$payload,auto_unbox = TRUE),  "\n", sep = "")
    invisible(self)
  },

  text = function(mtext){
    self$payload$text <- mtext
  },

  title = function(mtitle){
    self$payload$title <- mtitle
  },

  summary = function(msummary){
    self$payload$summary <- msummary
  },

  color = function(mcolor){
    self$payload$themeColor <- mcolor
  },

  add_link_button = function(btext, burl){

    if(!exists('potentialAction', where=self$payload)) self$payload$potentialAction = list()

    thisbutton = list(
      `@context` = "http://schema.org",
      `@type` = "ViewAction",
      name = btext,
      target = list(burl)
      )

    self$payload$potentialAction <- append(self$payload$potentialAction,list(thisbutton))

   },

  new_hook = function(nurl){
    self$hookurl = nurl
  },

  add_section = function(new_section){

    if(!exists('sections', where=self$payload)) self$payload$sections = list()

    self$payload$sections <- append(self$payload$sections, list(new_section$dump()))

  },

  add_potential_action = function(new_paction){

    if(!exists('potentialAction', where=self$payload)) self$payload$potentialAction = list()

    self$payload$potentialAction <- append(self$payload$potentialAction, list(new_paction$dump()))

  },


  send = function(){
    res <- httr::POST(
      url = self$hookurl,
      httr::add_headers("Content-Type"="application/json"),
      body = self$payload,
      use_proxy = self$proxies,
      timeout = self$http_timeout,
      encode = 'json'
      )

    if(res$status_code == 200) return(TRUE)
    else return(res)

    }
))
