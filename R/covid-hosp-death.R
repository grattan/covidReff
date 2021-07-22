

# Protection against infection
get_vaccine_poi <- function(.vaccine, .dose) {
  fcase(
    .vaccine == "pf" & .dose == 1L, pf_1_poi,
    .vaccine == "pf" & .dose == 2L, pf_2_poi,
    .vaccine == "az" & .dose == 1L, az_1_poi,
    .vaccine == "az" & .dose == 2L, az_2_poi,
    .vaccine == "none", 0
  )
}



# Hopsitalisation function
get_covid_hospitalisation <- function(.age,
                                      .vaccine = "none",
                                      .dose = 0,
                                      type = c("hosp_rate", "icu_rate")) {

  .age <- if_else(.age == 100, 99, .age)

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


# Get length of stay
get_covid_los <- function(use_icu,
                          use_ventilation,
                          return_los = c("hosp_los", "icu_los"),
                          max_days = 60) {

  return_los <- return_los[1]

  l <- length(use_icu)

  # from Burrell et al (2021; table 3)

  hosp_los25 <-  8.6     # uses non-icu
  hosp_los50 <- 14.2     # uses icu
  hosp_los75 <- 21.1     # uses icu and ventilator

  icu_los25 <-  2.4      # no ventilator
  icu_los50 <-  5.9
  icu_los75 <- 11.1      # uses ventilator

  vent_los25 <-  4.0
  vent_los50 <-  8.0
  vent_los75 <- 17.0


  # A person who uses ICU, ventilators will have a longer hospital stay
  if (return_los == "hosp_los") {

    ret <- fcase(
             !use_icu, rlnorm(l, log(hosp_los25), 0.5),
              use_icu & !use_ventilation, rlnorm(l, log(hosp_los50), 0.5),
              use_icu &  use_ventilation, rlnorm(l, log(hosp_los75), 0.5)
            )

  } else if (return_los == "icu_los") {

    ret <- fcase(
            !use_icu, 0,
             use_icu & !use_ventilation, rlnorm(l, log(icu_los25), 0.5),
             use_icu &  use_ventilation, icu_los50 + rlnorm(l, log(vent_los50), 1)
            )

  }


  ret <- as.integer(ret)

  return(ret)

}

# IFR function by age
get_covid_death <- function(.age,
                            .vaccine = "none",
                            .dose = 0,
                            .treatment_improvement = 0.2,
                            .max_death_rate = 0.40 # max death rate from Australian experience (see hospital_rates data frame)
) {

  age <- as.numeric(.age)

  # death rate from Levin at al https://pubmed.ncbi.nlm.nih.gov/33289900/
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
