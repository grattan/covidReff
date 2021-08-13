# check:
# devtools::load_all()

# Beta, low level of introduced cases

simulate_dist_spreads <- function(dist, cases) {

  data <- simulate_covid(
    R = 5,
    R_dist = dist,
    n_iterations = 5,
    run_simulations = 20,
    vaccination_levels = 0.50,
    n_start_infected = cases,
    n_daily_introductions = cases,
    n_population = 2.6e5,
    quiet = TRUE
    )

  cases <- data %>%
    dplyr::filter(day == max(day)) %>%
    dplyr::pull(total_cases_i)

  spread <- max(cases) / min(cases)

  return(list(data = data,
              cases = cases,
              spread = spread)
         )
}

# Beta, high level of introduced cases
sim_beta_dist_low_cases <- simulate_dist_spreads("beta", 1)
sim_beta_dist_high_cases <- simulate_dist_spreads("beta", 100)
sim_pois_dist_low_cases <- simulate_dist_spreads("pois", 1)
sim_pois_dist_high_cases <- simulate_dist_spreads("pois", 100)


test_that("beta and poisson values are significantly different", {
  expect_gt(sim_beta_dist_low_cases$spread, sim_beta_dist_high_cases$spread)
  expect_lt(sim_pois_dist_low_cases$spread, sim_beta_dist_low_cases$spread)
  expect_lt(sim_pois_dist_high_cases$spread, sim_beta_dist_high_cases$spread)
})

