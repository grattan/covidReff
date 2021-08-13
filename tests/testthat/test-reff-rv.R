# check:
# devtools::load_all()

# Beta, low level of introduced cases
sim_beta_dist_low_cases <- simulate_covid(
  R = 5,
  R_dist = "beta",
  n_iterations = 10,
  run_simulations = 20,
  vaccination_levels = 0.75,
  n_start_infected = 1,
  n_daily_introductions = 1,
  n_population = 2.6e5,
  quiet = TRUE
  )

beta_low_cases_cases <- sim_beta_dist_low_cases %>%
  dplyr::filter(day == max(day)) %>%
  dplyr::pull(total_cases_i)

beta_low_cases_spread <- max(beta_low_cases_cases) / min(beta_low_cases_cases)


# Beta, high level of introduced cases
sim_beta_dist_high_cases <- simulate_covid(
  R = 5,
  R_dist = "beta",
  n_iterations = 10,
  run_simulations = 20,
  vaccination_levels = 0.75,
  n_start_infected = 100,
  n_daily_introductions = 100,
  n_population = 2.6e5,
  quiet = TRUE
)

beta_high_cases_cases <- sim_beta_dist_high_cases %>%
  dplyr::filter(day == max(day)) %>%
  dplyr::pull(total_cases_i)

beta_high_cases_spread <- max(beta_high_cases_cases) / min(beta_high_cases_cases)



# Pois, low level of introduced cases
sim_pois_dist_low_cases <- simulate_covid(
  R = 5,
  R_dist = "pois",
  n_iterations = 10,
  run_simulations = 10,
  vaccination_levels = 0.75,
  n_start_infected = 1,
  n_daily_introductions = 1,
  n_population = 2.6e5,
  quiet = TRUE
)

pois_low_cases_cases <- sim_pois_dist_low_cases %>%
  dplyr::filter(day == max(day)) %>%
  dplyr::pull(total_cases_i)

pois_low_cases_spread <- max(pois_low_cases_cases) / min(pois_low_cases_cases)



# Pois, high level of introduced cases
sim_pois_dist_high_cases <- simulate_covid(
  R = 5,
  R_dist = "pois",
  n_iterations = 10,
  run_simulations = 10,
  vaccination_levels = 0.75,
  n_start_infected = 100,
  n_daily_introductions = 100,
  n_population = 2.6e5,
  quiet = TRUE
)

pois_high_cases_cases <- sim_pois_dist_high_cases %>%
  dplyr::filter(day == max(day)) %>%
  dplyr::pull(total_cases_i)

pois_high_cases_spread <- max(pois_high_cases_cases) / min(pois_high_cases_cases)





test_that("highest and lowest beta values are significantly different", {
  expect_gt(beta_low_cases_spread, 7)
  expect_lt(beta_high_cases_spread, 1.5)
  expect_lt(pois_high_cases_spread, beta_high_cases_spread)
  expect_lt(pois_low_cases_spread, beta_low_cases_spread)
})

