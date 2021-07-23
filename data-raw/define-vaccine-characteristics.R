# Define vaccine characteristics

vaccine_names <- c("pf", "az", "none")

# sources:
# EU: https://www.ecdc.europa.eu/sites/default/files/documents/Partial%20COVID%20vaccination%20and%20heterologous%20vacc%20schedule%20-%2022%20July%202021.pdf
# NEJM: https://www.nejm.org/doi/full/10.1056/NEJMoa2108891?query=featured_home

# Pfizer
pf_1_poi <- 0.30 # source: NEJM
pf_2_poi <- 0.90 # source: EU Table 1
pf_1_poh <- 0.50 # source: EU Table 2
pf_2_poh <- 0.98 # source: EU Table 2
pf_1_pod <- 0.65 # source: EU Table 3
pf_2_pod <- 0.99 # source: EU Table 3
pf_1_second_dose_wait_days <- 21 # source: ?

# AstraZeneca
az_1_poi <- 0.35 # PHE
az_2_poi <- 0.67 # PHE
az_1_poh <- 0.30 # ?
az_2_poh <- 0.92 # PHE
az_1_pod <- 0.50 # ?
az_2_pod <- 0.99 # ?
az_1_second_dose_wait_days <- 90 # source: ?

# None :(
none_0_poi <- 0
none_0_poh <- 0
none_0_pod <- 0
none_0_second_dose_wait_days <- 0
