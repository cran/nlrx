% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nl_to_points.R
\name{nl_to_points}
\alias{nl_to_points}
\title{Get spatial data from metrics.turtles output}
\usage{
nl_to_points(nl, coords)
}
\arguments{
\item{nl}{nl object}

\item{coords}{nl object}
}
\value{
tibble with spatial data objects
}
\description{
Turn turtle metrics from NetLogo in spatial data objects
}
\details{
Converts measured metrics.turtles into spatial sf point objects.
In order to so, a pair of turtle coordinates needs to be measured.
Any additional metrics will be stored as properties of the spatial points.
Because turtle coordinates in NetLogo can be measured in two formats,
pxcor/pycor or xcor/ycor coordinates, the type of coordinate used for
transformation to spatial objects need to be defined, using the parameter
coords: "px" for pxcor/pycor coordinates, "x" for xcor/ycor coordinates.

In order to use this function, simulation results need to be attached to
the nl object first.
}
\examples{

# Load nl object (with spatial output data already attached) from test data:
nl <- nl_spatial

# Convert turtle metrics (pxcor/pycor) to spatial point objects:
results.sf <- nl_to_points(nl, coords="px")


}
