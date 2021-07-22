

# Hopsitalisation function
covid_age_hospitalisation_prob <- function(.age,
                                           .vaccine,
                                           .dose,
                                           type = c("hosp_rate", "icu_rate")) {

  age10 <- floor(.age/10) + 1
  type <- type[1]

  # unvaccinated hospital rate based on the 2020-21 Australian data from
  # National Notifiable Diseases Surveillance System (2021)
  hr <- hospital_rates[[type]][age10]

  # add vaccine protection
  .vac_hospitalisation_reduction <- fcase(
    .vaccine == "pf" & .dose == 1L, pf_1_poh,
    .vaccine == "pf" & .dose == 2L, pf_2_poh,
    .vaccine == "az" & .dose == 1L, az_1_poh,
    .vaccine == "az" & .dose == 2L, az_2_poh,
    .vaccine == "none", 0
  )

  .vac_poi <- get_vaccine_poi(.vaccine, .dose)

  hr <- hr * (1 - .vac_hospitalisation_reduction) / (1 - .vac_poi)

  return(hr)
}


# IFR function by age
covid_age_death_prob <- function(.age,
                                 .vaccine = "none",
                                 .dose = 0,
                                 .treatment_improvement = 0.2,
                                 .max_death_rate = 0.40 # max death rate from Australian experience
) {

  age <- as.numeric(.age)

  # get death rate from Levin at al https://pubmed.ncbi.nlm.nih.gov/33289900/
  ifr <- 10^(-3.27 + 0.0524 * age) / 100

  # cap base death rate (on advice from MK)
  ifr <- if_else(ifr > .max_death_rate, .max_death_rate, ifr)

  # add treatment improvement (on advice from MK)
  ifr <- ifr * (1 - .treatment_improvement)

  # add vaccine protection
  .vac_death_reduction <- fcase(
      .vaccine == "pf" & .dose == 1L, pf_1_pod,
      .vaccine == "pf" & .dose == 2L, pf_2_pod,
      .vaccine == "az" & .dose == 1L, az_1_pod,
      .vaccine == "az" & .dose == 2L, az_2_pod,
      .vaccine == "none", 0
    )

  .vac_poi <- get_vaccine_poi(.vaccine, .dose)

  ifr <- ifr * (1 - .vac_death_reduction) / (1 - .vac_poi)

  return(ifr)

}


get_vaccine_poi <- function(.vaccine, .dose) {
  fcase(
    .vaccine == "pf" & .dose == 1L, pf_1_poi,
    .vaccine == "pf" & .dose == 2L, pf_2_poi,
    .vaccine == "az" & .dose == 1L, az_1_poi,
    .vaccine == "az" & .dose == 2L, az_2_poi,
    .vaccine == "none", 0
  )
}
