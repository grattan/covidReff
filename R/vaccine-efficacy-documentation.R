#' Vaccine efficacy data
#'
#' A tibble containing time-based vaccine efficacy for:
#' AstraZeneca (az) and Pfizer;
#' for first and second dosage;
#' for protection against infection and hospitalisation;
#' for each day since dosage.
#'
#' These estimates are constructed using the following sources:
#'
#' [Pouwels et al](https://www.ndm.ox.ac.uk/files/coronavirus/covid-19-infection- survey/finalfinalcombinedve20210816.pdf);
#' [Tartof et al](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3909743);
#' [Nasreen et al](https://www.medrxiv.org/content/10.1101/2021.06.28.21259420v1.full.pdf);
#' [Bernal et al (summarised)](https://www.ft.com/content/5a24d39a-a702-40d2-876d-b12a524dc9a5); and
#' see also https://github.com/grattan/covidReff/issues/27 for a discussion.
#'
#'
#' @format A tibble containing six variables
#' \describe{
#' \item{\code{protection_type}}{Protection against infecton "poi" or hospitalisation "poh"}
#' \item{\code{vaccine_type}}{Vaccine type: "pf" (Pfizer) or "az" (AstraZeneca)}
#' \item{\code{vaccine_dose}}{Vaccine protection against infection after a single dose of AstraZeneca from day 1 to 600 after vaccination.}
#' \item{\code{day}}{Days since receiving vaccine dose.}
#' \item{\code{efficacy}}{Efficacy, ie the reduction in likelihood of given outcome (infection, hospitalisation)}
#' \item{\code{source}}{Source for efficacy estimate. [Oxford-Pouwels](https://www.ndm.ox.ac.uk/files/coronavirus/covid-19-infection- survey/finalfinalcombinedve20210816.pdf); [Kaiser](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3909743); [Ontario](https://www.medrxiv.org/content/10.1101/2021.06.28.21259420v1.full.pdf); [Bernal-PHE](https://www.ft.com/content/5a24d39a-a702-40d2-876d-b12a524dc9a5); and see https://github.com/grattan/covidReff/issues/27 for a discussion. See also \code{?vaccine_efficacy}.}
#' }
"vaccine_efficacy"

#' Vaccine efficacy data by day
#'
#' Linear interpolation of vaccine efficacy data from day 1 to 600 since dosage. See \code{?vaccine_efficacy}
#'
#' @format A list containing eight named numeric vectors of length 600:
#' \describe{
#' \item{\code{ved_poi_pf1}}{Vaccine protection against infection after a single dose of Pfizer from day 1 to 600 after vaccination.}
#' \item{\code{ved_poi_pf2}}{Vaccine protection against infection after a double dose of Pfizer from day 1 to 600 after vaccination.}
#' \item{\code{ved_poi_az1}}{Vaccine protection against infection after a single dose of AstraZeneca from day 1 to 600 after vaccination.}
#' \item{\code{ved_poi_az2}}{Vaccine protection against infection after a double dose of AstraZeneca from day 1 to 600 after vaccination.}
#' \item{\code{ved_poh_pf1}}{Vaccine protection against hospitalisation after a single dose of Pfizer from day 1 to 600 after vaccination.}
#' \item{\code{ved_poh_pf2}}{Vaccine protection against hospitalisation after a double dose of Pfizer from day 1 to 600 after vaccination.}
#' \item{\code{ved_poh_az1}}{Vaccine protection against hospitalisation after a single dose of AstraZeneca from day 1 to 600 after vaccination.}
#' \item{\code{ved_poh_az2}}{Vaccine protection against hospitalisation after a double dose of AstraZeneca from day 1 to 600 after vaccination.}
#' }
"ved_list"
