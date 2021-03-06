% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/targetId.R
\name{targetId}
\alias{targetId}
\title{Simultaneous MS1 profiling and target identification visualization}
\usage{
targetId(analysisDir = NULL)
}
\arguments{
\item{analysisDir}{(i.e. 04.stats)the full path of the analysis directory containing the
(.csv) files output from \code{\link{simExTargId}}.}
}
\description{
Visualization of deconvoluted data obtained during an MS1-level
profiling experiment. All statResults (.csv) files within an analysis directory
will be read and can be visualized as a volcano plot and as reactive
tables indicating the direction of the median fold change. This allows the
experimenter to visualize the emergence of statistically significant
pseudospectra features before the completion of a MS1-level profiling experiment.
minimum fold change and maximum multiple testing adjusted p-/q-values (\code{\link{coVarStatType}}) can be
set by the experimenter. When a list of possible targets has been determined
the table can be downloaded/ saved as a Csv file. This list of statistically
significant targets can therefore be readily included in a MS/MS fragmentation
experiment before the end of a profiling experiments completion.
}
\seealso{
\code{\link{simExTargId}}.
}
