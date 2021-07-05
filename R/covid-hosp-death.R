

# Hopsitalisation function
covid_age_hospitalisation_prob <- function(.age,
                                           .vaccine = "none",
                                           .dose = 0,
                                           .hospitalisation_per_death = 20,
                                           .max_hospitalisation_rate = 0.90) {

  hr <- covid_age_death_prob(.age, .vaccine = "none") * .hospitalisation_per_death

  hr <- if_else(hr > .max_hospitalisation_rate, .max_hospitalisation_rate, hr)

  # add vaccine protection
  .vac_hospitalisation_reduction <- .get_vaccine_characteristic(
    vaccine = .vaccine, dose = .dose, characteristic = "poh"
  )

  hr <- hr * (1 - .vac_hospitalisation_reduction)

  return(hr)
}


# IFR function by age
covid_age_death_prob <- function(.age,
                                 .vaccine = "none",
                                 .dose = 0,
                                 .treatment_improvement = 0.2,
                                 .max_death_rate = 0.28 # 90-year-old death rate as per Gideon
) {

  age <- as.numeric(.age)

  # get death rate from Levin at al https://pubmed.ncbi.nlm.nih.gov/33289900/
  ifr <- 10^(-3.27 + 0.0524 * age) / 100

  # cap base death rate (on advice from MK)
  ifr <- if_else(ifr > .max_death_rate, .max_death_rate, ifr)

  # add treatment improvement (on advice from MK)
  ifr <- ifr * (1 - .treatment_improvement)

  # add vaccine protection
  .vac_death_reduction <- .get_vaccine_characteristic(
    vaccine = .vaccine, dose = .dose, characteristic = "pod"
    )

  ifr <- ifr * (1 - .vac_death_reduction)

  return(ifr)

}
