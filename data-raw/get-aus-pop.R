## code to prepare `DATASET` dataset goes here
library(tidyverse)
library(readabs)

abs_raw <- read_abs("3101.0", "59")

auspop <- abs_raw %>%
  filter(date == max(date, na.rm = TRUE)) %>%
  separate_series() %>%
  select(gender = series_2,
         age = series_3,
         n = value) %>%
  filter(gender == "Persons") %>% # drop gender
  select(-gender) %>%
  mutate(age = if_else(age == "100 and over", 100, as.numeric(age)))

usethis::use_data(auspop, overwrite = TRUE, internal = TRUE)
