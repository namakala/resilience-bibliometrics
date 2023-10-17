# Functions to perform API query

genQuery <- function(type = "pubmed") {
  #' Generate Query
  #'
  #' Generate query term
  #'
  #' @param type Type of query to be generated
  #' @return Character object signifying what to query from the database
  res <- list(
    "pubmed" = "'Resilience, Psychological'[Mesh]"
  )

  return(res[[type]])
}

DBquery <- function(query, type = "pubmed", ...) {
  #' Database Query
  #'
  #' A wrapper function to perform queries against the database
  #'
  #' @param query Query to make, conveniently generated using `genQuery`
  #' @param type Type of database to query
  #'   - "pubmed" will use `pubmedR::pmApiRequest` to perform the query
  #' @param ... Parameters passed on to the function used to perform query
  #' @return An API response
  if (type == "pubmed") {
    res <- pubmedR::pmApiRequest(query, limit = Inf)
  }

  return(res)
}
