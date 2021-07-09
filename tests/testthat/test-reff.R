# check:
# devtools::load_all()

zero_vac_sim_R5 <- simulate_covid(
  R = 5,
  n_iterations = 2,
  run_simulations = 1,
  vaccination_levels = 0,
  vac_transmission_reduction = 0.5,
  n_start_infected = 5,
  n_population = 26000,
  quiet = TRUE
  )

# 85% w kids
vacc85_kids <- c(
  "0-10"  = 0.80,
  "11-20" = 0.80,
  "21-30" = 0.75,
  "31-40" = 0.85,
  "41-50" = 0.90,
  "51-60" = 0.90,
  "61-70" = 0.90,
  "71-80" = 0.95,
  "81-90" = 0.95,
  "91+"   = 0.95)

high_vac_sim_R5 <- simulate_covid(
  R = 5,
  n_iterations = 5,
  run_simulations = 5,
  vaccination_levels = vacc85_kids,
  vac_transmission_reduction = 0.5,
  n_start_infected = 5,
  n_population = 26000,
  quiet = TRUE
  )


stagger <- simulate_covid(
  n_iterations = 2,
  run_simulations = 3,
  stagger_simulations = 5,
  n_population = 26000,
  quiet = TRUE
)


test_that("simulation returns sensible results", {

  # reff
  expect_equal(max(zero_vac_sim_R5$rt_i, na.rm = TRUE), 5)
  expect_lt(high_vac_sim_R5$rt_i[2], 2)
  expect_equal(nrow(zero_vac_sim_R5), 2 + 1)
  expect_equal(ncol(zero_vac_sim_R5), 23)
  expect_equal(zero_vac_sim_R5$new_cases_i[1], 5)
})


test_that("staggering works", {
  expect_equal(stagger$day[[4]], 5)
  expect_equal(stagger$day[[7]], 10)
})


test_that("get population rate works", {

  expect_gte(
      get_population_rate(
        age_rate = c("0-10"  = 0.00,
                     "11-20" = 0.20,
                     "21-30" = 0.40,
                     "31-40" = 0.50,
                     "41-50" = 0.60,
                     "51-60" = 0.70,
                     "61-70" = 0.90,
                     "71-80" = 0.90,
                     "81-90" = 0.95,
                     "91+"   = 0.95)),
      0.5 # 0.502982
    )

  expect_equal(get_population_rate(age_rate = rep(0.7, 10)),  0.7)

  expect_error(simulate_covid(vaccination_levels = c(0.1, 0.2)))

})


test_that("death probabilities are as expected", {

  expect_equal(
    covid_age_death_prob(100,
                         .treatment_improvement = 0,
                         .max_death_rate = 0.28),
    0.28
  )

  expect_equal(
    covid_age_death_prob(100,
                         .treatment_improvement = 0.2,
                         .max_death_rate = 0.28),
    0.224
  )

})


