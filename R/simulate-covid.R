# Simulate COVID
library(tidyverse)
library(data.table)

simulate_covid <- function(
  # epidemiology
  r0 = 3 * 1.5, # r0 = 3; plus delta variant increases by 50%: https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/993232/S1272_LSHTM_Modelling_Paper_B.1.617.2.pdf
  # vaccination settings
  vaccination_levels = c(
    under12 = 0.00,
    under40 = 0.70,
    under50 = 0.90,
    under60 = 0.95,
    under80 = 0.95,
    over80  = 0.95),
  uniform_vaccination_rate = NULL,
  weekly_vaccinations = 0.01,            # additional % of the population vaccinated each week
  max_vaccination_rate = 0.95,

  # epidemiology of vaccinated people
  vac_infection_rate = 0.2,
  vac_transmission_rate = 0.5,
  vac_hospitalisation_reduction = 0.95, # Hospitalisation reduction when vaccinated GIVEN infection
  vac_death_reduction = 0.99,           # Death reduction when vaccinated GIVEN infection
  hospitalisation_per_death = 20,       # made this up; need to look into it
  max_hospitalisation_rate = 0.95,

  # population settings

  population_scale_factor = population_scale_factor, # 1=26m, 10=2.6m, 100=260k population
  n_start_infected = 1,
  p_max_infected = 0.8, # proportion who CAN get infected if it spreads; kinda like herd immunity level
  n_iterations =  3,
  simulations = 1,
  scenario = 1,
  return_iterations = TRUE, # otherwise provide a summary
  return_population = FALSE # full population summary
) {

  # internal settings:
  serial_interval <- 3.5 # days; https://www.medrxiv.org/content/10.1101/2021.06.04.21258205v1.full.pdf


  # function to estimate the Reff once (split this out)
  simulate_covid_run <- function(runid) {

    # Get Australia
    aus <- .read_demographics(uncounted = TRUE,
                              scale_factor = population_scale_factor) %>%
            as.data.table()

    # starting vaccination levels
    aus <-  aus %>%
     .[, is_vaccinated := runif(.N) <= .get_vaccination_level(age, vaccination_levels, uniform = uniform_vaccination_rate)] %>%
     .[is_vaccinated == TRUE, is_infected := FALSE] %>%
     .[is_vaccinated == FALSE, is_infected := .sample_fixed_TRUE(.N, n_start_infected)] %>%
     .[, newly_infected := is_infected]


    # starting conditions
    start_conditions <- tibble(
      iteration = 0L,
      new_cases = n_start_infected,
      new_hosp  = 0,
      new_dead  = 0,
      new_vaccinated = aus[, sum(is_vaccinated)])

    # loop over iterations
    for (t in seq_len(n_iterations)) {

      # at start of day, how many infected:
      n_infected_and_vaccinated <- aus[, sum(newly_infected & is_vaccinated)]
      n_infected_and_unvaccinated <- aus[, sum(newly_infected & !is_vaccinated)]

      # Number of infected due to transmission and r0 but not infection
      n_maybed_infected <- n_infected_and_vaccinated * r0 * vac_transmission_rate +
                           n_infected_and_unvaccinated * r0
      n_maybed_infected <- as.integer(n_maybed_infected)

      # put new people in contact with covid:
      aus[, maybe_infected := FALSE] %>%
        .[newly_infected == FALSE, maybe_infected := .sample_fixed_TRUE(.N, n_maybed_infected)]

      # Now if a person is vaccinated they are only infected if they have a
      # random number at least as unlikely as the infection rate
      aus[, newly_infected := FALSE] %>% # reset newly infected counter
        # if maybe infected: zero chance if previously infected; lower chance if vaccinated
        .[maybe_infected == TRUE,
          newly_infected := fcase(
            is_vaccinated == TRUE, runif(.N) <= vac_infection_rate,
            is_infected == TRUE, FALSE,
            is_vaccinated == FALSE & is_infected == FALSE, TRUE)] %>%
        .[, is_infected := newly_infected | is_infected]

      # Of the people who become infected, who requires hospitalisation, and
      # who will die?
      aus[newly_infected == TRUE,
          is_hosp := runif(.N) < covid_age_hospitalisation_prob(age, .vaccinated = is_vaccinated)] %>%
        .[newly_infected == TRUE,
          is_dead := runif(.N) < covid_age_death_prob(age, vaccinated = is_vaccinated)]

      # generate summary of new cases
      newly <- aus[newly_infected == TRUE]

      add_cases <- tibble(iteration = t,
                          new_cases = newly[, .N],
                          new_hosp  = newly[, sum(is_hosp)],
                          new_dead  = newly[, sum(is_dead)],
                          )

      if (t == 1) {
        all_cases <- start_conditions %>%
          bind_rows(add_cases)
      } else {
        all_cases <- all_cases %>%
          bind_rows(add_cases)
      }

    } # end day loop

    if (return_population) return(aus)

    # return all cases summary
    all_cases %>%
      mutate(runid = as.integer(runid),
             population_vaccination_rate = population_vaccination_rate) %>%
      return()


  }

  # repeat the simulation:
  iterations <- map_dfr(1:simulations, simulate_covid_run) %>%
    group_by(runid) %>%
    mutate(day = iteration * serial_interval,
           total_cases = cumsum(new_cases),
           total_hosp = cumsum(new_hosp),
           total_dead = cumsum(new_dead),
           rt = new_cases / lag(new_cases),
           reff = .calculate_reff(sum(new_cases), n_start_infected, n_iterations),
           scenario = scenario) %>%
    relocate(scenario, runid, iteration, day) %>%
    mutate(r0 = r0,
           population_vaccination_rate = population_vaccination_rate,
           vaccination_levels = list(vaccination_levels),
           vac_infection_rate = vac_infection_rate,
           vac_transmission_rate = vac_transmission_rate)

  # Print summary
  print(summary(iterations$reff))

  if (return_iterations) {
    return(iterations)
  }

  if (!return_iterations) {
    iterations %>%
      filter(iteration == max(iteration)) %>%
      select(-iteraction) %>%
      return()
  }

}

