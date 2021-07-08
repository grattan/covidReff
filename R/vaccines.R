# vaccine characteristics


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
