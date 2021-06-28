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
