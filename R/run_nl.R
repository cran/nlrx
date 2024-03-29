

#' Execute all NetLogo simulations from a nl object
#'
#' @description Execute all NetLogo simulations from a nl object with a defined experiment and simdesign
#'
#' @param nl nl object
#' @param split number of parts the job should be split into
#' @param cleanup.csv TRUE/FALSE, if TRUE temporary created csv output files will be deleted after gathering results.
#' @param cleanup.xml TRUE/FALSE, if TRUE temporary created xml output files will be deleted after gathering results.
#' @param cleanup.bat TRUE/FALSE, if TRUE temporary created bat/sh output files will be deleted after gathering results.
#' @param writeRDS TRUE/FALSE, if TRUE, for each single simulation an rds file with the simulation results will be written to the defined outpath folder of the experiment within the nl object.
#' @return tibble with simulation output results
#' @details
#'
#' run_nl_all executes all simulations of the specified NetLogo model within the provided nl object.
#' The function loops over all random seeds and all rows of the siminput table of the simdesign of nl.
#' The loops are created by calling \link[furrr]{future_map_dfr}, which allows running the function either locally or on remote HPC machines.
#' The logical cleanup variables can be set to FALSE to preserve temporary generated output files (e.g. for debugging).
#' cleanup.csv deletes/keeps the temporary generated model output files from each run.
#' cleanup.xml deletes/keeps the temporary generated experiment xml files from each run.
#' cleanup.bat deletes/keeps the temporary generated batch/sh commandline files from each run.
#'
#' When using run_nl_all in a parallelized environment (e.g. by setting up a future plan using the future package),
#' the outer loop of this function (random seeds) creates jobs that are distributed to available cores of the current machine.
#' The inner loop (siminputrows) distributes simulation tasks to these cores.
#' However, it might be advantageous to split up large jobs into smaller jobs for example to reduce the total runtime of each job.
#' This can be done using the split parameter. If split is > 1 the siminput matrix is split into smaller parts.
#' Jobs are created for each combination of part and random seed.
#' If the split parameter is set such that the siminput matrix can not be splitted into equal parts, the procedure will stop and throw an error message.
#'
#' ### Debugging "Temporary simulation output file not found" error message:
#'
#' Whenever this error message appears it means that the simulation did not produce any output.
#' Two main reasons can lead to this problem, either the simulation did not even start or the simulation crashed during runtime.
#' Both can happen for several reasons and here are some hints for debugging this:
#' 1. Missing software:
#' Make sure that java is installed and available from the terminal (java -version).
#' Make sure that NetLogo is installed and available from the terminal.
#' 2. Wrong path definitions:
#' Make sure your nlpath points to a folder containing NetLogo.
#' Make sure your modelpath points to a *.nlogo model file.
#' Make sure that the nlversion within your nl object matches the NetLogo version of your nlpath.
#' Use the convenience function of nlrx for checking your nl object (print(nl), eval_variables_constants(nl)).
#' 3. Temporary files cleanup:
#' Due to automatic temp file cleanup on unix systems temporary output might be deleted.
#' Try reassigning the default temp folder for this R session (the unixtools package has a neat function).
#' 4. NetLogo runtime crashes:
#' It can happen that your NetLogo model started but failed to produce output because of a NetLogo runtime error.
#' Make sure your model is working correctly or track progress using print statements.
#' Sometimes the java virtual machine crashes due to memory constraints.
#'
#'
#' @examples
#' \dontrun{
#'
#' # Load nl object from test data:
#' nl <- nl_lhs
#'
#' # Execute all simulations from an nl object with properly attached simdesign.
#' results <- run_nl_all(nl)
#'
#' # Run in parallel on local machine:
#' library(future)
#' plan(multisession)
#' results <- run_nl_all(nl)
#'
#' }
#' @aliases run_nl_all
#' @rdname run_nl_all
#'
#' @export

run_nl_all <- function(nl,
                       split = 1,
                       cleanup.csv = TRUE,
                       cleanup.xml = TRUE,
                       cleanup.bat = TRUE,
                       writeRDS = FALSE) {
  ## Store the number of siminputrows
  siminput_nrow <- nrow(getsim(nl, "siminput"))
  ## Check if split parameter is valid:
  if (siminput_nrow %% split != 0) {
    stop(
      "Modulo of split parameter and number of rows of the siminput matrix is
      not 0. Please adjust split parameter to a valid value!",
      call. = FALSE
    )
  }

  ## Calculate size of one part:
  n_per_part <- siminput_nrow / split
  ## Generate job ids from seeds and parts:
  jobs <- as.list(expand.grid(getsim(nl, "simseeds"), seq(1:split)))
  ## Setup progress bar:
  total_steps <- siminput_nrow * length(getsim(nl, "simseeds"))
  p <- progressr::progressor(steps = total_steps)

  ## Execute on remote location
  nl_results <- furrr::future_map_dfr(
      seq_along(jobs[[1]]),
      function(job) {
        ## Extract current seed and part from job id:
        job_seed <- jobs[[1]][[job]]
        job_part <- jobs[[2]][[job]]

        ## Calculate rowids of the current part:
        rowids <-
          seq(1:n_per_part) +
          (job_part - 1) * n_per_part

        ## Start inner loop to run model simulations:
        res_job <- furrr::future_map_dfr(
          rowids,
          function(siminputrow) {

            # Update progress bar:
            p(sprintf("row %d/%d seed %d",
                      siminputrow, nrow(getsim(nl, "siminput")),
                      job_seed))
            # Run simulation
            res_one <- run_nl_one(
              nl = nl,
              seed = job_seed,
              siminputrow = siminputrow,
              cleanup.csv = cleanup.csv,
              cleanup.xml = cleanup.xml,
              cleanup.bat = cleanup.bat,
              writeRDS = writeRDS
            )
            return(res_one)
          })
        return(res_job)
      })
  return(nl_results)
}



#' Execute one NetLogo simulation from a nl object
#'
#' @description Execute one NetLogo simulation from a nl object with a defined experiment and simdesign
#'
#' @param nl nl object
#' @param seed a random seed for the NetLogo simulation
#' @param siminputrow rownumber of the input tibble within the attached simdesign object that should be executed
#' @param cleanup.csv TRUE/FALSE, if TRUE temporary created csv output files will be deleted after gathering results.
#' @param cleanup.xml TRUE/FALSE, if TRUE temporary created xml output files will be deleted after gathering results.
#' @param cleanup.bat TRUE/FALSE, if TRUE temporary created bat/sh output files will be deleted after gathering results.
#' @param writeRDS TRUE/FALSE, if TRUE an rds file with the simulation results will be written to the defined outpath folder of the experiment within the nl object.
#' @return tibble with simulation output results
#' @details
#'
#' run_nl_one executes one simulation of the specified NetLogo model within the provided nl object.
#' The random seed is set within the NetLogo model to control stochasticity.
#' The siminputrow number defines which row of the input data tibble within the simdesign object of the provided nl object is executed.
#' The logical cleanup variables can be set to FALSE to preserve temporary generated output files (e.g. for debugging).
#' cleanup.csv deletes/keeps the temporary generated model output files from each run.
#' cleanup.xml deletes/keeps the temporary generated experiment xml files from each run.
#' cleanup.bat deletes/keeps the temporary generated batch/sh commandline files from each run.
#'
#' This function can be used to run single simulations of a NetLogo model.
#'
#'
#' @examples
#' \dontrun{
#'
#' # Load nl object from test data:
#' nl <- nl_lhs
#'
#' # Run one simulation:
#' results <- run_nl_one(nl = nl,
#'                       seed = getsim(nl, "simseeds")[1],
#'                       siminputrow = 1)
#'
#' }
#' @aliases run_nl_one
#' @rdname run_nl_one
#'
#' @export

run_nl_one <- function(nl,
                       seed,
                       siminputrow,
                       cleanup.csv = TRUE,
                       cleanup.xml = TRUE,
                       cleanup.bat = TRUE,
                       writeRDS = FALSE) {

  util_eval_simdesign(nl)

  ## Write XML File:
  xmlfile <-
    tempfile(
      pattern = paste0("nlrx_seed_", seed, "_row_", siminputrow, "_"),
      fileext = ".xml"
    )

  util_create_sim_XML(nl, seed, siminputrow, xmlfile)

  ## Execute:
  outfile <-
    tempfile(
      pattern = paste0("nlrx_seed_", seed, "_row_", siminputrow, "_"),
      fileext = ".csv"
    )

  batchpath <- util_read_write_batch(nl)
  util_call_nl(nl, xmlfile, outfile, batchpath)

  ## Read results
  nl_results <- util_gather_results(nl, outfile, seed, siminputrow)

  ## Delete temporary files:
  cleanup.files <- list("csv" = outfile,
                        "xml" = xmlfile,
                        "bat" = batchpath)

  util_cleanup(nl, cleanup.csv, cleanup.xml, cleanup.bat, cleanup.files)


  if (isTRUE(writeRDS))
  {
    if(dir.exists(nl@experiment@outpath))
    {
      filename <- paste0("nlrx_seed_", seed, "_row_", siminputrow, ".rds")
      saveRDS(nl_results, file=file.path(nl@experiment@outpath, filename))
    } else
    {
      warning(paste0("Outpath of nl object does not exist on remote file system: ", nl@experiment@outpath, ". Cannot write rds file!"))
    }
  }

  return(nl_results)
}




#' Execute NetLogo simulation without pregenerated parametersets
#'
#' @description Execute NetLogo simulation from a nl object with a defined experiment and simdesign but no pregenerated input parametersets
#'
#' @param nl nl object
#' @param seed a random seed for the NetLogo simulation
#' @param cleanup.csv TRUE/FALSE, if TRUE temporary created csv output files will be deleted after gathering results.
#' @param cleanup.xml TRUE/FALSE, if TRUE temporary created xml output files will be deleted after gathering results.
#' @param cleanup.bat TRUE/FALSE, if TRUE temporary created bat/sh output files will be deleted after gathering results.
#' @return simulation output results can be tibble, list, ...
#' @details
#'
#' run_nl_dyn can be used for simdesigns where no predefined parametersets exist.
#' This is the case for dynamic designs, such as Simulated Annealing and Genetic Algorithms, where parametersets are dynamically generated, based on the output of previous simulations.
#' The logical cleanup variables can be set to FALSE to preserve temporary generated output files (e.g. for debugging).
#' cleanup.csv deletes/keeps the temporary generated model output files from each run.
#' cleanup.xml deletes/keeps the temporary generated experiment xml files from each run.
#' cleanup.bat deletes/keeps the temporary generated batch/sh commandline files from each run.
#'
#' @examples
#' \dontrun{
#'
#' # Load nl object form test data:
#' nl <- nl_lhs
#'
#' # Add genalg simdesign:
#' nl@@simdesign <- simdesign_GenAlg(nl=nl,
#'                                   popSize = 200,
#'                                   iters = 100,
#'                                   evalcrit = 1,
#'                                   nseeds = 1)
#'
#' # Run simulations:
#' results <- run_nl_dyn(nl)
#'
#' }
#' @aliases run_nl_dyn
#' @rdname run_nl_dyn
#'
#' @export

run_nl_dyn <- function(nl,
                       seed,
                       cleanup.csv = TRUE,
                       cleanup.xml = TRUE,
                       cleanup.bat = TRUE) {
  nl_results <- NULL

  if (getsim(nl, "simmethod") == "GenSA") {
    nl_results <- util_run_nl_dyn_GenSA(
      nl = nl,
      seed = seed,
      cleanup.csv = cleanup.csv,
      cleanup.xml = cleanup.xml,
      cleanup.bat = cleanup.bat
    )
  }

  if (getsim(nl, "simmethod") == "GenAlg") {
    nl_results <- util_run_nl_dyn_GenAlg(
      nl = nl,
      seed = seed,
      cleanup.csv = cleanup.csv,
      cleanup.xml = cleanup.xml,
      cleanup.bat = cleanup.bat
    )
  }

  if (getsim(nl, "simmethod") == "ABCmcmc") {
    nl_results <- util_run_nl_dyn_ABCmcmc(
      nl = nl,
      seed = seed,
      cleanup.csv = cleanup.csv,
      cleanup.xml = cleanup.xml,
      cleanup.bat = cleanup.bat
    )
  }


  return(nl_results)
}


