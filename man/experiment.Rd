% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/class_constr.R
\name{experiment}
\alias{experiment}
\title{Construct a new experiment object}
\usage{
experiment(
  expname = "defaultexp",
  outpath = NA_character_,
  repetition = 1,
  tickmetrics = "true",
  idsetup = "setup",
  idgo = "go",
  idfinal = NA_character_,
  idrunnum = NA_character_,
  runtime = 1,
  evalticks = NA_integer_,
  stopcond = NA_character_,
  metrics = c("count turtles"),
  metrics.turtles = list(),
  metrics.patches = NA_character_,
  metrics.links = list(),
  variables = list(),
  constants = list(),
  ...
)
}
\arguments{
\item{expname}{A character string defining the name of the experiment, no whitespaces allowed}

\item{outpath}{Path to a directory where experiment output will be stored}

\item{repetition}{A number which gives the number of repetitions for each row of the simulation design input tibble}

\item{tickmetrics}{Character string "true" runs defined metrics on each simulation tick. "false" runs metrics only after simulation is finished}

\item{idsetup}{character string or vector of character strings, defining the name of the NetLogo setup procedure}

\item{idgo}{character string or vector of character strings, defining the name of the NetLogo go procedure}

\item{idfinal}{character string or vector of character strings, defining the name of NetLogo procedures that should be run after the last tick}

\item{idrunnum}{character string, defining the name of a NetLogo global that should be used to parse the current siminputrow during model executions which can then be used for self-written output.}

\item{runtime}{number of model ticks that should be run for each simulation}

\item{evalticks}{vector of tick numbers defining when measurements are taken. NA_integer_ to measure each tick}

\item{stopcond}{a NetLogo reporter that reports TRUE/FALSE. If it reports TRUE the current simulation run is stopped (e.g. "not any? turtles")}

\item{metrics}{vector of strings defining valid NetLogo reporters that are taken as output measurements (e.g. c("count turtles", "count patches"))}

\item{metrics.turtles}{a list with named vectors of strings defining valid turtles-own variables that are taken as output measurements (e.g. list("turtles" = c("who", "pxcor", "pycor", "color"))}

\item{metrics.patches}{vector of strings defining valid patches-own variables that are taken as output measurements (e.g. c("pxcor", "pycor", "pcolor"))}

\item{metrics.links}{a list with named vectors of strings defining valid links-own variables that are taken as output measurements (e.g. list("links" = c("end1", "end2")))}

\item{variables}{a nested list of variables that are changed within a simulation design. The name of each sublist item has to be a valid global of the defined NetLogo model. Depending on the desired simdesign each list item consist of a vector of values, a min value, a max value, a step value and a qfun (e.g. list("paramA" = list(values=c(0, 0.5, 1), min=0, max=1, step=0.1, qfun="qunif")))}

\item{constants}{a list of constants that are kept constant within a simulation design. The name of each list item has to be a valid global of the defined NetLogo model (e.g. list("pNUM" = 12, "pLOGIC"="TRUE", "pSTRING"="\"default\""))}

\item{...}{...}
}
\value{
experiment S4 class object
}
\description{
Construct a new experiment object
}
\details{
The experiment class stores all information related to the NetLogo simulation experiment.
The class holds all information that is typically entered into NetLogo Behavior Space experiments.
When setting up an experiment, it is usually attached to an already defined \link[nlrx]{nl} object (see examples).
After attaching an experiment, different simdesign helper functions can be used to attach a simdesign to the nl object \link[nlrx]{simdesign}.
The simdesign helper functions use the variable definitions from the experiment within the nl object to generate a parameter tibble for simulations.

\strong{The following class slots are obligatory to run an experiment:}

\emph{repetition}

In cases, where the random seed is controlled by nlrx simdesigns, repitition should be set to one as random seeds would not differ between simulations.
In cases, where the random seed is set within the NetLogo model, repitition can be increased to repeat the same parameterisation with different random seeds.

\emph{tickmetrics}

If "true", the defined output reporters are collected on each simulation tick that is defined in evalticks. If "false" measurements are taken only on the last tick.

\emph{idsetup, idgo}

These two class slots accept strings, or vectors of strings, defining NetLogo model procedures that should be executed for model setup (idsetup) and model execution (idgo).

\emph{runtime}

Defines the maximum number of simulation ticks that are executed.
Use 0 or NA_integer_ to execute simulations without predefined number of ticks.
Warning: This is only recommended in combination with a stop condition (see slot stopcond), or NetLogo models with a built-in stop condition.
Otherwise, simulations might get stuck in endless loops.

\strong{Depending on the simdesign, the following slots may be obligatory:}

\emph{metrics}

A vector of valid netlogo reporters that defines which measurements are taken.
The optimization simdesigns need at least one defined metrics reporter for fitness calculation of the optimization algorithm.

\emph{constants, variables}

These slots accept lists with NetLogo parameters that should be varied within a simdesign (variables) or should be kept constant (constants) for each simulation.
Any NetLogo parameter that is not entered in at least one of these two lists will be set up as constant with the default value from the NetLogo interface.
It is not possible to enter a NetLogo parameter in both lists (a warning message will appear when a simdesign is attached to such an experiment).
All simdesigns except \link[nlrx]{simdesign_simple} need defined variables for setting up a parameter matrix.
Variables can be defined as distinct values, value distributions or range with increment.
The information that is needed, depends on the chosen simdesign (details on variable definition requirements can be found in the helpfiles of each simdesign helper function).

\strong{All remaining slots are optional:}

\emph{expname}

A character string defining the name of the experiment, useful for documentation purposes. The string must not contain any whitespaces.

\emph{outpath}

A valid path to an existing directory. The directory is used by the \link[nlrx]{write_simoutput} function to store attached simulation results to disk in csv format.

\emph{idfinal}

A character string or vector of strings defining NetLogo procedures that are executed at the end of each simulation (e.g. cleanup or self-written output procedures).

\emph{idrunnum}

This slot can be used to transfer the current nlrx experiment name, random seed and runnumber (siminputrow) to NetLogo.
To use this functionality, a string input field widget needs to be created on the GUI of your NetLogo model.
The name of this widget can be entered into the "idrunnum" field of the experiment.
During simulations, the value of this widget is automatically updated with a generated string that contains the current nlrx experiment name, random seed and siminputrow ("expname_seed_siminputrow").
For self-written output In NetLogo, we suggest to include this global variable which allows referencing the self-written output files to the collected output of the nlrx simulations in R.

\emph{evalticks}

Only applied if tickmetrics = TRUE.
Evalticks may contain a vector of integers, defining the ticks for which the defined metrics will be measured.
Set evalticks to NA_integer_ to measure on every tick.

\emph{stopcond}

The stopcond slot can be used to define a stop condition by providing a string with valid NetLogo code that reports either true or false.
Each simulation will be stopped automatically, once the reporter reports true.

\emph{metrics.patches}

The metrics.patches slot accepts a vector of valid patches-own variables of the NetLogo model.
These patch variables are measured in addition to the defined metrics.
Results of these metrics will be nested inside the output results tibble of the simulations.
Please note that NetLogo models may contain a huge number of patches and output measurements of agent variables on each tick may need a lot of ressources.

\emph{metrics.turtles}

The metrics.turtles slot accepts a list with named vectors of valid turtle breed metrics.
Each name of a vector in this list defines a specified breed of the NetLogo model, whereas the vector defines the variables that are measured for this breed.
For example metrics.turtles = list("sheep"=c("color"), "wolves"=c("who")) - would measure the color of each sheep and the who number of each wolf agent.
To measure turtles-own variables for all turtles, use "turtles" = c(...).
Be aware, that NetLogo will produce runtime errors if you measure breed-own variables for agents that do not belong to this breed.
Please note that NetLogo models may contain a huge number of turtles and output measurements of agent variables on each tick may need a lot of ressources.

\emph{metrics.links}

The metrics.links slot accepts a list with named vectors of valid link breed metrics.
Each name of a vector in this list defines a specified link breed of the NetLogo model, whereas the vector defines the variables that are measured for this link breed.
For example metrics.links = list("linktype-a"=c("end1"), "linktype-b"=c("end2")) - would measure the start agent of each linktype-a link and the end agent of each linktype-b link.
To measure links-own variables for all links, use "links" = c(...).
Be aware, that NetLogo will produce runtime errors if you measure link-breed-own variables for agents that do not belong to this breed.
Please note that NetLogo models may contain a huge number of turtles and output measurements of agent variables on each tick may need a lot of ressources.
}
\examples{

# To attach an experiment, a nl object needs to be created first (see ?nl).
# For this example, we load a nl object from test data.

# Example for Wolf Sheep Predation model from NetLogo models library:
nl <- nl_simple
nl@experiment <- experiment(expname="wolf-sheep",
                             outpath="C:/out/",
                             repetition=1,
                             tickmetrics="true",
                             idsetup="setup",
                             idgo="go",
                             idfinal=NA_character_,
                             idrunnum=NA_character_,
                             runtime=50,
                             evalticks=seq(40,50),
                             stopcond="not any? turtles",
                             metrics=c("count sheep",
                                       "count wolves",
                                     "count patches with [pcolor = green]"),
                             metrics.turtles=list("turtles" = c("who",
                                               "pxcor",
                                               "pycor",
                                               "color")),
                             metrics.patches=c("pxcor", "pycor", "pcolor"),
                             variables = list('initial-number-sheep' =
                             list(min=50, max=150, step=10, qfun="qunif"),
                                              'initial-number-wolves' =
                             list(min=50, max=150, step=10, qfun="qunif")),
                             constants = list("model-version" =
                                              "\"sheep-wolves-grass\"",
                                              "grass-regrowth-time" = 30,
                                              "sheep-gain-from-food" = 4,
                                              "wolf-gain-from-food" = 20,
                                              "sheep-reproduce" = 4,
                                              "wolf-reproduce" = 5,
                                              "show-energy?" = "false"))


}
