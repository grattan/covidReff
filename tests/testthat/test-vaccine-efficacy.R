# Test vaccine efficacy


test_that("get_vaccine_efficacy returns correct values", {

  test_all <- vaccine_efficacy %>%
    ungroup() %>%
    mutate(efficacy = if_else(day == 0, 0, efficacy)) %>%
    mutate(efficacy_calc = get_vaccine_efficacy(protection_against = protection_type,
                                                vaccine_type = vaccine_type,
                                                vaccine_dose = vaccine_dose,
                                                days_since_dosage = day),
           is_same = efficacy_calc == efficacy)

  expect_true(all(test_all$is_same))

})


test_that("out of sample takes most recent value", {

  same_300_600 <- get_vaccine_efficacy(protection_against = "poh",
                                       vaccine_type = c("az", "az", "pf", "pf"),
                                       vaccine_dose = rep(c(2, 2), 2),
                                       days_since_dosage = rep(c(300, 600), 2))

  expect_equal(same_300_600[1], same_300_600[2])
  expect_equal(same_300_600[3], same_300_600[4])

})


test_that("no vaccine offers zero proection", {

  expect_equal(get_vaccine_efficacy(protection_against = "poi", vaccine_type = "none", vaccine_dose = 0, days_since_dosage = 0),
               0)

  expect_equal(get_vaccine_efficacy(protection_against = "poi", vaccine_type = "pf", vaccine_dose = 0, days_since_dosage = 0),
               0)

  expect_equal(get_vaccine_efficacy(protection_against = "poh", vaccine_type = "none", vaccine_dose = 1, days_since_dosage = 0),
               0)
})


# test timing of big one

test_that("retrieval of vaccine effectiveness isn't TOO damn slow", {

  skip_on_ci()

  test_big <- vaccine_efficacy %>%
    ungroup() %>%
    sample_n(1e6, replace = TRUE)

  speed_test <- microbenchmark::microbenchmark(
    time_test = mutate(test_big,
           efficacy_calc = get_vaccine_efficacy(protection_against = protection_type,
                                                vaccine_type = vaccine_type,
                                                vaccine_dose = vaccine_dose,
                                                days_since_dosage = day)),
    times = 5
  )

  # should be quicker than 4 seconds
  expect_lte(mean(speed_test$time/1e9), 4)

})
