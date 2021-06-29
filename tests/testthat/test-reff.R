# check:

test_that("simulation works", {

  testthat::expect_output(
    simulate_covid(r0 = 5,
               n_iterations = 2,
               simulations = 1,
               # vaccines:
               uniform_vaccination_rate = 0,
               vac_infection_rate = 0.2,
               vac_transmission_rate = 0.5,
               n_start_infected = 100,
               population_scale_factor = 10)
    )
})

test_that("get population rate works", {

  testthat::expect_gte(
      get_population_rate(age_rate = c(under12 = 0.00,
                                       under40 = 0.70,
                                       under60 = 0.90,
                                       under80 = 0.95,
                                       over80  = 0.95)),
      0.7 # 0.7003302
    )

  testthat::expect_equal(
      get_population_rate(age_rate = c(under12 = 0.7,
                                       under40 = 0.7,
                                       under60 = 0.7,
                                       under80 = 0.7,
                                       over80  = 0.7)),
      0.7)
})
