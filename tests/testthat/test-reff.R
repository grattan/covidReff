# check:
a <-
simulate_covid(r0 = 4,
               n_iterations = 100,
               simulations = 2,
               # vaccines:
               uniform_vaccination_rate = 0.5,
               vac_infection_rate = 0.2,
               vac_transmission_rate = 0.5,
               n_start_infected = 100,
               population_scale_factor = 100)

  get_reff(r0 = 5,
           .n_iter = 5,
           population_vaccinated = 0.2,
           vac_infection_rate = 0.2,
           vac_transmission_rate = 0.5, .n_start = 100,
           .n_pop = 1e5)
