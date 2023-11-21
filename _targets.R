# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "bibliometrix", "crew")
sapply(pkgs, library, character.only = TRUE)

# List all references
ref <- list.files(
    "data/raw", recursive = TRUE, full.names = TRUE, pattern = "*.(csv|txt|bib)"
  ) %>%
  set_names(gsub(x = ., ".*/|\\..+", ""))

# Source all functions
fun <- list.files("src/R", recursive = TRUE, full.names = TRUE, pattern = "*.R") %>%
  sapply(source)

# Set option for targets
tar_option_set(
  packages   = pkgs,
  error      = "continue",
  memory     = "transient",
  controller = crew_controller_local(worker = 4),
  storage    = "worker",
  retrieval  = "worker",
  garbage_collection = TRUE
)

# Analysis pipeline
list(

  # Read exported dataset
  tar_target(bibs, readBib(ref)),
  tar_target(bib,  mergeBib(bibs)),

  # Perform bibliometrics analysis
  tar_target(analyzed_bib, bibliometrix::biblioAnalysis(bib)),

  # Reference data from WoS for network analysis
  tar_target(sub_bib, bib %>% subset(.$DB == "ISI")),

  # Extract the network of articles
  tar_map(
    unlist = FALSE,
    values = tibble::tibble(
      "analysis" = c("collaboration", "co-occurrences", "co-citation", "coupling"),
      "network"  = c("authors", "keywords", "references", "sources")
    ),
    tar_target(network_bib, mkNetwork(sub_bib, analysis = analysis, network = network))
  ),

  # Tokenize the abstract into unigram, bigram, and trigram
  tar_map(
    unlist = FALSE,
    values = tibble::tibble("n" = (1:3)),
    tar_target(token, tokenize(bib, wordlist = "data/ref/awl.txt", n = n)),
    tar_target(token_count, countToken(token)),
    tar_target(token_stat,  getTokenStat(token))
  ),

  # Create document-feature matrices
  tar_map(
    unlist = FALSE,
    values = tibble::tibble(token = rlang::syms(paste("token", 1:3, sep = "_"))),
    tar_target(dfm, mkDocMatrix(token, bib))
  ),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
