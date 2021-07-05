# Define vaccine characteristics

vaccine_characteristics <- tibble::tribble(
  ~vaccine_name, ~after_dose, ~varname,               ~value, ~source,
  "pf",                   1L,    "poi",                 0.33, "PHE",
  "pf",                   2L,    "poi",                 0.85, "PHE",
  "pf",                   1L,    "poh",                 0.50, "?",
  "pf",                   2L,    "poh",                 0.96, "PHE",
  "pf",                   1L,    "pod",                 0.60, "?",
  "pf",                   2L,    "pod",                 0.99, "?",
  "pf",                   1L,   "second_dose_wait_days",  21, "?",

  "az",                   1L,    "poi",                 0.33, "PHE",
  "az",                   2L,    "poi",                 0.60, "PHE",
  "az",                   1L,    "poh",                 0.30, "?",
  "az",                   2L,    "poh",                 0.92, "PHE",
  "az",                   1L,    "pod",                 0.50, "?",
  "az",                   2L,    "pod",                 0.99, "?",
  "az",                   1L,   "second_dose_wait_days",  90, "?",

) %>%
  mutate(vaccine_name = fct_inorder(vaccine_name))

vaccine_names <- unique(vaccine_characteristics$vaccine_name)
