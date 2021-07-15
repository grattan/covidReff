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
#' A shorter \code{serial_interval} will speed up the virus spread over time.
#' @param vaccination_levels Starting vaccination levels. Either a single numeric for a uniformly distributed population wide vaccination rate, or a named vector of length 10 representing the vaccination levels for age groups 0-10, 11-20, 21-30, ..., 91-100. Default is \code{vaccination_levels = c(0, 0, 0, 0.5, 0.6, 0.9, 0.9, 0.9, 0.9, 0.9)}
#' @param vaccination_growth_steepness Defines how quickly additional people are vaccinated after opening, defaulting to 0.01. This is the growth parameter (\code{c}) in the logistic curve \code{M / (1 + ((M - n0) / n0) * exp(-c*t))}, where \code{n0} is the starting vaccination level defined by  \code{vaccination_levels}.
#' @param p_max_vaccinated  Maximum proportion of the population able to be vaccinated. A single numeric with default 0.90. This is the maximium level parameter (\code{M}) in the logistic curve \code{M / (1 + ((M - n0) / n0) * exp(-c*t))}, where \code{n0} is the starting vaccination level defined by  \code{vaccination_levels}.
#' @param only_pfizer_after_opening When the simulation starts, do newly vaccinated people only get \code{TRUE} the Pfizer vaccine (the defult), or a mix of
#' @param over60_az_share   The proportion of vaccinated people over 60 years old who have the AstraZeneca vaccine. Single numeric defaulting to 0.80. Used for vaccine distribution before the simulation starts and, when \code{only_pfizer_after_opening = FALSE}, for new vaccines during the simulation.
#' @param under60_az_share  The proportion of vaccinated people 60-years-old and younger who have the AstraZeneca vaccine. Single numeric defaulting to 0.80. Used for vaccine distribution before the simulation starts and, when \code{only_pfizer_after_opening = FALSE}, for new vaccines during the simulation.
#' @param vac_transmission_reduction The reduction in the likelihood of transmission from an infected vaccinated person relative to an infected unvaccinated person. A single numeric with default 0.5, representing a 50 per cent reduction in transmission from vaccinated infection people.
#' @param death_rate The likelihood that an infected unvaccinated person dies by age. Either a character "loglinear", the default, which uses the log-linear relationship between age and mortality of \code{10^(-3.27 + 0.0524 * age) / 100} described in \href{https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7721859/}{Levin et al (2021)} and capped at 0.28. Alternatively, the user can provide a numeric vector of length 10 describing the death rates for age groups 0-10, 11-20, 21-30, ..., 91-100.
#' @param treatment_death_reduction The reduction in mortality from treatments. A single numeric with default 0.2 that proportionally reduces \code{death_rate} values. E.g. with \code{treatment_death_reduction = 0.2}, a person with a 10 per cent pre-treatment risk of dying from Covid would have an 8 per cent risk with treatment.
#' @param n_population Population size for each simulation. A single numeric defaulting to 2.6e6 (about 10 per cent of the Australian population).
#' @param n_start_infected The number of people infected at the beginning of the simulation. A numeric defaulting to 100 people infected at day 0.
#' @param n_daily_introductions The number of new external infections introduced each day. A numeric defaulting to 1.
#' @param n_iterations Number of iterations the simulation runs for. A single integer defaulting to 3L. Means that the simulation runs for \code{serial_interval * n_iterations} days.
#' @param run_simulations The number of times the simulation is run. A single integer defaulting to  1L.
#' @param scenario Name of the scenario. Defaults to "1". This is useful when using \code{purrr::map} or \code{lapply} over a number of scenarios.
#'
#' @return A \code{tibble} object with one row per scenario, simulation and iteration. For each row, columns provide information on:
#'
#' \item{\code{scenario}}{The scenario name.}
#' \item{\code{runid}}{The simulation run number.}
#' \item{\code{iteration}}{The iteration of the scenario simulation run.}
#' \item{\code{day}}{Days since beginning of simulation, where \code{day = iteration * serial_iterval}.}
#' \item{\code{new_maybe_infected_i}}{the number of new possible Covid cases in iteration \code{i} (interpreted as contacts that would become cases without vaccines).}
#' \item{\code{new_cases_i}}{the number of new Covid cases in iteration \code{i}.}
#' \item{\code{new_dead_i}}{the number of new Covid dead in iteration \code{i}.}
#' \item{\code{new_vaccinated_i}}{the number of new people fully vaccinated in iteration \code{i}.}
#' \item{\code{total_cases_i}}{the cumulative number of Covid cases after iteration \code{i}.}
#' \item{\code{total_dead_i}}{the cumulative number of Covid dead after iteration \code{i}.}
#' \item{\code{total_vaccinations_i}}{the cumulative number of Covid vaccinations after iteration \code{i}.}
#' \item{\code{rt_i}}{The average number of new infections in this iteration cased by a case in the previous iteration.Derived with \code{rt_i = new_cases_i / lag(new_cases_i)}.}
#' \item{\code{in_population}}{Input population in the simulation, equal to the \code{n_population}.}
#' \item{\code{in_R}}{Input \code{R} value.}
#' \item{\code{in_vaccination_levels}}{Input \code{vaccination_levels}.}
#'
#'
#' @export


globalVariables(c("age", "day", "is_dead", "is_infected",
                  "is_vaccinated", "new_vaccinated_i", "iteration", "maybe_infected",
                  "new_cases_i", "new_local_cases_i", "new_dead_i", "newly_infected", "new_first_dose",
                  "runid", "vaccinated_after_infection", ".", "vaccine_type", "vaccine_dose",
                  "days_since_first_dose", "start_first_dose", "vaccine_protection"))

# terminal styles
bad <- red
good <- green
note <- cyan
notebold <- bgCyan$white$bold


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
  vaccination_growth_steepness = 0.01,
  only_pfizer_after_opening = TRUE,
  over60_az_share  = 0.80,
  under60_az_share = 0.20,
  p_max_vaccinated = 0.90,
  vac_transmission_reduction = 0.50,
  death_rate = "loglinear",
  treatment_death_reduction = 0.2,
  n_population = 2e5,
  n_start_infected = 10,
  n_daily_introductions = 1,
  n_iterations =  3,
  run_simulations = 1,
  scenario = "1",
  quiet = n_population < 100e3
) {

  quiet <- isTRUE(quiet)
  vac_transmission_rate <- 1 - vac_transmission_reduction

  # get Australia population
  base_aus <- .read_demographics(uncounted = TRUE,
                                 n_pop = n_population) %>%
    as.data.table()

  # function to estimate the Reff once (split this out)
  simulate_covid_run <- function(runid) {

    if (!quiet) {
      message(notebold("Scenario", scenario, "\t|\trun", runid))
    }
    aus <- base_aus

    n_population <- nrow(aus)

    # fully vaccinate (some of) the nation
    aus[, vaccine_type := factor("none",
                                 levels = vaccine_names)] %>%
      .[, vaccine_dose := 0L] %>%
      # fully vaccinated start:
      .[, is_vaccinated := dqrunif(.N) <= .get_vaccination_level(age,
                                                               vaccination_levels)] %>%

      # if fully vaccinated, what vaccine?
      .[is_vaccinated == TRUE,
        vaccine_type := .get_vaccination_type(age,
                                              over60az = over60_az_share,
                                              under60az = under60_az_share)] %>%
      .[is_vaccinated == TRUE,
        vaccine_dose := 2L]

    # how many should have first dose?
    pop_vaccinated <- get_population_rate(vaccination_levels)

    # how many had first dose vaccines?
    previous_vaccination_rates <- .logistic_curve(
      -pf_1_second_dose_wait_days / serial_interval,
      p_max_vaccinated,
      pop_vaccinated,
      vaccination_growth_steepness)

    n_start_pf_first <- round(n_population * (pop_vaccinated - previous_vaccination_rates))

    # first dose some of the population with Pfizer
    # set days_since_first_dose:
    aus[is_vaccinated == TRUE,
        days_since_first_dose := 1000] %>%
      .[is_vaccinated == FALSE,
        days_since_first_dose := 0] %>%
    # some start with first dose:
      .[is_vaccinated == FALSE,
        start_first_dose := .sample_fixed_TRUE(.N, n_start_pf_first)] %>%
      .[start_first_dose == TRUE,
        vaccine_dose := 1L]

    # set vaccine types:
      if (only_pfizer_after_opening) {
        aus[start_first_dose == TRUE,
            vaccine_type := factor("pf", vaccine_names)]
      } else {
        aus[start_first_dose == TRUE,
            vaccine_type := .get_vaccination_type(age,
                                                  over60az = over60_az_share,
                                                  under60az = under60_az_share)]
      }

    # set
    aus[start_first_dose == TRUE,
      # days_since_first_dose := round(runif(.N,
      #                                      min = 1,
      #                                      max = fifelse(vaccine_type == "pf",
      #                                                    pf_1_second_dose_wait_days,
      #                                                    az_1_second_dose_wait_days)))]
      days_since_first_dose := dqrng::dqsample.int(if (.BY[[1]] == "pf") {
        pf_1_second_dose_wait_days
      } else {
        az_1_second_dose_wait_days
      },
      size = .N,
      replace = TRUE),
      by = "vaccine_type"]



    p_start_vaccinated <- aus[, sum(is_vaccinated)] / n_population

    # starting infected population more likely to be unvaccinated
    p_infected_vaccinated_start <- p_start_vaccinated
    p_infected_unvaccinated_start <- (1 - p_infected_vaccinated_start)

    # starting vaccination levels
    n_start_infected_vaccinated <- round(p_infected_vaccinated_start * n_start_infected)
    n_start_infected_unvaccinated <- round(p_infected_unvaccinated_start * n_start_infected)

    # infect
    aus[, is_infected := FALSE] %>%
      .[is_vaccinated == TRUE,
        is_infected := .sample_fixed_TRUE(.N, n_start_infected_vaccinated)] %>%
      .[is_vaccinated == FALSE,
       is_infected := .sample_fixed_TRUE(.N, n_start_infected_unvaccinated)] %>%
      .[, newly_infected := is_infected]

    # add vars
    aus[, is_dead := FALSE] %>%
      .[, vaccinated_after_infection := FALSE]

    # record starting conditions
    start_conditions <- tibble(
      iteration = 0L,
      new_cases_i = n_start_infected,
      new_local_cases_i = n_start_infected,
      new_os_cases_i = 0L,
      new_cases_vaccinated2_i = n_start_infected_vaccinated,
      new_dead_i  = 0,
      new_dead_vaccinated2_i  = 0,
      new_vaccinated_i = round(p_start_vaccinated * n_population))

    zero_count <- 0

    current_vaccination_level <- .logistic_curve(
      0,
      p_max_vaccinated,
      pop_vaccinated,
      vaccination_growth_steepness)

    n_iteration_introductions <- n_daily_introductions * serial_interval


    # loop over iterations -----------
    for (t in seq_len(n_iterations)) {

      day_count <- t * serial_interval

      # *at start of day* ----

      # what proportion are vaccinated
      current_vac_rate <- aus[, sum(vaccine_dose > 0L)] / n_population
      current_vac2_rate <- aus[, sum(vaccine_dose > 1L)] / n_population

      # progress first dose time periods and convert to second dose
      aus[vaccine_dose == 1L,
          days_since_first_dose := days_since_first_dose + serial_interval] %>%
        .[days_since_first_dose > pf_1_second_dose_wait_days,
          vaccine_dose := 2L]

      # reset new vaccinations
      aus[, new_first_dose := FALSE]

      vaccinate_more <- current_vac_rate < p_max_vaccinated

      if (vaccinate_more) {

        new_vaccination_level <- .logistic_curve(
          t * serial_interval,
          p_max_vaccinated,
          pop_vaccinated,
          vaccination_growth_steepness)

        new_vaccinations <- round(n_population * (new_vaccination_level - current_vaccination_level))

        current_vaccination_level <- new_vaccination_level

        aus[is_vaccinated == FALSE & is_dead == FALSE,
            new_first_dose := .sample_fixed_TRUE(.N, new_vaccinations)]

        # if only pfizer after opening:
        if (only_pfizer_after_opening) {
          aus[new_first_dose == TRUE,
              vaccine_type := factor("pf", vaccine_names)]
        } else {
          aus[new_first_dose == TRUE,
              vaccine_type := .get_vaccination_type(age,
                                                    over60az = over60_az_share,
                                                    under60az = under60_az_share)]
        }

        # for the newly vaccined:
        aus[new_first_dose == TRUE,
            vaccine_dose := 1L] %>%
          .[new_first_dose == TRUE,
            days_since_first_dose := 0] %>%
          .[new_first_dose == TRUE,
            is_vaccinated == TRUE]

      }

      # INFECTIONS -------------------------------------------------------------
      # how many newly infected in the community last iteration:
      n_infected_and_vaccinated <- aus[, sum(newly_infected & vaccine_dose == 2L)]
      n_infected_and_unvaccinated <- aus[, sum(newly_infected & vaccine_dose < 2L)]

      # n_maybe_infected is the number of infected due to R and
      # differing rates of infection-spread among vacc/not vacc,
      # but not vaccination protection. 
      # (i.e. here we take into account whether or not
      #  a vaccinated person is less likely to cough, 
      #  but not whether the person
      #  they cough on is endowed with greater protection
      #  from infection because they are vaccinated)
      n_maybe_infected <- n_infected_and_vaccinated * R * vac_transmission_rate +
                           n_infected_and_unvaccinated * R
      n_maybe_infected <- as.integer(n_maybe_infected)

      if (n_maybe_infected == 0) {
        zero_count <- zero_count + 1
        if (zero_count == 3) break else next
      }

      # reset maybe infected and newly infected
      aus[, maybe_infected := FALSE] %>%
        .[, newly_infected := FALSE]

      # introduce n_iteration_introductions cases into the community;
      # with at least some vaccination protection (as a border requirement)

      # put other people in contact with Covid:
      aus[newly_infected == FALSE,
          maybe_infected := .sample_fixed_TRUE(.N, n_maybe_infected)]


      # if maybe infected and vaccinated, what vaccine protection?
      aus[maybe_infected == TRUE,
          vaccine_protection := fcase(
            vaccine_type == "pf" & vaccine_dose == 1L, pf_1_poh,
            vaccine_type == "pf" & vaccine_dose == 2L, pf_2_poh,
            vaccine_type == "az" & vaccine_dose == 1L, az_1_poh,
            vaccine_type == "az" & vaccine_dose == 2L, az_2_poh,
            vaccine_type == "none", 0
          )]

      # if maybe infected: zero chance if previously infected; lower chance if vaccinated
      aus[maybe_infected == TRUE & newly_infected == FALSE,
            newly_infected := fcase(
            # # if contact but already infected: can't be infected
              is_infected == TRUE, FALSE,
              # if contact and vaccinated, does vaccination protect?
              vaccine_dose > 0L, dqrunif(.N) > vaccine_protection,
              # if contact and not vaccinated, infected:
              vaccine_dose == 0L, TRUE)] %>%
        # add overseas cases
        .[maybe_infected == FALSE & is_infected == FALSE & vaccine_dose >= 1L,
          newly_infected := .sample_fixed_TRUE(.N, n_iteration_introductions)] %>%
        .[, is_infected := newly_infected | is_infected]

      # Of the people who become infected, who dies?
      aus[newly_infected == TRUE,
          is_dead := dqrunif(.N) < covid_age_death_prob(age, vaccine_type, vaccine_dose,
                                                      .treatment_improvement = treatment_death_reduction)]

      # generate summary of new cases ---
      newly <- aus[newly_infected == TRUE]

      new_cases <- newly[, .N]
      new_os_cases <- n_iteration_introductions
      new_local_cases <- new_cases - n_iteration_introductions
      new_dead <- newly[, sum(is_dead)]
      new_dead_vac <- newly[vaccine_dose == 2L, sum(is_dead)]
      new_cases_vac <- newly[vaccine_dose == 2L, .N]
      new_vaccinated <- aus[, sum(new_first_dose)]
      total_vaccinated1 <- aus[vaccine_dose == 1L, .N]
      total_vaccinated2 <- aus[vaccine_dose == 2L, .N]
      total_pf <- aus[vaccine_type == "pf", .N]
      total_az <- aus[vaccine_type == "az", .N]

      if (!quiet) {
        message(note$underline("\nIteration: ", t, " ( day ", day_count, ")\t\t\t"))
        message(good("\tVaccination rate, dose 1: ", scales::percent(current_vac_rate, 0.1)))
        message(good("\tVaccination rate, dose 2: ", scales::percent(current_vac2_rate, 0.1)))
        message(note("\tMaybe infected:           ", scales::comma(n_maybe_infected)))
        message(note("\tNew local cases:          ", scales::comma(new_local_cases),
                     "(", scales::percent(new_local_cases/n_maybe_infected, 0.1), " of maybe infected)"))
        message(note("\tNew overseas cases:       ", scales::comma(new_os_cases)))
        message(note("\tNew cases fully vaccinated:", scales::comma(new_cases_vac), "/", scales::percent(new_cases_vac/new_cases)))
        message(bad("\tNew dead:           \t", scales::comma(new_dead),
                "\t\t", scales::percent(new_dead_vac / new_dead), " were fully vaccinated"))
        message(good("\tNew vaccinated:    \t", scales::comma(new_vaccinated)))
        message(good("\tTotal first dose:  \t", scales::comma(total_vaccinated1)))
        message(good("\tTotal second dose: \t", scales::comma(total_vaccinated2)))
        message(good("\tTotal Pfizer:      \t", scales::comma(total_pf)))
        message(good("\tTotal AZ:          \t", scales::comma(total_az)))
      }

      add_cases <- tibble(iteration = t,
                          new_maybe_infected_i = n_maybe_infected,
                          new_cases_i = new_cases,
                          new_local_cases_i = new_local_cases,
                          new_os_cases_i = new_os_cases,
                          new_cases_vaccinated2_i = new_cases_vac,
                          new_dead_i = new_dead,
                          new_dead_vaccinated2_i = new_dead_vac,
                          new_vaccinated_i = new_vaccinated,
                          total_vaccinated1_i = total_vaccinated1,
                          total_vaccinated2_i = total_vaccinated2,
                          total_pf_i = total_pf,
                          total_az_i = total_az
                          )

      if (t == 1) {
        all_cases <- start_conditions %>%
          bind_rows(add_cases)
      } else {
        all_cases <- all_cases %>%
          bind_rows(add_cases)
      }

      tot_inf <- sum(all_cases$new_cases_i)

      if (!quiet) {
        message(bad$bold("\tTotal infected:\t\t", scales::comma(tot_inf),
                " (", scales::percent(tot_inf/n_population, 0.1),
                "of the", scales::comma(n_population), "population)"))
      }

    } # end day loop


    # return all cases summary
    all_cases %>%
      mutate(
        runid = as.integer(runid),
        in_population = n_population,
        day = iteration * serial_interval,
        ) %>%
      return()

  } # end simulation

  # repeat the simulation:
  iterations <- map_dfr(1:run_simulations, simulate_covid_run) %>%
    group_by(runid) %>%
    mutate(total_cases_i = cumsum(new_cases_i),
           total_dead_i = cumsum(new_dead_i),
           total_vaccinated_i = cumsum(new_vaccinated_i),
           rt_i = new_local_cases_i / lag(new_cases_i), # exclude OS infections from denominator
           scenario = scenario) %>%
    relocate(scenario, runid, iteration, day, starts_with("new"), starts_with("total")) %>%
    mutate(in_R = R,
           in_vaccination_levels = list(vaccination_levels))

    return(iterations)

}
