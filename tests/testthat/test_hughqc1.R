

test_that("100x increase in population causes 100x vaccinated numbers but not case numbers mutatis", {
  skip_if_not_installed("withr")
  skip_if_not_installed("stats")
  library(dplyr)
  library(stats)
  withr::with_seed(1, {
    Ans10k <- simulate_covid(n_population = 10e3, quiet = TRUE, run_simulations = 10)
    Ans1M <- simulate_covid(n_population = 1e6, quiet = TRUE, run_simulations = 10)
  })
    Compare <-
      inner_join(select(Ans10k, runid, day, in_population, total_cases_i, total_vaccinated1_i),
                 select(Ans1M,  runid, day, in_population, total_cases_i, total_vaccinated1_i),
                 by = c("runid", "day"))

    lm.cases <- lm(total_cases_i.y ~ total_cases_i.x, data = Compare)
    conf.cases <- confint(lm.cases)
    expect_gte(conf.cases["total_cases_i.x", 1], 0.75)
    expect_lte(conf.cases["total_cases_i.x", 2], 1.25)

    lm.cases <- lm(total_vaccinated1_i.y ~ total_vaccinated1_i.x, data = Compare)
    conf.cases <- confint(lm.cases)
    expect_gte(conf.cases["total_vaccinated1_i.x", 1], 90)
    expect_lte(conf.cases["total_vaccinated1_i.x", 2], 110)
  })
