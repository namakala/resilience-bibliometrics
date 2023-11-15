# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "bibliometrix")
sapply(pkgs, library, character.only = TRUE)

# List all references
ref <- list.files(
    "data/raw", recursive = TRUE, full.names = TRUE, pattern = "*.(csv|txt|bib)"
  ) %>%
  set_names(gsub(x = ., ".*/|\\..+", ""))

# Source all functions
fun <- list.files("src/R", recursive = TRUE, full.names = TRUE, pattern = "*.R") %>%
  sapply(source)

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
  tar_target(net_auth, mkNetwork(sub_bib,    analysis = "collaboration",  network = "authors")),
  tar_target(net_keyword, mkNetwork(sub_bib, analysis = "co-occurrences", network = "keywords")),
  tar_target(net_ref, mkNetwork(sub_bib,     analysis = "co-citation",    network = "references")),
  tar_target(net_src, mkNetwork(sub_bib,     analysis = "coupling",       network = "sources")),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
