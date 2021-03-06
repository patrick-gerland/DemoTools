% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/basepop.R
\name{downloadnLx}
\alias{downloadnLx}
\title{Extract Lx estimates from WPP2019}
\usage{
downloadnLx(nLx, country, gender, nLxDatesIn)
}
\arguments{
\item{nLx}{either \code{NULL} or a numeric vector of lifetable exposure. If it's the second then we just pass it back.}

\item{country}{character country name available UN Pop Div \code{LocName} set}

\item{gender}{\code{"male"}, \code{"female"}, or \code{"both"}}

\item{nLxDatesIn}{numeric vector of three decimal dates produced by (or passed through) \code{basepop_five()}}
}
\value{
numeric matrix of \code{nLx} with \code{length(nLxDatesIn)} and abrdiged ages in rows.
}
\description{
We use the \code{FetchLifeTableWpp2019} function of the \code{fertestr} to extract \code{Lx} from \code{wpp2019}, interpolated to an exact date.
}
