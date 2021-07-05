# vaccine characteristics

.get_vaccine_characteristic <- function(vaccine, dose = NA, characteristic) {

  purrr::pmap_dbl(
    list(vaccine,
         dose,
         characteristic),
    function(a, b, c) {

      ret <- vaccine_characteristics %>%
        filter(vaccine_name == a,
               after_dose == b,
               varname == c) %>%
        pull(value)

      if (purrr::is_empty(ret)) ret <- 0

      return(ret)

    }
  )


}


.get_vaccination_type <- function(age, over60az, under60az) {

  rand <- runif(length(age))

  ret <- fcase(
    # under 60s
    age <  60 & rand <  under60az, "az",
    age <  60 & rand >= under60az, "pf",
    # over 60s
    age >= 60 & rand <  over60az, "az",
    age >= 60 & rand >= over60az, "pf"
  ) %>%
    factor(levels = vaccine_names)

  return(ret)
}
