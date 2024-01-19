
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

Please note that our software is open source and available for use,
distributed under the MIT license. When it is used in a publication, we
ask that authors properly cite the following reference:

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
    x5b3426b4c7fa7dbc([""Started""]):::started --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- x70a5fa6bea6f298d[""Pattern""]:::none
    x70a5fa6bea6f298d[""Pattern""]:::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> xd5f458da9fb5a730>"mapTheme"]:::uptodate
    x9f4ef3011fe80273>"regularize"]:::uptodate --> x526ae069d8cfaac5>"getTheme"]:::uptodate
    xe427ebfaffa48850>"getGraph"]:::uptodate --> x3fb1b27e75a74c3b>"vizNetwork"]:::uptodate
    x8c84eb080ccbef92>"countToken"]:::uptodate --> x5b3deeac8d9d74fb>"getTokenStat"]:::uptodate
    x8c84eb080ccbef92>"countToken"]:::uptodate --> xc93041fcb624a462>"mkDocMatrix"]:::uptodate
    x2e3537559af5fbf8>"dedup"]:::uptodate --> x9e9a67411fa60786>"mergeBib"]:::uptodate
    x9d671fe3c715bf64>"flatten"]:::uptodate --> x82e62d618bc88e7e>"getLabel"]:::uptodate
    xe55316a1f7b4fae4>"tokenizeNgrams"]:::uptodate --> x86247b0b8f4cd373>"tokenize"]:::uptodate
    x939ce327f826a4c8>"augToBib"]:::uptodate --> x1a91335926f4a99e>"augmentBib"]:::uptodate
    x82fe2bb8b38bd06c>"mergeByDOI"]:::uptodate --> x939ce327f826a4c8>"augToBib"]:::uptodate
    x5b3deeac8d9d74fb>"getTokenStat"]:::uptodate --> xcaaf7c7bd8e35ab0(["token_stat_1"]):::uptodate
    x3115d41a9a868779(["token_1"]):::uptodate --> xcaaf7c7bd8e35ab0(["token_stat_1"]):::uptodate
    x5cdbbaf8a1244604>"getTopic"]:::uptodate --> xa8e53da9537b8a4e(["topic_doc_1"]):::uptodate
    xc8082656a8ada16b(["optim_param_1"]):::uptodate --> xa8e53da9537b8a4e(["topic_doc_1"]):::uptodate
    xd0367a1e5446b6a3["stm_1"]:::uptodate --> xa8e53da9537b8a4e(["topic_doc_1"]):::uptodate
    x5b3deeac8d9d74fb>"getTokenStat"]:::uptodate --> x4278c1afaa4bd567(["token_stat_2"]):::uptodate
    xe379b3a87aa6402a(["token_2"]):::uptodate --> x4278c1afaa4bd567(["token_stat_2"]):::uptodate
    x5cdbbaf8a1244604>"getTopic"]:::uptodate --> xa5a741489892d4d7(["topic_doc_2"]):::uptodate
    x6cb5dee127f58742(["optim_param_2"]):::uptodate --> xa5a741489892d4d7(["topic_doc_2"]):::uptodate
    x5a1898d7b5099422["stm_2"]:::uptodate --> xa5a741489892d4d7(["topic_doc_2"]):::uptodate
    x5b3deeac8d9d74fb>"getTokenStat"]:::uptodate --> x4c26d0b91e560ca7(["token_stat_3"]):::uptodate
    xf1bba0d245da2dfd(["token_3"]):::uptodate --> x4c26d0b91e560ca7(["token_stat_3"]):::uptodate
    x5cdbbaf8a1244604>"getTopic"]:::uptodate --> x4fc9e1ae9b49ea3c(["topic_doc_3"]):::uptodate
    xa61118f41413bb66(["optim_param_3"]):::uptodate --> x4fc9e1ae9b49ea3c(["topic_doc_3"]):::uptodate
    xac8d14645b350239["stm_3"]:::uptodate --> x4fc9e1ae9b49ea3c(["topic_doc_3"]):::uptodate
    xffb09e21cb2bb0ec>"readBib"]:::uptodate --> xb2d44098e9dbb607(["bibs"]):::uptodate
    xc5a9e5584c3f223f{{"ref"}}:::uptodate --> xb2d44098e9dbb607(["bibs"]):::uptodate
    x7eb08bfa4d5ee377["eval_summaries_1"]:::uptodate --> xda0a1b408497d7ac(["eval_summary_1"]):::uptodate
    x8c84eb080ccbef92>"countToken"]:::uptodate --> x0a25155295475de3(["token_count_1"]):::uptodate
    x3115d41a9a868779(["token_1"]):::uptodate --> x0a25155295475de3(["token_count_1"]):::uptodate
    x14bc624547f154f2["eval_summaries_2"]:::uptodate --> xff30368e56172ec2(["eval_summary_2"]):::uptodate
    x8c84eb080ccbef92>"countToken"]:::uptodate --> x4a99a33f2cffd9a2(["token_count_2"]):::uptodate
    xe379b3a87aa6402a(["token_2"]):::uptodate --> x4a99a33f2cffd9a2(["token_count_2"]):::uptodate
    xa47e508563e85eac["eval_summaries_3"]:::uptodate --> x78ba4032e44c94dc(["eval_summary_3"]):::uptodate
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> xfb4fe9f78f06bedc(["net_bib_co.citation_references"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> xfb4fe9f78f06bedc(["net_bib_co.citation_references"]):::uptodate
    x8c84eb080ccbef92>"countToken"]:::uptodate --> x1bf731753ea8de12(["token_count_3"]):::uptodate
    xf1bba0d245da2dfd(["token_3"]):::uptodate --> x1bf731753ea8de12(["token_count_3"]):::uptodate
    x1a91335926f4a99e>"augmentBib"]:::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    xe87e1a2d13f75745(["token_flat_1"]):::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    xb5f69d5d79b5defc(["token_flat_2"]):::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    x61c15c5a638eedf9(["token_flat_3"]):::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    xa8e53da9537b8a4e(["topic_doc_1"]):::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    xa5a741489892d4d7(["topic_doc_2"]):::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    x4fc9e1ae9b49ea3c(["topic_doc_3"]):::uptodate --> x83d6705e1b12040d(["bib_aug"]):::uptodate
    x0b850f22018be657(["dfm_1"]):::uptodate --> x06a467991b80a4ae["eval_topic_1"]:::uptodate
    xf80f600a5a9c7261>"evalTopic"]:::uptodate --> x06a467991b80a4ae["eval_topic_1"]:::uptodate
    xd0367a1e5446b6a3["stm_1"]:::uptodate --> x06a467991b80a4ae["eval_topic_1"]:::uptodate
    xd5f458da9fb5a730>"mapTheme"]:::uptodate --> xd660345371dff399(["map_bib_topic1"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> xd660345371dff399(["map_bib_topic1"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> xf91a477ac7d89474(["topic_label_1"]):::uptodate
    xc8082656a8ada16b(["optim_param_1"]):::uptodate --> xf91a477ac7d89474(["topic_label_1"]):::uptodate
    xd0367a1e5446b6a3["stm_1"]:::uptodate --> xf91a477ac7d89474(["topic_label_1"]):::uptodate
    xda935d9cbc8f3b46(["dfm_2"]):::uptodate --> x85186046cac8f386["eval_topic_2"]:::uptodate
    xf80f600a5a9c7261>"evalTopic"]:::uptodate --> x85186046cac8f386["eval_topic_2"]:::uptodate
    x5a1898d7b5099422["stm_2"]:::uptodate --> x85186046cac8f386["eval_topic_2"]:::uptodate
    xd5f458da9fb5a730>"mapTheme"]:::uptodate --> xe5668e8da4c9625d(["map_bib_topic2"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> xe5668e8da4c9625d(["map_bib_topic2"]):::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x6c2900ba07fd8520(["topic_label_2"]):::uptodate
    x6cb5dee127f58742(["optim_param_2"]):::uptodate --> x6c2900ba07fd8520(["topic_label_2"]):::uptodate
    x5a1898d7b5099422["stm_2"]:::uptodate --> x6c2900ba07fd8520(["topic_label_2"]):::uptodate
    x8a4f23ffbaf15159(["dfm_3"]):::uptodate --> xf62445bb8a53abf2["eval_topic_3"]:::uptodate
    xf80f600a5a9c7261>"evalTopic"]:::uptodate --> xf62445bb8a53abf2["eval_topic_3"]:::uptodate
    xac8d14645b350239["stm_3"]:::uptodate --> xf62445bb8a53abf2["eval_topic_3"]:::uptodate
    x82e62d618bc88e7e>"getLabel"]:::uptodate --> x2472a4751ea45616(["topic_label_3"]):::uptodate
    xa61118f41413bb66(["optim_param_3"]):::uptodate --> x2472a4751ea45616(["topic_label_3"]):::uptodate
    xac8d14645b350239["stm_3"]:::uptodate --> x2472a4751ea45616(["topic_label_3"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> x5d0137cf25dee142(["analyzed_bib"]):::uptodate
    xd5f458da9fb5a730>"mapTheme"]:::uptodate --> x5de8759ab2810278(["map_bib_topic"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> x5de8759ab2810278(["map_bib_topic"]):::uptodate
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> x2ff661369c94fc41(["net_bib_co.occurrences_keywords"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> x2ff661369c94fc41(["net_bib_co.occurrences_keywords"]):::uptodate
    x76b58a7850052e79(["net_hist"]):::uptodate --> x13b32a6ce3fac82a(["net_hist_plt"]):::uptodate
    x83d6705e1b12040d(["bib_aug"]):::uptodate --> x1592aa0a5fd55f23(["sub_bib"]):::uptodate
    xe8106633484dc4fe>"mkNetwork"]:::uptodate --> xc21aeee6947f1d28(["net_bib_collaboration_authors"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> xc21aeee6947f1d28(["net_bib_collaboration_authors"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> x0b850f22018be657(["dfm_1"]):::uptodate
    xc93041fcb624a462>"mkDocMatrix"]:::uptodate --> x0b850f22018be657(["dfm_1"]):::uptodate
    x3115d41a9a868779(["token_1"]):::uptodate --> x0b850f22018be657(["dfm_1"]):::uptodate
    x5cdbbaf8a1244604>"getTopic"]:::uptodate --> x7fb410e8991d38d8(["topic_token_1"]):::uptodate
    xc8082656a8ada16b(["optim_param_1"]):::uptodate --> x7fb410e8991d38d8(["topic_token_1"]):::uptodate
    xd0367a1e5446b6a3["stm_1"]:::uptodate --> x7fb410e8991d38d8(["topic_token_1"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> xda935d9cbc8f3b46(["dfm_2"]):::uptodate
    xc93041fcb624a462>"mkDocMatrix"]:::uptodate --> xda935d9cbc8f3b46(["dfm_2"]):::uptodate
    xe379b3a87aa6402a(["token_2"]):::uptodate --> xda935d9cbc8f3b46(["dfm_2"]):::uptodate
    x5cdbbaf8a1244604>"getTopic"]:::uptodate --> x167056d2eacb1749(["topic_token_2"]):::uptodate
    x6cb5dee127f58742(["optim_param_2"]):::uptodate --> x167056d2eacb1749(["topic_token_2"]):::uptodate
    x5a1898d7b5099422["stm_2"]:::uptodate --> x167056d2eacb1749(["topic_token_2"]):::uptodate
    xb2d44098e9dbb607(["bibs"]):::uptodate --> x2f7ce3a74217c3eb(["bib"]):::uptodate
    x9e9a67411fa60786>"mergeBib"]:::uptodate --> x2f7ce3a74217c3eb(["bib"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> x8a4f23ffbaf15159(["dfm_3"]):::uptodate
    xc93041fcb624a462>"mkDocMatrix"]:::uptodate --> x8a4f23ffbaf15159(["dfm_3"]):::uptodate
    xf1bba0d245da2dfd(["token_3"]):::uptodate --> x8a4f23ffbaf15159(["dfm_3"]):::uptodate
    x5cdbbaf8a1244604>"getTopic"]:::uptodate --> xea54396647b46690(["topic_token_3"]):::uptodate
    xa61118f41413bb66(["optim_param_3"]):::uptodate --> xea54396647b46690(["topic_token_3"]):::uptodate
    xac8d14645b350239["stm_3"]:::uptodate --> xea54396647b46690(["topic_token_3"]):::uptodate
    x1592aa0a5fd55f23(["sub_bib"]):::uptodate --> x76b58a7850052e79(["net_hist"]):::uptodate
    x06a467991b80a4ae["eval_topic_1"]:::uptodate --> x7eb08bfa4d5ee377["eval_summaries_1"]:::uptodate
    xda0a1b408497d7ac(["eval_summary_1"]):::uptodate --> xc8082656a8ada16b(["optim_param_1"]):::uptodate
    x378eaef7eb720930>"selTopicParam"]:::uptodate --> xc8082656a8ada16b(["optim_param_1"]):::uptodate
    x85186046cac8f386["eval_topic_2"]:::uptodate --> x14bc624547f154f2["eval_summaries_2"]:::uptodate
    xff30368e56172ec2(["eval_summary_2"]):::uptodate --> x6cb5dee127f58742(["optim_param_2"]):::uptodate
    x378eaef7eb720930>"selTopicParam"]:::uptodate --> x6cb5dee127f58742(["optim_param_2"]):::uptodate
    xf62445bb8a53abf2["eval_topic_3"]:::uptodate --> xa47e508563e85eac["eval_summaries_3"]:::uptodate
    x78ba4032e44c94dc(["eval_summary_3"]):::uptodate --> xa61118f41413bb66(["optim_param_3"]):::uptodate
    x378eaef7eb720930>"selTopicParam"]:::uptodate --> xa61118f41413bb66(["optim_param_3"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> x3115d41a9a868779(["token_1"]):::uptodate
    x86247b0b8f4cd373>"tokenize"]:::uptodate --> x3115d41a9a868779(["token_1"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> xe379b3a87aa6402a(["token_2"]):::uptodate
    x86247b0b8f4cd373>"tokenize"]:::uptodate --> xe379b3a87aa6402a(["token_2"]):::uptodate
    x2f7ce3a74217c3eb(["bib"]):::uptodate --> xf1bba0d245da2dfd(["token_3"]):::uptodate
    x86247b0b8f4cd373>"tokenize"]:::uptodate --> xf1bba0d245da2dfd(["token_3"]):::uptodate
    x9d671fe3c715bf64>"flatten"]:::uptodate --> xe87e1a2d13f75745(["token_flat_1"]):::uptodate
    x3115d41a9a868779(["token_1"]):::uptodate --> xe87e1a2d13f75745(["token_flat_1"]):::uptodate
    x0b850f22018be657(["dfm_1"]):::uptodate --> xd0367a1e5446b6a3["stm_1"]:::uptodate
    xfc1752122b7f5302>"genTopic"]:::uptodate --> xd0367a1e5446b6a3["stm_1"]:::uptodate
    xee8868c11de4b9e2(["ntopic"]):::uptodate --> xd0367a1e5446b6a3["stm_1"]:::uptodate
    x6e87002190572330{{"seed"}}:::uptodate --> xd0367a1e5446b6a3["stm_1"]:::uptodate
    x9d671fe3c715bf64>"flatten"]:::uptodate --> xb5f69d5d79b5defc(["token_flat_2"]):::uptodate
    xe379b3a87aa6402a(["token_2"]):::uptodate --> xb5f69d5d79b5defc(["token_flat_2"]):::uptodate
    xda935d9cbc8f3b46(["dfm_2"]):::uptodate --> x5a1898d7b5099422["stm_2"]:::uptodate
    xfc1752122b7f5302>"genTopic"]:::uptodate --> x5a1898d7b5099422["stm_2"]:::uptodate
    xee8868c11de4b9e2(["ntopic"]):::uptodate --> x5a1898d7b5099422["stm_2"]:::uptodate
    x6e87002190572330{{"seed"}}:::uptodate --> x5a1898d7b5099422["stm_2"]:::uptodate
    x9d671fe3c715bf64>"flatten"]:::uptodate --> x61c15c5a638eedf9(["token_flat_3"]):::uptodate
    xf1bba0d245da2dfd(["token_3"]):::uptodate --> x61c15c5a638eedf9(["token_flat_3"]):::uptodate
    x8a4f23ffbaf15159(["dfm_3"]):::uptodate --> xac8d14645b350239["stm_3"]:::uptodate
    xfc1752122b7f5302>"genTopic"]:::uptodate --> xac8d14645b350239["stm_3"]:::uptodate
    xee8868c11de4b9e2(["ntopic"]):::uptodate --> xac8d14645b350239["stm_3"]:::uptodate
    x6e87002190572330{{"seed"}}:::uptodate --> xac8d14645b350239["stm_3"]:::uptodate
    xba77f89666b4cb20(["theme"]):::outdated --> xdcb7a04111d5c3fd(["theme_plt"]):::outdated
    x45d39a73e00e4fd3>"vizTheme"]:::uptodate --> xdcb7a04111d5c3fd(["theme_plt"]):::outdated
    xc21aeee6947f1d28(["net_bib_collaboration_authors"]):::uptodate --> x561017f6ea551642(["net_bib_plt"]):::uptodate
    x3fb1b27e75a74c3b>"vizNetwork"]:::uptodate --> x561017f6ea551642(["net_bib_plt"]):::uptodate
    x526ae069d8cfaac5>"getTheme"]:::uptodate --> xba77f89666b4cb20(["theme"]):::outdated
    xd660345371dff399(["map_bib_topic1"]):::uptodate --> xba77f89666b4cb20(["theme"]):::outdated
    xe5668e8da4c9625d(["map_bib_topic2"]):::uptodate --> xba77f89666b4cb20(["theme"]):::outdated
    xf91a477ac7d89474(["topic_label_1"]):::uptodate --> xba77f89666b4cb20(["theme"]):::outdated
    x6c2900ba07fd8520(["topic_label_2"]):::uptodate --> xba77f89666b4cb20(["theme"]):::outdated
    x6e52cb0f1668cc22(["readme"]):::started --> x6e52cb0f1668cc22(["readme"]):::started
    x2d15849e3198e8d1{{"pkgs"}}:::uptodate --> x2d15849e3198e8d1{{"pkgs"}}:::uptodate
    x22b0201614333ef4{{"fun"}}:::uptodate --> x22b0201614333ef4{{"fun"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef started stroke:#000000,color:#000000,fill:#DC863B;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 5 stroke-width:0px;
  linkStyle 146 stroke-width:0px;
  linkStyle 147 stroke-width:0px;
  linkStyle 148 stroke-width:0px;
```
