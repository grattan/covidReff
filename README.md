
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covidReff

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of `covidReff` is to simulate Covid outbreaks in a partially
vaccinated population.

This package is in development and should not be relied upon.

## Installation

The development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("grattan/covidReff")
```

## Usage

The `simulate_covid()` runs simulations of Covid spreading and returns a
`tibble` with the results for each simulation (`runid`) on each day.
Using the default settings:

``` r
sim_results <- simulate_covid()
#> Scenario: 1; run: 1
#>  Iteration: 1 (day 5)
#>      Vaccination rate: 0.503
#>      Maybe infected: 425
#>  Total infected: 349 (0.0%)
#> Scenario: 1; run: 1
#>  Iteration: 2 (day 10)
#>      Vaccination rate: 0.507
#>      Maybe infected: 1001
#>  Total infected: 904 (0.0%)
#> Scenario: 1; run: 1
#>  Iteration: 3 (day 15)
#>      Vaccination rate: 0.51
#>      Maybe infected: 2243
#>  Total infected: 2,242 (0.1%)
sim_results
#> # A tibble: 4 x 19
#> # Groups:   runid [1]
#>   scenario runid iteration   day new_cases_i new_hosp_i new_dead_i
#>      <dbl> <int>     <int> <dbl>       <dbl>      <dbl>      <dbl>
#> 1        1     1         0     0         100          0          0
#> 2        1     1         1     5         249          1          1
#> 3        1     1         2    10         555          7          0
#> 4        1     1         3    15        1338         30          1
#> # … with 12 more variables: new_vaccinated_i <dbl>, total_cases_i <dbl>,
#> #   total_hosp_i <dbl>, total_dead_i <dbl>, total_vaccinated_i <dbl>,
#> #   in_population <int>, rt_i <dbl>, reff <dbl>, in_R <dbl>,
#> #   in_vaccination_levels <list>, in_vac_infection_reduction <dbl>,
#> #   in_vac_transmission_reduction <dbl>
```

The key inputs for the `simulate_covid()` function are `R0` and
`vaccination_levels`:

``` r
# oh no
oh_no <- simulate_covid(R = 8, vaccination_levels = .5)
#> Scenario: 1; run: 1
#>  Iteration: 1 (day 5)
#>      Vaccination rate: 0.499
#>      Maybe infected: 756
#>  Total infected: 567 (0.0%)
#> Scenario: 1; run: 1
#>  Iteration: 2 (day 10)
#>      Vaccination rate: 0.503
#>      Maybe infected: 3400
#>  Total infected: 2,591 (0.1%)
#> Scenario: 1; run: 1
#>  Iteration: 3 (day 15)
#>      Vaccination rate: 0.507
#>      Maybe infected: 14764
#>  Total infected: 11,336 (0.4%)
oh_no
#> # A tibble: 4 x 19
#> # Groups:   runid [1]
#>   scenario runid iteration   day new_cases_i new_hosp_i new_dead_i
#>      <dbl> <int>     <int> <dbl>       <dbl>      <dbl>      <dbl>
#> 1        1     1         0     0         100          0          0
#> 2        1     1         1     5         467         46          5
#> 3        1     1         2    10        2024        195         16
#> 4        1     1         3    15        8745        861         72
#> # … with 12 more variables: new_vaccinated_i <dbl>, total_cases_i <dbl>,
#> #   total_hosp_i <dbl>, total_dead_i <dbl>, total_vaccinated_i <dbl>,
#> #   in_population <int>, rt_i <dbl>, reff <dbl>, in_R <dbl>,
#> #   in_vaccination_levels <list>, in_vac_infection_reduction <dbl>,
#> #   in_vac_transmission_reduction <dbl>
# okay!
okay <- simulate_covid(R = 2, vaccination_levels = .9)
#> Scenario: 1; run: 1
#>  Iteration: 1 (day 5)
#>      Vaccination rate: 0.9
#>      Maybe infected: 176
#>  Total infected: 162 (0.0%)
#> Scenario: 1; run: 1
#>  Iteration: 2 (day 10)
#>      Vaccination rate: 0.903
#>      Maybe infected: 81
#>  Total infected: 188 (0.0%)
#> Scenario: 1; run: 1
#>  Iteration: 3 (day 15)
#>      Vaccination rate: 0.903
#>      Maybe infected: 32
#>  Total infected: 203 (0.0%)
okay
#> # A tibble: 4 x 19
#> # Groups:   runid [1]
#>   scenario runid iteration   day new_cases_i new_hosp_i new_dead_i
#>      <dbl> <int>     <int> <dbl>       <dbl>      <dbl>      <dbl>
#> 1        1     1         0     0         100          0          0
#> 2        1     1         1     5          62          2          0
#> 3        1     1         2    10          26          0          0
#> 4        1     1         3    15          15          0          0
#> # … with 12 more variables: new_vaccinated_i <dbl>, total_cases_i <dbl>,
#> #   total_hosp_i <dbl>, total_dead_i <dbl>, total_vaccinated_i <dbl>,
#> #   in_population <int>, rt_i <dbl>, reff <dbl>, in_R <dbl>,
#> #   in_vaccination_levels <list>, in_vac_infection_reduction <dbl>,
#> #   in_vac_transmission_reduction <dbl>
```
