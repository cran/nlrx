testthat::context("Class construction")
testthat::test_that("class objects are created with correct variables", {
  nl <- nl(
    nlversion = "6.0.2",
    nlpath = "C:/Program Files/NetLogo 6.0.2/",
    modelpath = "C:/WolfSheepPredation.nlogo",
    jvmmem = 1024
  )

  testthat::context("Class construction: nl")
  testthat::expect_match(getnl(nl, "nlversion"), "6.0.2")
  testthat::expect_match(getnl(nl, "nlpath"), "C:/Program Files/NetLogo 6.0.2/")
  testthat::expect_match(getnl(nl, "modelpath"), "C:/WolfSheepPredation.nlogo")
  testthat::expect_equal(getnl(nl, "jvmmem"), 1024)
  testthat::expect_match(class(getnl(nl, "experiment"))[1], "experiment")
  testthat::expect_match(class(getnl(nl, "simdesign"))[1], "simdesign")

  nl@experiment <- experiment(
    expname = "nlrxtest",
    outpath = "C:/out/",
    repetition = 1,
    tickmetrics = "true",
    idsetup = "setup",
    idgo = "go",
    idfinal = "final",
    runtime = 10,
    evalticks = seq(8, 10),
    stopcond = "ticks = 3",
    metrics = c("count sheep", "count wolves"),
    variables = list(
      "initial-number-sheep" = list(min = 50, max = 150, step = 10,
                                    qfun = "qunif"),
      "initial-number-wolves" = list(min = 50, max = 150, step = 10,
                                     qfun = "qunif")
    ),
    constants = list(
      "model-version" = "\"sheep-wolves-grass\"",
      "grass-regrowth-time" = 30,
      "sheep-gain-from-food" = 4,
      "wolf-gain-from-food" = 20,
      "sheep-reproduce" = 4,
      "wolf-reproduce" = 5,
      "show-energy?" = "false"
    )
  )

  testthat::context("Class construction: experiment")
  testthat::expect_match(getexp(nl, "expname"), "nlrxtest")
  testthat::expect_match(getexp(nl, "outpath"), "C:/out/")
  testthat::expect_equal(getexp(nl, "repetition"), 1)
  testthat::expect_match(getexp(nl, "tickmetrics"), "true")
  testthat::expect_match(getexp(nl, "idsetup"), "setup")
  testthat::expect_match(getexp(nl, "idgo"), "go")
  testthat::expect_match(getexp(nl, "idfinal"), "final")
  testthat::expect_equal(getexp(nl, "runtime"), 10)
  testthat::expect_equal(getexp(nl, "evalticks"), seq(8, 10))
  testthat::expect_match(getexp(nl, "metrics")[1], "count sheep")
  testthat::expect_match(getexp(nl, "metrics")[2], "count wolves")
  testthat::expect_match(names(getexp(nl, "variables"))[1],
                         "initial-number-sheep")
  testthat::expect_match(names(getexp(nl, "variables"))[2],
                         "initial-number-wolves")
  testthat::expect_equal(length(getexp(nl, "variables")[[1]]), 4)
  testthat::expect_equal(length(getexp(nl, "variables")[[2]]), 4)

  testthat::expect_match(names(getexp(nl, "constants"))[1],
                         "model-version")
  testthat::expect_match(names(getexp(nl, "constants"))[2],
                         "grass-regrowth-time")
  testthat::expect_match(names(getexp(nl, "constants"))[3],
                         "sheep-gain-from-food")
  testthat::expect_match(names(getexp(nl, "constants"))[4],
                         "wolf-gain-from-food")
  testthat::expect_match(names(getexp(nl, "constants"))[5],
                         "sheep-reproduce")
  testthat::expect_match(names(getexp(nl, "constants"))[6],
                         "wolf-reproduce")
  testthat::expect_match(names(getexp(nl, "constants"))[7],
                         "show-energy?")

  testthat::expect_match(getexp(nl, "constants")[[1]],
                         "\"sheep-wolves-grass\"")
  testthat::expect_equal(getexp(nl, "constants")[[2]], 30)
  testthat::expect_equal(getexp(nl, "constants")[[3]], 4)
  testthat::expect_equal(getexp(nl, "constants")[[4]], 20)
  testthat::expect_equal(getexp(nl, "constants")[[5]], 4)
  testthat::expect_equal(getexp(nl, "constants")[[6]], 5)
  testthat::expect_match(getexp(nl, "constants")[[7]], "false")


  testthat::context("Class construction: simdesign")
  # Testing validity of simdesign simple:
  nl@simdesign <- simdesign_simple(
    nl = nl,
    nseeds = 3
  )

  testthat::expect_match(getsim(nl, "simmethod"), "simple")
  testthat::expect_equal(nrow(getsim(nl, "siminput")), 1)
  testthat::expect_equal(length(getsim(nl, "simobject")), 0)
  testthat::expect_equal(length(getsim(nl, "simseeds")), 3)
  testthat::expect_equal(nrow(getsim(nl, "simoutput")), 0)

})
