% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analyze_nl.R
\name{analyze_morris}
\alias{analyze_morris}
\title{Analyze NetLogo simulation output of simdesign morris}
\usage{
analyze_morris(nl, metrics, funs)
}
\arguments{
\item{nl}{nl object}

\item{metrics}{vector of strings defining metric columns for evaluation. Defaults to metrics of the experiment within the nl object}

\item{funs}{list with the summary metrics for the sensitivity results}
}
\description{
Analyze NetLogo simulation output of simdesign morris
}
\details{
The function calculates morris sensitivity indices from the output results using the \link[sensitivity]{sensitivity} package.
}
\keyword{internal}
