# run scripts to make datasets
library(tidyverse)

# Make data
list.files("data-raw", pattern = "\\.R", full.names = TRUE) %>%
  .[!str_detect(., "_run-data")] %>%
  purrr::walk(source)

# Export
usethis::use_data(
    pf_1_poi,
    pf_2_poi,
    pf_1_poh,
    pf_2_poh,
    pf_1_pod,
    pf_2_pod,
    pf_1_second_dose_wait_days,
    az_1_poi,
    az_2_poi,
    az_1_poh,
    az_2_poh,
    az_1_pod,
    az_2_pod,
    az_1_second_dose_wait_days,
    none_0_poi,
    none_0_poh,
    none_0_pod,
    none_0_second_dose_wait_days,
    hospital_rates,
    vaccine_names,
    auspop,
  internal = TRUE,
  overwrite = TRUE)
