# Functions to perform text mining

tokenize <- function(bib, mode = "unigram" wordlist = NULL) {
  #' Make Text Corpus
  #'
  #' Create a text corpus from the abstracts of extracted query results. The
  #' text is first tokenized into words, then stop words are removed.
  #'
  #' @param bib A bibliography data frame from exported query results
  #' @param wordlist Additional list of stop word to exclude
  #' @return A tidy data frame of tokenized abstracts
  require("tidytext")

  abstract <- bib %>%
    subset(select = c(DI, AB)) %>%
    set_names(c("doi", "abstract")) %>%
    tibble::tibble()

  token <- abstract %>%
    unnest_tokens(input = "abstract", output = "word")

  if (!is.null(wordlist)) {
    wordlist %<>% readLines() %>% {tibble::tibble(word = .)}
    stopword  <-  c(wordlist, stop_words$word)
  } else {
    stopword  <-  stop_words$word
  }

  token %<>% subset(!{.$words %in% stopword})

  return(token)
}

bib %>%
  #head() %>%
  #mkCorpus()
  tokenize(wordlist = "data/ref/awl.txt") %>%
  dplyr::count(word, sort = TRUE) %>%
  head(50) %>%
  data.frame()
