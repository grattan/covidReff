# Define vaccine characteristics

pf_1_poi <- 0.33 # source: PHE
pf_2_poi <- 0.85 # source: PHE
pf_1_poh <- 0.50 # source: ?
pf_2_poh <- 0.96 # source: PHE
pf_1_pod <- 0.60 # source: ?
pf_2_pod <- 0.99 # source: ?
pf_1_second_dose_wait_days <- 21 # source: ?
az_1_poi <- 0.33 # PHE
az_2_poi <- 0.60 # PHE
az_1_poh <- 0.30 # ?
az_2_poh <- 0.92 # PHE
az_1_pod <- 0.50 # ?
az_2_pod <- 0.99 # ?
az_1_second_dose_wait_days <- 90 # source: ?

none_0_poi <- 0
none_0_poh <- 0
none_0_pod <- 0
none_0_second_dose_wait_days <- 0

vaccine_names <- c("pf", "az", "none")
