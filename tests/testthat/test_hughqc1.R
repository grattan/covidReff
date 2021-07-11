

test_that("100x increase in population causes 100x vaccinated numbers but not case numbers mutatis", {
  skip_if_not_installed("withr")
  skip_if_not_installed("stats")
  library(dplyr)
  library(stats)
  withr::with_seed(1, {
    Ans100k <- simulate_covid(n_population = 100e3, quiet = TRUE, n_iterations = 50)
    Ans10M <- simulate_covid(n_population = 10e6, quiet = TRUE, n_iterations = 50)
    Compare <-
      inner_join(select(Ans100k, runid, day, in_population, total_cases_i, total_vaccinated1_i),
                 select(Ans10M,  runid, day, in_population, total_cases_i, total_vaccinated1_i),
                 by = c("runid", "day"))

    lm.cases <- lm(total_cases_i.y ~ total_cases_i.x, data = Compare)
    conf.cases <- confint(lm.cases)
    expect_lte(conf.cases["total_cases_i.x", "2.5 %"], 0)
    expect_gte(conf.cases["total_cases_i.x", "97.5 %"], 0)
  })
})

