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

  # Perform bibliometrics analysis and create network of authors
  tar_target(analyzed_bib, bibliometrix::biblioAnalysis(bib)),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
