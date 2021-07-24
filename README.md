
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covidReff

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![R build
status](https://github.com/grattan/covidReff/workflows/R-CMD-check/badge.svg)](https://github.com/grattan/covidReff/actions)
<!-- badges: end -->

The goal of `covidReff` is to simulate Covid outbreaks in a partially
vaccinated population.

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
#>  Vaccination rate, dose 1:   51.2%
#>  Vaccination rate, dose 2:   50.2%
#>  Maybe infected:             29
#>  New local cases:            22 ( 75.9%  of maybe infected)
#>  New overseas cases:         0
#>  New cases fully vaccinated: 8 / 36%
#>  New Hospital / ICU:          3 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,212
#>  Total first dose:    3,576
#>  Total second dose:   100,917
#>  Total Pfizer:        66,875
#>  Total AZ:            37,618
#>  Total infected:      32  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:   52.2%
#>  Vaccination rate, dose 2:   50.5%
#>  Maybe infected:             75
#>  New local cases:            42 ( 56.0%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 12 / 26%
#>  New Hospital / ICU:          3 / 0
#>  New dead:                    1       0%  were fully vaccinated
#>  New vaccinated:      2,196
#>  Total first dose:    5,269
#>  Total second dose:   101,350
#>  Total Pfizer:        69,001
#>  Total AZ:            37,618
#>  Total infected:      79  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:   53.3%
#>  Vaccination rate, dose 2:   50.7%
#>  Maybe infected:             159
#>  New local cases:            96 ( 60.4%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 29 / 29%
#>  New Hospital / ICU:          4 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,178
#>  Total first dose:    6,939
#>  Total second dose:   101,738
#>  Total Pfizer:        71,059
#>  Total AZ:            37,618
#>  Total infected:      180  ( 0.1% of the 199,997 population)
```

The resulting `tibble` is:

``` r
glimpse(sim_results)
#> Rows: 4
#> Columns: 27
#> Groups: runid [1]
#> $ scenario                <chr> "1", "1", "1", "1"
#> $ runid                   <int> 1, 1, 1, 1
#> $ iteration               <dbl> 0, 1, 2, 3
#> $ day                     <dbl> 0, 5, 10, 15
#> $ new_cases_i             <dbl> 10, 22, 47, 101
#> $ new_local_cases_i       <dbl> 10, 22, 42, 96
#> $ new_os_cases_i          <dbl> 0, 0, 5, 5
#> $ new_cases_vaccinated2_i <dbl> 5, 8, 12, 29
#> $ new_dead_i              <dbl> 0, 0, 1, 0
#> $ new_dead_vaccinated2_i  <dbl> 0, 0, 0, 0
#> $ new_vaccinated_i        <dbl> 100451, 2212, 2196, 2178
#> $ new_maybe_infected_i    <int> NA, 29, 75, 159
#> $ new_hosp_i              <int> NA, 3, 3, 4
#> $ new_icu_i               <int> NA, 0, 0, 0
#> $ total_vaccinated1_i     <int> NA, 3576, 5269, 6939
#> $ total_vaccinated2_i     <int> NA, 100917, 101350, 101738
#> $ total_pf_i              <int> NA, 66875, 69001, 71059
#> $ total_az_i              <int> NA, 37618, 37618, 37618
#> $ total_cases_i           <dbl> 10, 32, 79, 180
#> $ total_dead_i            <dbl> 0, 0, 1, 1
#> $ total_vaccinated_i      <dbl> 100451, 102663, 104859, 107037
#> $ in_population           <int> 199997, 199997, 199997, 199997
#> $ current_hosp_i          <dbl> 0, 3, 6, 9
#> $ current_icu_i           <dbl> 0, 0, 0, 0
#> $ rt_i                    <dbl> NA, 2.200000, 1.909091, 2.042553
#> $ in_R                    <dbl> 4.5, 4.5, 4.5, 4.5
#> $ in_vaccination_levels   <list> <0.00, 0.20, 0.40, 0.50, 0.60, 0.70, 0.90, 0.9…
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
#>  Vaccination rate, dose 1:   50.9%
#>  Vaccination rate, dose 2:   50.0%
#>  Maybe infected:             52
#>  New local cases:            34 ( 65.4%  of maybe infected)
#>  New overseas cases:         0
#>  New cases fully vaccinated: 6 / 18%
#>  New Hospital / ICU:          5 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,216
#>  Total first dose:    3,634
#>  Total second dose:   100,408
#>  Total Pfizer:        78,520
#>  Total AZ:            25,522
#>  Total infected:      44  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:   52.0%
#>  Vaccination rate, dose 2:   50.2%
#>  Maybe infected:             222
#>  New local cases:            122 ( 55.0%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 20 / 16%
#>  New Hospital / ICU:          20 / 3
#>  New dead:                    1       0%  were fully vaccinated
#>  New vaccinated:      2,201
#>  Total first dose:    5,343
#>  Total second dose:   100,806
#>  Total Pfizer:        80,627
#>  Total AZ:            25,522
#>  Total infected:      171  ( 0.1% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:   53.1%
#>  Vaccination rate, dose 2:   50.4%
#>  Maybe infected:             856
#>  New local cases:            450 ( 52.6%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 85 / 19%
#>  New Hospital / ICU:          56 / 9
#>  New dead:                    6       0%  were fully vaccinated
#>  New vaccinated:      2,183
#>  Total first dose:    6,971
#>  Total second dose:   101,212
#>  Total Pfizer:        82,661
#>  Total AZ:            25,522
#>  Total infected:      626  ( 0.3% of the 199,997 population)
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
#>  Vaccination rate, dose 1:   58.0%
#>  Vaccination rate, dose 2:   57.1%
#>  Maybe infected:             25
#>  New local cases:            17 ( 68.0%  of maybe infected)
#>  New overseas cases:         0
#>  New cases fully vaccinated: 8 / 47%
#>  New Hospital / ICU:          0 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,075
#>  Total first dose:    3,311
#>  Total second dose:   114,672
#>  Total Pfizer:        78,739
#>  Total AZ:            39,244
#>  Total infected:      27  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:   59.0%
#>  Vaccination rate, dose 2:   57.3%
#>  Maybe infected:             46
#>  New local cases:            19 ( 41.3%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 10 / 42%
#>  New Hospital / ICU:          0 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,046
#>  Total first dose:    4,907
#>  Total second dose:   115,019
#>  Total Pfizer:        80,682
#>  Total AZ:            39,244
#>  Total infected:      51  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:   60.0%
#>  Vaccination rate, dose 2:   57.5%
#>  Maybe infected:             62
#>  New local cases:            35 ( 56.5%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 17 / 42%
#>  New Hospital / ICU:          2 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,014
#>  Total first dose:    6,411
#>  Total second dose:   115,379
#>  Total Pfizer:        82,546
#>  Total AZ:            39,244
#>  Total infected:      91  ( 0.0% of the 199,997 population)
glimpse(sim_r4_50)
#> Rows: 4
#> Columns: 27
#> Groups: runid [1]
#> $ scenario                <chr> "1", "1", "1", "1"
#> $ runid                   <int> 1, 1, 1, 1
#> $ iteration               <dbl> 0, 1, 2, 3
#> $ day                     <dbl> 0, 5, 10, 15
#> $ new_cases_i             <dbl> 10, 17, 24, 40
#> $ new_local_cases_i       <dbl> 10, 17, 19, 35
#> $ new_os_cases_i          <dbl> 0, 0, 5, 5
#> $ new_cases_vaccinated2_i <dbl> 6, 8, 10, 17
#> $ new_dead_i              <dbl> 0, 0, 0, 0
#> $ new_dead_vaccinated2_i  <dbl> 0, 0, 0, 0
#> $ new_vaccinated_i        <dbl> 114198, 2075, 2046, 2014
#> $ new_maybe_infected_i    <int> NA, 25, 46, 62
#> $ new_hosp_i              <int> NA, 0, 0, 2
#> $ new_icu_i               <int> NA, 0, 0, 0
#> $ total_vaccinated1_i     <int> NA, 3311, 4907, 6411
#> $ total_vaccinated2_i     <int> NA, 114672, 115019, 115379
#> $ total_pf_i              <int> NA, 78739, 80682, 82546
#> $ total_az_i              <int> NA, 39244, 39244, 39244
#> $ total_cases_i           <dbl> 10, 27, 51, 91
#> $ total_dead_i            <dbl> 0, 0, 0, 0
#> $ total_vaccinated_i      <dbl> 114198, 116273, 118319, 120333
#> $ in_population           <int> 199997, 199997, 199997, 199997
#> $ current_hosp_i          <dbl> 0, 0, 0, 2
#> $ current_icu_i           <dbl> 0, 0, 0, 0
#> $ rt_i                    <dbl> NA, 1.700000, 1.117647, 1.458333
#> $ in_R                    <dbl> 4, 4, 4, 4
#> $ in_vaccination_levels   <list> <0.00, 0.40, 0.60, 0.60, 0.60, 0.70, 0.90, 0.9…
```
