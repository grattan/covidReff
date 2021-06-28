
# Reff calculation
.calculate_reff <- function(total_cases, initial_cases, iterations) {
  (total_cases / initial_cases)^(1/iterations) - 1
}

# vaccine rate function ------------------------------------------------------
.get_vaccination_level <- function(age,
                                   levels = NULL,
                                   uniform = NULL) {

  if (!is.null(uniform)) return(uniform)

  if (is.null(uniform)) {
    fcase(
      age <  12, levels["under12"],
      age <  40, levels["under40"],
      age <  50, levels["under50"],
      age <  60, levels["under60"],
      age <  80, levels["under80"],
      age >= 80, levels["over80"]
    )
  }
}

# helper function
.sample_fixed_TRUE <- function(n, nTRUE) {
  nFALSE <- n - nTRUE
  if (nTRUE >= n) {
    return(rep(TRUE, n))
  }
  if (nFALSE >= n) {
    return(rep(FALSE, n))
  }

  out <- sample(rep(c(FALSE, TRUE),
                    c(nFALSE, nTRUE)))

  out
}


.read_demographics <- function(uncounted = TRUE,
                               scale_factor = 1 # 1 is unscaled
                               ) {
  load("data/auspop.rda")

  if (uncounted) {
    auspop <- auspop %>%
      count(age, wt = n) %>%
      mutate(n = round(n / scale_factor)) %>%
      uncount() %>%
      select(age)
  }

  return(auspop)

}
