% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RunSims_VRAP1.R
\name{RunSims.VRAP1}
\alias{RunSims.VRAP1}
\title{Run simulations sensu VRAP 1.0}
\usage{
RunSims.VRAP1(inputs, version = "R")
}
\arguments{
\item{inputs}{Inputs from .rav file}

\item{version}{R or C++}
}
\value{
list with inputs, SummaryStats, staticvars, comp.time.
}
\description{
RunSims.VRAP1 takes the input list, runs the VRAP simulations, and returns the summary statistics used by VRAP 1.0
}
\details{
This function is to produce VRAP 1.0 output stats using VRAP 1.0 functions.
}
