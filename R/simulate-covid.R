#
#' Simulate COVID
#'
#' @name simulate_covid
#'
#' @description simulate covid for a given reproduction number, level of
#' vaccinations in a population, and other epidemiological params.
#'
#' @param r0 base reproduction number. Defaults to 3 plus delta variant increases by 50 per cent: https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/993232/S1272_LSHTM_Modelling_Paper_B.1.617.2.pdf
#' @param serial_interval 5 days, from https://www.medrxiv.org/content/10.1101/2021.06.04.21258205v1.full.pdf
#' @param vaccination_levels vaccination_levels by age; provided in a named vector. If a single numeric is provided, distributed uniformly among age groups.
#' @param weekly_vaccinations defaults to  0.005. The additional proportion of the population vaccinated each week
#' @param p_max_vaccinated  defaults to 0.90.
#' @param vac_infection_rate defaults to 0.2.
#' @param vac_transmission_rate defaults to 0.5.
#' @param vac_hospitalisation_reduction defaults to 0.95. The hospitalisation reduction when vaccinated GIVEN infection
#' @param vac_death_reduction defaults to 0.99. The death reduction when vaccinated GIVEN infection
#' @param hospitalisation_per_death defaults to 20.
#' @param max_hospitalisation_rate defaults to 0.95.
#' @param population_scale_factor defaults to 10, where values of 1 implies 26m  population; 10=2.6m, 100=260k population, etc
#' @param n_start_infected defaults to 100 people infected at day 0.
#' @param n_iterations defaults to  3.
#' @param simulations defaults to  1.
#' @param scenario defaults to 1.
#' @param return_iterations defaults to TRUE
#' @param return_population defaults to FALSE
#'
#' @return A \code{tibble} object.
#'
#' @import dplyr
#' @import readr
#' @import purrr
#' @importFrom tidyr uncount
#' @importFrom scales comma percent
#' @importFrom stats runif
#' @import data.table
#'
#' @export


globalVariables(c("age", "day", "is_dead", "is_hosp", "is_infected",
                  "is_vaccinated", "new_vaccinated", "iteration", "maybe_infected",
                  "new_cases", "new_dead", "new_hosp", "newly_infected", "newly_vaccinated",
                  "runid", "vaccinated_after_infection", "."))

simulate_covid <- function(
  r0 = 4.5,
  serial_interval = 5,
  vaccination_levels = c(
    under12 = 0.00,
    under40 = 0.70,
    under60 = 0.95,
    under80 = 0.95,
    over80  = 0.95),
  weekly_vaccinations = 0.005,
  p_max_vaccinated = 0.90,
  vac_infection_rate = 0.2,
  vac_transmission_rate = 0.5,
  vac_hospitalisation_reduction = 0.95,
  vac_death_reduction = 0.99,
  hospitalisation_per_death = 20,
  max_hospitalisation_rate = 0.95,
  population_scale_factor = 10,
  n_start_infected = 100,
  p_max_infected = 0.8,
  n_iterations =  3,
  simulations = 1,
  scenario = 1,
  return_iterations = TRUE,
  return_population = FALSE
) {


  # function to estimate the Reff once (split this out)
  simulate_covid_run <- function(runid) {

    # Get Australia
    aus <- .read_demographics(uncounted = TRUE,
                              scale_factor = population_scale_factor) %>%
            as.data.table()

    n_population <- nrow(aus)

    # vaccinate (some of) the nation
    aus[, is_vaccinated := runif(.N) <= .get_vaccination_level(age,
                                                               vaccination_levels)]

    p_start_vaccinated <- aus[, sum(is_vaccinated)] / n_population

    # starting infected population more likely to be unvaccinated
    p_infected_vaccinated_start <- p_start_vaccinated / 5
    p_infected_unvaccinated_start <- (1 - p_infected_vaccinated_start)

    # starting vaccination levels
    n_start_infected_vaccinated <- round(p_infected_vaccinated_start * n_start_infected)
    n_start_infected_unvaccinated <- round(p_infected_unvaccinated_start * n_start_infected)

    # vaccinate
    aus[, is_infected := FALSE] %>%
      .[is_vaccinated == TRUE,
        is_infected := .sample_fixed_TRUE(.N, n_start_infected_vaccinated)] %>%
      .[is_vaccinated == FALSE,
       is_infected := .sample_fixed_TRUE(.N, n_start_infected_unvaccinated)] %>%
      .[, newly_infected := is_infected]

    # add vars
    aus[, is_hosp := FALSE] %>%
      .[, is_dead := FALSE] %>%
      .[, vaccinated_after_infection := FALSE]

    # record starting conditions
    start_conditions <- tibble(
      iteration = 0L,
      new_cases = n_start_infected,
      new_hosp  = 0,
      new_dead  = 0,
      new_vaccinated = round(p_start_vaccinated * n_population))

    zero_count <- 0

    iteration_vaccinations <- round(weekly_vaccinations / 7 * serial_interval * n_population)
    # - should add some decaying function for this

    # loop over iterations
    for (t in seq_len(n_iterations)) {

      message("Scenario: ", scenario, "; run: ", runid)
      message("\tIteration: ", t, " (day ", t*serial_interval, ")")

      # *at start of day*

      # how many new vaccinated -----
      current_vac_rate <- aus[, sum(is_vaccinated)] / n_population
      message("\t\tVaccination rate: ", round(current_vac_rate, 3))

      # reset new vaccinations
      aus[, newly_vaccinated := FALSE]

      vaccinate_more <- current_vac_rate < p_max_vaccinated

      if (vaccinate_more) {

        aus[is_vaccinated == FALSE & is_dead == FALSE,
            newly_vaccinated := .sample_fixed_TRUE(.N, iteration_vaccinations)]

        # is the vaccination happening AFTER a person has already been infected?
        aus[is_infected == TRUE & newly_vaccinated == TRUE,
            vaccinated_after_infection := TRUE]

        # convert to an vaccination (ie: these are vaccines administered 14 days ago)
        aus[newly_vaccinated == TRUE,
            is_vaccinated := TRUE]

        }

      # how many new infected:
      n_infected_and_vaccinated <- aus[, sum(newly_infected & is_vaccinated)]
      n_infected_and_unvaccinated <- aus[, sum(newly_infected & !is_vaccinated)]

      # Number of infected due to transmission and r0 but not infection
      n_maybe_infected <- n_infected_and_vaccinated * r0 * vac_transmission_rate +
                           n_infected_and_unvaccinated * r0
      n_maybe_infected <- as.integer(n_maybe_infected)

      message("\t\tMaybe infected: ", n_maybe_infected)

      if (n_maybe_infected == 0) {
        zero_count <- zero_count + 1
        if (zero_count == 3) break else next
      }

      # put new people in contact with covid:
      aus[, maybe_infected := FALSE] %>%
        .[, maybe_infected := .sample_fixed_TRUE(.N, n_maybe_infected)]

      # reset newly infected
      aus[,
          newly_infected := FALSE]

        # if maybe infected: zero chance if previously infected; lower chance if vaccinated
      aus[,
          newly_infected := fcase(
            maybe_infected == TRUE & is_vaccinated == TRUE,
              runif(.N) <= vac_infection_rate,
            maybe_infected == TRUE & is_infected == TRUE,
              FALSE,
            maybe_infected == TRUE & !is_vaccinated & !is_infected,
              TRUE,
            maybe_infected == FALSE,
              FALSE
            )] %>%
        .[, is_infected := newly_infected | is_infected]

      # Of the people who become infected, who requires hospitalisation, and
      # who will die?
      aus[newly_infected == TRUE,
          is_hosp := runif(.N) < covid_age_hospitalisation_prob(age, .vaccinated = is_vaccinated)] %>%
        .[newly_infected == TRUE,
          is_dead := runif(.N) < covid_age_death_prob(age, vaccinated = is_vaccinated)]


      # generate summary of new cases ---
      newly <- aus[newly_infected == TRUE]
      add_cases <- tibble(iteration = t,
                          new_cases = newly[, .N],
                          new_hosp  = newly[, sum(is_hosp)],
                          new_dead  = newly[, sum(is_dead)],
                          new_vaccinated  = aus[, sum(newly_vaccinated)]
                          )

      if (t == 1) {
        all_cases <- start_conditions %>%
          bind_rows(add_cases)
      } else {
        all_cases <- all_cases %>%
          bind_rows(add_cases)
      }

      tot_inf <- sum(all_cases$new_cases)

      message("\tTotal infected: ", scales::comma(tot_inf), " (", scales::percent(tot_inf/n_population, 0.1), ")")

    } # end day loop

    if (return_population) {
      return(aus)
    }

    # return all cases summary
    all_cases %>%
      mutate(runid = as.integer(runid),
             population = n_population
             ) %>%
      return()


  }

  # repeat the simulation:
  iterations <- map_dfr(1:simulations, simulate_covid_run) %>%
    group_by(runid) %>%
    mutate(day = iteration * serial_interval,
           total_cases = cumsum(new_cases),
           total_vaccinated = cumsum(new_vaccinated),
           total_hosp = cumsum(new_hosp),
           total_dead = cumsum(new_dead),
           rt = new_cases / lag(new_cases),
           reff = .calculate_reff(sum(new_cases), n_start_infected, n_iterations),
           scenario = scenario) %>%
    relocate(scenario, runid, iteration, day) %>%
    mutate(r0 = r0,
           vaccination_levels = list(vaccination_levels),
           vac_infection_rate = vac_infection_rate,
           vac_transmission_rate = vac_transmission_rate)

  # Print summary
  final <- iterations %>%
    filter(iteration == max(iteration)) %>%
    select(-iteration)

  message("Outcomes")
  message("\tCases:")
  print(summary(final$total_cases))
  message("\tDead:")
  print(summary(final$total_dead))

  if (return_iterations) {
    return(iterations)
  } else {
    return(final)
  }

}
