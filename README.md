
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
#> Scenario 1   |   run 1
#> 
#> Iteration:  1  ( day  5 )            
#>  Vaccination rate, dose 1:  52.0%
#>  Vaccination rate, dose 2:  50.5%
#>  Maybe infected:      42
#>  New cases:           16 ( 38.1%  of maybe infected)
#>  New hospitalisated:      1
#>  New dead:                0
#>  New vaccinated:      714
#>  Total first dose:    3,039
#>  Total second dose:   101,685
#>  Total Pfizer:        60,849
#>  Total AZ:            43,875
#>  Total infected:      26  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:  52.4%
#>  Vaccination rate, dose 2:  50.8%
#>  Maybe infected:      69
#>  New cases:           35 ( 50.7%  of maybe infected)
#>  New hospitalisated:      2
#>  New dead:                0
#>  New vaccinated:      714
#>  Total first dose:    3,011
#>  Total second dose:   102,401
#>  Total Pfizer:        61,537
#>  Total AZ:            43,875
#>  Total infected:      61  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:  52.7%
#>  Vaccination rate, dose 2:  51.2%
#>  Maybe infected:      150
#>  New cases:           80 ( 53.3%  of maybe infected)
#>  New hospitalisated:      2
#>  New dead:                0
#>  New vaccinated:      714
#>  Total first dose:    2,953
#>  Total second dose:   103,142
#>  Total Pfizer:        62,220
#>  Total AZ:            43,875
#>  Total infected:      141  ( 0.1% of the 199,997 population)
```

The resulting `tibble` is:

``` r
sim_results
#> # A tibble: 4 x 21
#> # Groups:   runid [1]
#>   scenario runid iteration   day new_cases_i new_hosp_i new_dead_i
#>   <chr>    <int>     <int> <dbl>       <dbl>      <dbl>      <dbl>
#> 1 1            1         0     0          10          0          0
#> 2 1            1         1     5          16          1          0
#> 3 1            1         2    10          35          2          0
#> 4 1            1         3    15          80          2          0
#> # … with 14 more variables: new_vaccinated_i <dbl>, new_maybe_infected_i <int>,
#> #   total_vaccinated1_i <int>, total_vaccinated2_i <int>, total_pf_i <int>,
#> #   total_az_i <int>, total_cases_i <dbl>, total_hosp_i <dbl>,
#> #   total_dead_i <dbl>, total_vaccinated_i <dbl>, in_population <int>,
#> #   rt_i <dbl>, in_R <dbl>, in_vaccination_levels <list>
```

The key inputs of the `simulate_covid()` function – among many – are the
reproduction value of the virus in a ‘relaxed’ Australian society, `R`,
and the proportion of the **whole** population that are vaccinated,
`vaccination_levels`.

``` r
sim_r8_50 <- simulate_covid(R = 8, 
                            vaccination_levels = .5)
#> Scenario 1   |   run 1
#> 
#> Iteration:  1  ( day  5 )            
#>  Vaccination rate, dose 1:  51.7%
#>  Vaccination rate, dose 2:  50.2%
#>  Maybe infected:      76
#>  New cases:           32 ( 42.1%  of maybe infected)
#>  New hospitalisated:      1
#>  New dead:                0
#>  New vaccinated:      714
#>  Total first dose:    3,052
#>  Total second dose:   100,990
#>  Total Pfizer:        70,828
#>  Total AZ:            33,214
#>  Total infected:      42  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:  52.0%
#>  Vaccination rate, dose 2:  50.5%
#>  Maybe infected:      252
#>  New cases:           130 ( 51.6%  of maybe infected)
#>  New hospitalisated:      18
#>  New dead:                1
#>  New vaccinated:      714
#>  Total first dose:    3,000
#>  Total second dose:   101,724
#>  Total Pfizer:        71,510
#>  Total AZ:            33,214
#>  Total infected:      172  ( 0.1% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:  52.4%
#>  Vaccination rate, dose 2:  50.9%
#>  Maybe infected:      996
#>  New cases:           538 ( 54.0%  of maybe infected)
#>  New hospitalisated:      56
#>  New dead:                2
#>  New vaccinated:      714
#>  Total first dose:    2,963
#>  Total second dose:   102,454
#>  Total Pfizer:        72,203
#>  Total AZ:            33,214
#>  Total infected:      710  ( 0.4% of the 199,997 population)
```

The `vaccination_levels` is provided as either a single numeric for
vaccination levels uniformly-distributed across age groups (as above),
or you can provide a numeric vector of length `10` describing the
vaccination rates for age groups `1-10`, `11-20`, `21-30`, …, `91-100`.

``` r
sim_r4_50 <- simulate_covid(
  R = 4, 
  vaccination_levels = c(
    "0-10"  = 0.00,
    "11-20" = 0.40,
    "21-30" = 0.60,
    "31-40" = 0.60,
    "41-50" = 0.60,
    "51-60" = 0.70,
    "61-70" = 0.90,
    "71-80" = 0.90,
    "81-90" = 0.95,
    "91+"   = 0.95)
  )
#> Scenario 1   |   run 1
#> 
#> Iteration:  1  ( day  5 )            
#>  Vaccination rate, dose 1:  58.5%
#>  Vaccination rate, dose 2:  57.0%
#>  Maybe infected:      38
#>  New cases:           18 ( 47.4%  of maybe infected)
#>  New hospitalisated:      0
#>  New dead:                0
#>  New vaccinated:      714
#>  Total first dose:    2,977
#>  Total second dose:   114,803
#>  Total Pfizer:        71,295
#>  Total AZ:            46,485
#>  Total infected:      28  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:  58.9%
#>  Vaccination rate, dose 2:  57.4%
#>  Maybe infected:      72
#>  New cases:           35 ( 48.6%  of maybe infected)
#>  New hospitalisated:      0
#>  New dead:                0
#>  New vaccinated:      714
#>  Total first dose:    2,960
#>  Total second dose:   115,495
#>  Total Pfizer:        71,970
#>  Total AZ:            46,485
#>  Total infected:      63  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:  59.2%
#>  Vaccination rate, dose 2:  57.7%
#>  Maybe infected:      138
#>  New cases:           68 ( 49.3%  of maybe infected)
#>  New hospitalisated:      3
#>  New dead:                0
#>  New vaccinated:      714
#>  Total first dose:    2,912
#>  Total second dose:   116,211
#>  Total Pfizer:        72,638
#>  Total AZ:            46,485
#>  Total infected:      131  ( 0.1% of the 199,997 population)
sim_r4_50
#> # A tibble: 4 x 21
#> # Groups:   runid [1]
#>   scenario runid iteration   day new_cases_i new_hosp_i new_dead_i
#>   <chr>    <int>     <int> <dbl>       <dbl>      <dbl>      <dbl>
#> 1 1            1         0     0          10          0          0
#> 2 1            1         1     5          18          0          0
#> 3 1            1         2    10          35          0          0
#> 4 1            1         3    15          68          3          0
#> # … with 14 more variables: new_vaccinated_i <dbl>, new_maybe_infected_i <int>,
#> #   total_vaccinated1_i <int>, total_vaccinated2_i <int>, total_pf_i <int>,
#> #   total_az_i <int>, total_cases_i <dbl>, total_hosp_i <dbl>,
#> #   total_dead_i <dbl>, total_vaccinated_i <dbl>, in_population <int>,
#> #   rt_i <dbl>, in_R <dbl>, in_vaccination_levels <list>
```
