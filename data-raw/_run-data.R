# run scripts to make datasets
library(tidyverse)

# Make data
list.files("data-raw", full.names = TRUE) %>%
  .[!str_detect(., "_run-data")] %>%
  purrr::walk(source)

# Export
usethis::use_data(vaccine_characteristics,
                  vaccine_names,
                  auspop,
                  internal = TRUE,
                  overwrite = TRUE)
