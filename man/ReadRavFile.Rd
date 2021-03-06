% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ReadRavFile.R
\name{ReadRavFile}
\alias{ReadRavFile}
\title{Read in rav File}
\usage{
ReadRavFile(InFile)
}
\arguments{
\item{InFile}{the name of the .rav file}
}
\value{
Returns the list of all inputs
}
\description{
Read in a VRAP 1.0 .rav file and assign all the variables need for VRAP 2.0
}
\details{
A .rav file is the input file for VRAP 1.0.  VRAP 2.0 uses most but not all the VRAP 1.0 specs and requires that some .rav values have certain values.  If illegal values are encountered, an error is returned.
}
\examples{
\dontrun{
fpath <- system.file("VRAP", "demofiles/Demo-ER.rav", package="VRAPS")
file.show(fpath)
}
}
