library(data.table)
library(tidyverse)
library(zoo)

vaccine_efficacy_raw <- read_csv("data-raw/data/vaccine_efficacy.csv") %>%
  janitor::clean_names() %>%
  rename(protection_from = type,
         vaccine_dose = dose,
         day = days)

vaccine_efficacy <- vaccine_efficacy_raw %>%
  mutate(day = if_else(day == 0, 1, day),
         efficacy = efficacy / 100,
         protection_type = case_when(
           protection_from == "Infection" ~ "poi",
           protection_from == "Hospitalization" ~ "poh"),
         vaccine_dose = as.integer(vaccine_dose),
         vaccine_type = case_when(
           manufacturer == "Pfizer" ~ "pf",
           manufacturer == "AZ" ~ "az")
         ) %>%
  select(protection_type, vaccine_type, vaccine_dose, day, efficacy, source)


usethis::use_data(vaccine_efficacy, overwrite = TRUE)

# expand and linearly interpolate
vaccine_efficacy_days <- crossing(
    vaccine_type = c("pf", "az"),
    protection_type = c("poi", "poh"),
    vaccine_dose = c(1L, 2L),
    day = 1:600) %>%
  left_join(vaccine_efficacy) %>%
  group_by(vaccine_type, protection_type, vaccine_dose) %>%
  mutate(efficacy = zoo::na.approx(efficacy, rule = 2))


ved_poi_pf1 <- vaccine_efficacy_days %>%
  filter(protection_type == "poi", vaccine_type == "pf", vaccine_dose == 1) %>%
  pull(efficacy)

ved_poi_pf2 <- vaccine_efficacy_days %>%
  filter(protection_type == "poi", vaccine_type == "pf", vaccine_dose == 2) %>%
  pull(efficacy)

ved_poi_az1 <- vaccine_efficacy_days %>%
  filter(protection_type == "poi", vaccine_type == "az", vaccine_dose == 1) %>%
  pull(efficacy)

ved_poi_az2 <- vaccine_efficacy_days %>%
  filter(protection_type == "poi", vaccine_type == "az", vaccine_dose == 2) %>%
  pull(efficacy)



ved_poh_pf1 <- vaccine_efficacy_days %>%
  filter(protection_type == "poh", vaccine_type == "pf", vaccine_dose == 1) %>%
  pull(efficacy)

ved_poh_pf2 <- vaccine_efficacy_days %>%
  filter(protection_type == "poh", vaccine_type == "pf", vaccine_dose == 2) %>%
  pull(efficacy)

ved_poh_az1 <- vaccine_efficacy_days %>%
  filter(protection_type == "poh", vaccine_type == "az", vaccine_dose == 1) %>%
  pull(efficacy)

ved_poh_az2 <- vaccine_efficacy_days %>%
  filter(protection_type == "poh", vaccine_type == "az", vaccine_dose == 2) %>%
  pull(efficacy)

ved_list <- list(
  ved_poi_pf1 = ved_poi_pf1,
  ved_poi_pf2 = ved_poi_pf2,
  ved_poi_az1 = ved_poi_az1,
  ved_poi_az2 = ved_poi_az2,
  ved_poh_pf1 = ved_poh_pf1,
  ved_poh_pf2 = ved_poh_pf2,
  ved_poh_az1 = ved_poh_az1,
  ved_poh_az2 = ved_poh_az2
)

usethis::use_data(ved_list, overwrite = TRUE)
