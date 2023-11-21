# Functions to perform text mining

tokenize <- function(bib, wordlist = NULL, ...) {
  #' Make Text Corpus
  #'
  #' Create a text corpus from the abstracts of extracted query results. The
  #' text is first tokenized into words, then stop words are removed.
  #'
  #' @param bib A bibliography data frame from exported query results
  #' @param wordlist Additional list of stop word to exclude
  #' @param ... Parameters to pass on to `tokenizeNgrams`
  #' @return A data frame containing DOI and tokenized abstract
  require("tidytext")

  abstract <- bib %>%
    subset(select = c(DI, AB)) %>%
    set_names(c("doi", "abstract")) %>%
    tibble::tibble()

  if (!is.null(wordlist)) {
    wordlist %<>% readLines()
    stopword  <-  c(wordlist, stop_words$word)
  } else {
    stopword  <-  stop_words$word
  }

  token <- tokenizeNgrams(abstract, stopword = stopword, ...)

  return(token)
}

tokenizeNgrams <- function(abstract, n, stopword = NULL) {
  #' Tokenize N-Grams
  #'
  #' A wrapper function for `tidytext::unnest_token` to formalize the switching
  #' mechanism of the `tokenize` function. This function takes any value of n >
  #' 0 and creates the logic for filtering the tokens.
  #'
  #' @param abstract A data frame containing DOI and abstract
  #' @param n The number of n-grams token to be generated
  #' @param stopword A character vector signifying which stop words to exclude
  #' @return A data frame containing DOI and tokenized words
  require("tidytext")

  token <- abstract %>%
    unnest_tokens(input = "abstract", output = "word", token = "ngrams", n = n) %>%
    subset(!is.na(.$word))

  tokens <- token %>%
    tidyr::separate(word, paste0("word", 1:n), sep = " ")

  if (!is.null(stopword)) {
    filter <- sprintf("tokens$word%s %%in%% stopword", 1:n) %>%
      paste(collapse = " | ") %>%
      {eval(parse(text = .))}
  } else {
    filter <- FALSE # Will return all entries if no stopword is used
  }

  token_filtered <- tokens %>% subset(!filter)

  combined_token <- paste0("token_filtered$word", 1:n) %>%
    paste(collapse = ", ") %>%
    {sprintf("paste(%s)", .)} %>%
    {eval(parse(text = .))}

  token_clean <- token_filtered %>%
    inset2("word", value = combined_token) %>%
    subset(select = c("doi", "word"))

  return(token_clean)

}

countToken <- function(token, summarize = TRUE) {
  #' Count Tokenize Words
  #'
  #' Count words from tokenized data frame. This function will taken output
  #' from `tokenize` function as an input.
  #'
  #' @param token A data frame containing DOI and tokenized words
  #' @param summarize Whether to return a summary across all abstracts (`TRUE`) or count
  #' the token per abstract (`FALSE`)
  #' @return A data frame of token counts

  if (summarize) {
    token_count <- token %>%
      dplyr::count(word, sort = TRUE)
  } else {
    token_count <- token %>%
      dplyr::count(doi, word, sort = TRUE)
  }

  return(token_count)
}

getTokenStat <- function(token, summarize = TRUE) {
  #' Calculate Token Statistics
  #'
  #' Calculate the TF-IDF statistics from the token counts. TF-IDF is the
  #' multiplication between term frequency (TF) and inverse document frequency
  #' (IDF), which signifies the importance of a particular token within and
  #' across documents. IDF decreases the weight of commonly-used words
  #' and increases the weight of not commonly-used words.
  #'
  #' @param token A data frame containing DOI and tokenized words
  #' @param summarize Whether to return a summary across all token (`TRUE`) or
  #' provide TF/IDF value per abstract (`FALSE`)
  #' @return A data frame containing TF, IDF, and TF-IDF values
  token_stat <- token %>%
    countToken(summarize = FALSE) %>%
    tidytext::bind_tf_idf(term = "word", document = "doi", n = "n")

  if (summarize) {
    token_stat %<>%
      dplyr::group_by(word) %>%
      dplyr::summarize(
        "n"      = sum(n),
        "tf"     = mean(tf, na.rm = TRUE),
        "tf_idf" = mean(tf_idf, na.rm = TRUE)
      )
  }

  token_stat %<>% {.[order(.$n, .$tf_idf, decreasing = TRUE), ]}

  return(token_stat)
}

mkDocMatrix <- function(token, bib = NULL) {
  #' Make Document Matrix
  #'
  #' Create a document feature matrix (DFM) natively supported by the
  #' `quanteda` package. The DFM object is intended to use for topic modelling
  #' using the `stm` package.
  #'
  #' @param token A data frame containing DOI and tokenized abstract
  #' @param bib A bibliography data frame from exported query results
  #' @return A document feature matrix object for topic modelling
  tbl <- countToken(token, summarize = FALSE)
  dfm <- tidytext::cast_dfm(tbl, document = "doi", term = "word", value = "n")

  if (!is.null(bib)) {
    quanteda::meta(dfm, "title")    <- bib$TI
    quanteda::meta(dfm, "keywords") <- bib$DE
    quanteda::meta(dfm, "source")   <- bib$SO
  }

  return(dfm)
}
