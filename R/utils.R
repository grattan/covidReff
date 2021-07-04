
# Reff calculation
.calculate_reff <- function(total_cases, initial_cases, iterations) {
  (total_cases / initial_cases)^(1/iterations) - 1
}

# vaccine rate function ------------------------------------------------------
.get_vaccination_level <- function(age,
                                   levels = NULL) {

  if (length(levels) != 1 & length(levels) != 10) {
    stop("Vaccination levels must be either a vector of length 1 or 10")
  }

  if (length(levels) == 1) return(levels)

  fcase(
      age <=  10, levels[1],
      age <=  20, levels[2],
      age <=  30, levels[3],
      age <=  40, levels[4],
      age <=  50, levels[5],
      age <=  60, levels[6],
      age <=  70, levels[7],
      age <=  80, levels[8],
      age <=  90, levels[9],
      age >   90, levels[10]
    )
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
                               n_pop = 2.6e6
                               ) {

  scale_factor <- n_pop / sum(auspop$n)

  ret <- auspop %>%
    mutate(n = round(n * scale_factor))


  if (uncounted) {
    ret <- ret %>%
      uncount() %>%
      select(age)
  }

  return(ret)

}
