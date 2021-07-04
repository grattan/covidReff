#' Get population rate based on an age-specific input
#'
#' @name get_population_rate
#'
#' @description determine the Australian population level rate for age-specific rates
#' @param age_rate a vector of length 10 with vaccination levels for age groups: 0-10, 11-20, ..., 81-90, and 90+.
#' Can be unnamed or named for clarity, eg: \code{c("0-10" = 0, "11-20" = 0.1, "21-30" = 0.2, "31-40" = 0.2, "41-50" = 0.2, "51-60" = 0.2, "61-70" = 0.2, "71-80" = 0.2, "81-90" = 0.2, "91-100" = 0.2)}
#'
#' @export

globalVariables(c("vac_rate"))

get_population_rate <- function(
  age_rate = c(0, 0.2, 0.6, 0.8, 0.7, 0.9, 0.9, 0.9, 0.9, 0.9)
) {

  if (length(age_rate) != 1 & length(age_rate) != 10) {
    stop("Vaccination levels must be a vector of length 1 or 10")
  }

  .read_demographics(uncounted = FALSE) %>%
    mutate(vac_rate = .get_vaccination_level(age, age_rate)) %>%
    summarise(weighted.mean(vac_rate, n)) %>%
    pull()
}
