

# Hopsitalisation function
covid_age_hospitalisation_prob <- function(.age = 50, .vaccinated = FALSE,
                                           .hospitalisation_per_death = 20,
                                           .max_hospitalisation_rate = 0.90,
                                           .vac_hospitalisation_reduction = 0.95) {

  hr <- covid_age_death_prob(.age, vaccinated = .vaccinated) * .hospitalisation_per_death

  hr <- if_else(hr > .max_hospitalisation_rate, .max_hospitalisation_rate, hr)

  hr <- if_else(.vaccinated, hr * (1 - .vac_hospitalisation_reduction), hr)

  return(hr)
}


# IFR function by age
covid_age_death_prob <- function(age = 50,
                                 vaccinated = FALSE,
                                 .vac_death_reduction = 0.99,
                                 .treatment_reduction = FALSE,
                                 .max_death_rate = 0.28 # 90-year-old death rate as per Gideon
) {

  age <- as.numeric(age)

  ifr <- 10^(-3.27 + 0.0524 * age) / 100 # from Levin at al https://pubmed.ncbi.nlm.nih.gov/33289900/

  ifr <- if_else(ifr > .max_death_rate, .max_death_rate, ifr)

  if (.treatment_reduction) ifr <- ifr * (1 - 0.2)

  ifr <- if_else(vaccinated, ifr * (1 - .vac_death_reduction), ifr)

  return(ifr)

}
