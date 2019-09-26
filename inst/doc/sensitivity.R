## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE----------------------------------------------------------
#  library(nlrx)
#  # Windows default NetLogo installation path (adjust to your needs!):
#  netlogopath <- file.path("C:/Program Files/NetLogo 6.0.3")
#  modelpath <- file.path(netlogopath, "app/models/Sample Models/Biology/Wolf Sheep Predation.nlogo")
#  outpath <- file.path("C:/out")
#  # Unix default NetLogo installation path (adjust to your needs!):
#  netlogopath <- file.path("/home/NetLogo 6.0.3")
#  modelpath <- file.path(netlogopath, "app/models/Sample Models/Biology/Wolf Sheep Predation.nlogo")
#  outpath <- file.path("/home/out")
#  
#  nl <- nl(nlversion = "6.0.3",
#           nlpath = netlogopath,
#           modelpath = modelpath,
#           jvmmem = 1024)

## ----eval=FALSE----------------------------------------------------------
#  nl@experiment <- experiment(expname = "wolf-sheep-morris",
#                              outpath = outpath,
#                              repetition = 1,
#                              tickmetrics = "true",
#                              idsetup = "setup",
#                              idgo = "go",
#                              runtime = 500,
#                              evalticks = seq(300,500),
#                              metrics=c("count sheep", "count wolves", "count patches with [pcolor = green]"),
#                              variables = list("initial-number-sheep" = list(min=50, max=150, step=10, qfun="qunif"),
#                                               "initial-number-wolves" = list(min=50, max=150, step=10, qfun="qunif"),
#                                               "grass-regrowth-time" = list(min=0, max=100, step=10, qfun="qunif"),
#                                               "sheep-gain-from-food" = list(min=0, max=50, step=10, qfun="qunif"),
#                                               "wolf-gain-from-food" = list(min=0, max=100, step=10, qfun="qunif"),
#                                               "sheep-reproduce" = list(min=0, max=20, step=5, qfun="qunif"),
#                                               "wolf-reproduce" = list(min=0, max=20, step=5, qfun="qunif")),
#                              constants = list("model-version" = "\"sheep-wolves-grass\"",
#                                               "show-energy?" = "false"))

## ----eval=FALSE----------------------------------------------------------
#  nl@simdesign <- simdesign_morris(nl=nl,
#                                   morristype="oat",
#                                   morrislevels=4,
#                                   morrisr=1000,
#                                   morrisgridjump=2,
#                                   nseeds=5)

## ----eval=FALSE----------------------------------------------------------
#  library(future)
#  plan(multisession)
#  results <- run_nl_all(nl)

## ----eval=FALSE----------------------------------------------------------
#  nl@simdesign@simoutput <- results
#  saveRDS(nl, file.path(nl@experiment@outpath, "morris.rds"))

## ----eval=FALSE----------------------------------------------------------
#  morris <- analyze_nl(nl)

