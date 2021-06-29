#' Get population rate based on an age-specific input
#'
#' @name get_population_rate
#'
#' @description determine the Australian population level rate for age-specific rates
#'
#' @param age_rate a named vector with levels for 'under12', 'under40', 'under60',
#' 'under80', 'over80'; eg: c(under12 = 0.00, under40 = 0.70, under60 = 0.90, under80 = 0.95, over80  = 0.95)
#'
#' @importFrom dplyr mutate summarise pull
#' @importFrom stats weighted.mean
#'
#' @export


get_population_rate <- function(
  age_rate = c(
    under12 = 0.00,
    under40 = 0.70,
    under60 = 0.90,
    under80 = 0.95,
    over80  = 0.95)
) {
  .read_demographics(uncounted = FALSE) %>%
    mutate(vac_rate = .get_vaccination_level(age, vaccination_levels)) %>%
    summarise(weighted.mean(vac_rate, n)) %>%
    pull()
}
