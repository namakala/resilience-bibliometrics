
# Getting started

Most of the works in this repository, especially the `R` scripts, should
be directly reproducible. You’ll need
[`git`](https://git-scm.com/downloads),
[`R`](https://www.r-project.org/),
[`quarto`](https://quarto.org/docs/download/), and more conveniently
[RStudio IDE](https://posit.co/downloads/) installed and running well in
your system. You simply need to fork/clone this repository using RStudio
by following [this tutorial, start right away from
`Step 2`](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2).
Using terminal in linux/MacOS, you can issue the following command:

    quarto tools install tinytex

This command will install `tinytex` in your path, which is required to
compile quarto documents as latex/pdf. Afterwards, in your RStudio
command line, you can copy paste the following code to setup your
working directory:

    install.packages("renv") # Only need to run this step if `renv` is not installed

This step will install `renv` package, which will help you set up the
`R` environment. Please note that `renv` helps tracking, versioning, and
updating packages I used throughout the analysis.

    renv::restore()

This step will read `renv.lock` file and install required packages to
your local machine. When all packages loaded properly (make sure there’s
no error at all), you *have to* restart your R session. Then, you should
be able to proceed with:

    targets::tar_make()

This step will read `_targets.R` file, where I systematically draft all
of the analysis steps. Once it’s done running, you will find the
rendered document (either in `html` or `pdf`) inside the `draft`
directory.

# What’s this all about?

This is the analysis pipeline for conducting analysis in an umbrella
review. The complete flow can be viewed in the following `mermaid`
diagram:

- The project is out-of-sync – use `renv::status()` for details. During
  startup - Warning messages: 1: Setting LC_COLLATE failed, using “C” 2:
  Setting LC_TIME failed, using “C” 3: Setting LC_MESSAGES failed, using
  “C” 4: Setting LC_MONETARY failed, using “C” Please note that our
  software is open source and available for use, distributed under the
  MIT license. When it is used in a publication, we ask that authors
  properly cite the following reference:

Aria, M. & Cuccurullo, C. (2017) bibliometrix: An R-tool for
comprehensive science mapping analysis, Journal of Informetrics, 11(4),
pp 959-975, Elsevier.

Failure to properly cite the software is considered a violation of the
license.

For information and bug reports: - Take a look at
https://www.bibliometrix.org - Send an email to info@bibliometrix.org  
- Write a post on https://github.com/massimoaria/bibliometrix/issues

Help us to keep Bibliometrix and Biblioshiny free to download and use by
contributing with a small donation to support our research team
(https://bibliometrix.org/donate.html)

To start with the Biblioshiny app, please digit: biblioshiny()

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x5b3426b4c7fa7dbc([""Started""]):::started
    x5b3426b4c7fa7dbc([""Started""]):::started --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x2e3537559af5fbf8>"dedup"]:::uptodate --> x9e9a67411fa60786>"mergeBib"]:::uptodate
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> xd3f20a2f996e26ce(["network_bib_mkNetwork_co.occurrences_keywords"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> xd3f20a2f996e26ce(["network_bib_mkNetwork_co.occurrences_keywords"]):::uptodate
    xb2d44098e9dbb607(["bibs"]):::uptodate --> x2f7ce3a74217c3eb(["bib"]):::uptodate
    x9e9a67411fa60786>"mergeBib"]:::uptodate --> x2f7ce3a74217c3eb(["bib"]):::uptodate
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> xbdb58136cfeec83a(["network_bib_mkNetwork_collaboration_authors"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> xbdb58136cfeec83a(["network_bib_mkNetwork_collaboration_authors"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> x5d0137cf25dee142(["analyzed_bib"]):::uptodate
    xffb09e21cb2bb0ec>"readBib"]:::uptodate --> xb2d44098e9dbb607(["bibs"]):::uptodate
    xc5a9e5584c3f223f{{"ref"}}:::uptodate --> xb2d44098e9dbb607(["bibs"]):::uptodate
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> x1f29d4abcfe1d32a(["network_bib_mkNetwork_coupling_sources"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> x1f29d4abcfe1d32a(["network_bib_mkNetwork_coupling_sources"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> x1592aa0a5fd55f23(["sub_bib"]):::uptodate
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> x3d74a378a58dff6e(["network_bib_mkNetwork_co.citation_references"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> x3d74a378a58dff6e(["network_bib_mkNetwork_co.citation_references"]):::uptodate
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    x2d15849e3198e8d1{{"pkgs"}}:::uptodate --> x2d15849e3198e8d1{{"pkgs"}}:::uptodate
    x22b0201614333ef4{{"fun"}}:::uptodate --> x22b0201614333ef4{{"fun"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 19 stroke-width:0px;
  linkStyle 20 stroke-width:0px;
  linkStyle 21 stroke-width:0px;
```
