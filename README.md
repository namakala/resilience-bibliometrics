
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

renv 1.0.0 was loaded from project library, but this project is
configured to use renv 1.0.3. - Use `renv::record("renv@1.0.0")` to
record renv 1.0.0 in the lockfile. - Use
`renv::restore(packages = "renv")` to install renv 1.0.3 into the
project library. Please note that our software is open source and
available for use, distributed under the MIT license. When it is used in
a publication, we ask that authors properly cite the following
reference:

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
    x5b3426b4c7fa7dbc([""Started""]):::started --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- x7420bd9270f8d27d([""Up to date""]):::uptodate
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    xb2d44098e9dbb607(["bibs"]):::outdated --> x2f7ce3a74217c3eb(["bib"]):::outdated
    x2f7ce3a74217c3eb(["bib"]):::outdated --> x5d0137cf25dee142(["analyzed_bib"]):::outdated
    xffb09e21cb2bb0ec>"readBib"]:::uptodate --> xb2d44098e9dbb607(["bibs"]):::outdated
    xc5a9e5584c3f223f{{"ref"}}:::uptodate --> xb2d44098e9dbb607(["bibs"]):::outdated
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    xccdeb963b10f414c>"genQuery"]:::uptodate --> xccdeb963b10f414c>"genQuery"]:::uptodate
    x2d15849e3198e8d1{{"pkgs"}}:::uptodate --> x2d15849e3198e8d1{{"pkgs"}}:::uptodate
    xcc1ff618dac8ab74>"DBquery"]:::uptodate --> xcc1ff618dac8ab74>"DBquery"]:::uptodate
    x22b0201614333ef4{{"fun"}}:::uptodate --> x22b0201614333ef4{{"fun"}}:::uptodate
  end
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 9 stroke-width:0px;
  linkStyle 10 stroke-width:0px;
  linkStyle 11 stroke-width:0px;
  linkStyle 12 stroke-width:0px;
  linkStyle 13 stroke-width:0px;
```
