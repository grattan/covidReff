#
#' Simulate COVID
#'
#' @name simulate_covid
#'
#' @description Simulate covid for a given reproduction number, level of
#' vaccinations in a population, and other epidemiological params.
#'
#' @param R The average number of additional people an infected person will infect in an unvaccinated society. It incorporates both the R0 of the variant and behaviours and policies may reduce alter transmission. A single numeric with default 4.5 to represent the Delta variant in a low-restriction society. See \href{https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/993232/S1272_LSHTM_Modelling_Paper_B.1.617.2.pdf}{Kucharski et al (2021)}.
#' @param serial_interval The average number of days between a person becoming infected and infecting others. A single numeric with default of 5, appropriate for wild type/Delta variant: \href{https://www.medrxiv.org/content/10.1101/2021.06.04.21258205v1.full.pdf}{Pung et al (2021)}).
#' A shorter \code{serial_interval} will speed up the virus spread.
#' @param vaccination_levels Starting vaccination levels. Either a single numeric for a uniformly distributed population wide vaccination rate, or a named vector of length 10 representing the vaccination levels for age groups 0-10, 11-20, 21-30, ..., 91-100. Default is \code{vaccination_levels = c(0, 0, 0, 0.5, 0.6, 0.9, 0.9, 0.9, 0.9, 0.9)}
#' @param weekly_vaccinations The additional proportion of the population vaccinated per 7 days. A single numeric with default 0.005. The additional proportion of the population vaccinated each week
#' @param p_max_vaccinated  Maximum proportion of the population able to be vaccinated. A single numeric with default 0.90.
#' @param vac_infection_reduction The reduction in the likelihood of infection relative to an unvaccinated person. A single numeric with default 0.8. This default represents a reduction in the probability of infection of 80 per cent.
#' @param vac_transmission_reduction The reduction in the likelihood of transmission from an infected vaccinated person relative to an infected unvaccinated person. A single numeric with default 0.5, representing a 50 per cent reduction in transmission from vaccinated infection people.
#' @param vac_hospitalisation_reduction The reduction in the likelihood, given an infection, of requiring hospitalisation for a vaccinated person. A single numeric defaulting to 0.95.
#' @param vac_death_reduction The reduction in the likelihood, given an infection, of death for a vaccinated person. A single numeric defaulting to 0.99.
#' @param hospitalisation_per_death Average number of hospitalisations for each death that occurs. A single numeric with default 20.
#' @param death_rate The likelihood that an infected person dies. Either a character "loglinear", the default, which uses the log-linear relationship between age and mortality of \code{10^(-3.27 + 0.0524 * age) / 100} described in \href{https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7721859/}{Levin et al (2021)} and capped at 0.28. Alternatively, the user can provide a numeric vector of length 10 describing the death rates for age groups 0-10, 11-20, 21-30, ..., 91-100.
#' @param treatment_death_reduction The reduction in mortality from treatments. A single numeric with default 0.2 that proportionally reduces \code{death_rate} values. E.g. with \code{treatment_death_reduction = 0.2}, a person with a 10 per cent pre-treatment risk of dying from Covid would have an 8 per cent risk with treatment.
#' @param population_scale_factor Scales down the Australian population (about 26 million) by this factor. A single numeric, defaulting to 10. Values of 1 implies 26m population; 10 = 2.6m, 100 = 260k, etc
#' @param n_start_infected The number of people infected at the beginning of the simulation. Defaults to 100 people infected at day 0.
#' @param n_iterations Number of iterations the simulation runs for. A single integer defaulting to 3L. Means that the simulation runs for \code{serial_interval * n_iterations} days.
#' @param run_simulations The number of times the simulation is run. A single integer defaulting to  1L.
#' @param stagger_simulations Sets the number of days each run in \code{run_simulations} is separated by. A single numeric defaulting to 0. A value of e.g. 7 would start the first run at day 0, the second at day 7, the third at day 14, etc. This can be used to simulate the introduction of infections to independent groups progressively over time.
#' @param scenario Name of the scenario. Defaults to "1". This is useful when using \code{purrr::map} or \code{lapply} over a number of scenarios.
#'
#' @return A \code{tibble} object with one row per scenario, simulation and iteration. For each row, columns provide information on:
#'
#' \item{\code{scenario}}{The scenario name.}
#' \item{\code{runid}}{The simulation run number.}
#' \item{\code{iteration}}{The iteration of the scenario simulation run.}
#' \item{\code{day}}{Days since beginning of simulation, where \code{day = iteration * serial_iterval}.}
#' \item{\code{new_cases_i}}{the number of new Covid cases in iteration \code{i}.}
#' \item{\code{new_hosp_i}}{the number of new Covid hospitalisations in iteration \code{i}.}
#' \item{\code{new_dead_i}}{the number of new Covid dead in iteration \code{i}.}
#' \item{\code{new_vaccinated_i}}{the number of new people fully vaccinated in iteration \code{i}.}
#' \item{\code{total_cases_i}}{the cumulative number of Covid cases after iteration \code{i}.}
#' \item{\code{total_hosp_i}}{the cumulative number of Covid hosp after iteration \code{i}.}
#' \item{\code{total_dead_i}}{the cumulative number of Covid dead after iteration \code{i}.}
#' \item{\code{total_vaccinations_i}}{the cumulative number of Covid vaccinations after iteration \code{i}.}
#' \item{\code{total_cases_i}}{the cumulative number of Covid cases after iteration \code{i}.}
#' \item{\code{rt_i}}{The average number of new infections in this iteration cased by a case in the previous iteration.Derived with \code{rt_i = new_cases_i / lag(new_cases_i)}.}
#' \item{\code{reff}}{The overall effective reproduction number. Derived from sum of all new cases, number of cases initially, and the number of iterations with: \code{(total_cases / initial_cases)^(1/iterations) - 1}.}
#' \item{\code{in_population}}{Input population in the simulation, equal to the Australian population / \code{population_scale_factor}.}
#' \item{\code{in_R}}{Input \code{R} value.}
#' \item{\code{in_vaccination_levels}}{Input \code{vaccination_levels}.}
#' \item{\code{in_vac_infection_reduction}}{Input \code{vac_infection_reduction}.}
#' \item{\code{in_vac_transmission_reduction}}{Input \code{vac_transmission_reduction}.}
#'
#'
#'
#' @export


globalVariables(c("age", "day", "is_dead", "is_hosp", "is_infected",
                  "is_vaccinated", "new_vaccinated_i", "iteration", "maybe_infected",
                  "new_cases_i", "new_dead_i", "new_hosp_i", "newly_infected", "newly_vaccinated",
                  "runid", "vaccinated_after_infection", "."))


simulate_covid <- function(
  R = 4.5,
  serial_interval = 5,
  vaccination_levels = c(
    "0-10"  = 0.00,
    "11-20" = 0.20,
    "21-30" = 0.40,
    "31-40" = 0.50,
    "41-50" = 0.60,
    "51-60" = 0.70,
    "61-70" = 0.90,
    "71-80" = 0.90,
    "81-90" = 0.95,
    "91+"   = 0.95),
  weekly_vaccinations = 0.005,
  p_max_vaccinated = 0.90,
  vac_infection_reduction = 0.8,
  vac_transmission_reduction = 0.5,
  vac_hospitalisation_reduction = 0.95,
  vac_death_reduction = 0.99,
  hospitalisation_per_death = 20,
  death_rate = "loglinear",
  treatment_death_reduction = 0.2,
  population_scale_factor = 10,
  n_start_infected = 100,
  p_max_infected = 0.8,
  n_iterations =  3,
  run_simulations = 1,
  stagger_simulations = 0,
  scenario = 1,
  return_iterations = TRUE,
  return_population = FALSE
) {

  # convert to rates
  vac_infection_rate <- 1 - vac_infection_reduction
  vac_transmission_rate <- 1 - vac_transmission_reduction


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
      new_cases_i = n_start_infected,
      new_hosp_i  = 0,
      new_dead_i  = 0,
      new_vaccinated_i = round(p_start_vaccinated * n_population))

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

      # Number of infected due to transmission and R but not infection
      n_maybe_infected <- n_infected_and_vaccinated * R * vac_transmission_rate +
                           n_infected_and_unvaccinated * R
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
                          new_cases_i = newly[, .N],
                          new_hosp_i  = newly[, sum(is_hosp)],
                          new_dead_i  = newly[, sum(is_dead)],
                          new_vaccinated_i  = aus[, sum(newly_vaccinated)]
                          )

      if (t == 1) {
        all_cases <- start_conditions %>%
          bind_rows(add_cases)
      } else {
        all_cases <- all_cases %>%
          bind_rows(add_cases)
      }

      tot_inf <- sum(all_cases$new_cases_i)

      message("\tTotal infected: ", scales::comma(tot_inf), " (", scales::percent(tot_inf/n_population, 0.1), ")")

    } # end day loop

    # what day does this run start?
    start_day <- stagger_simulations * (runid - 1)


    # return all cases summary
    all_cases %>%
      mutate(
        runid = as.integer(runid),
        in_population = n_population,
        day = start_day + iteration * serial_interval,
        ) %>%
      return()

  } # end simulation

  # repeat the simulation:
  iterations <- map_dfr(1:run_simulations, simulate_covid_run) %>%
    group_by(runid) %>%
    mutate(total_cases_i = cumsum(new_cases_i),
           total_hosp_i = cumsum(new_hosp_i),
           total_dead_i = cumsum(new_dead_i),
           total_vaccinated_i = cumsum(new_vaccinated_i),

           rt_i = new_cases_i / lag(new_cases_i),
           reff = .calculate_reff(sum(new_cases_i), n_start_infected, n_iterations),

           scenario = scenario) %>%
    relocate(scenario, runid, iteration, day, starts_with("new"), starts_with("total")) %>%
    mutate(in_R = R,
           in_vaccination_levels = list(vaccination_levels),
           in_vac_infection_reduction = vac_infection_reduction,
           in_vac_transmission_reduction = vac_transmission_reduction)

    return(iterations)

}
