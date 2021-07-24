
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covidReff

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://www.tidyverse.org/lifecycle/#stable)
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
#>  Vaccination rate, dose 1:   51.3%
#>  Vaccination rate, dose 2:   50.4%
#>  Maybe infected:             33
#>  New local cases:            24 ( 72.7%  of maybe infected)
#>  New overseas cases:         0
#>  New cases fully vaccinated: 9 / 38%
#>  New Hospital / ICU:          0 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,212
#>  Total first dose:    3,628
#>  Total second dose:   101,204
#>  Total Pfizer:        67,177
#>  Total AZ:            37,655
#>  Total infected:      34  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:   52.4%
#>  Vaccination rate, dose 2:   50.6%
#>  Maybe infected:             74
#>  New local cases:            36 ( 48.6%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 16 / 39%
#>  New Hospital / ICU:          6 / 3
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,196
#>  Total first dose:    5,342
#>  Total second dose:   101,613
#>  Total Pfizer:        69,300
#>  Total AZ:            37,655
#>  Total infected:      75  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:   53.5%
#>  Vaccination rate, dose 2:   50.8%
#>  Maybe infected:             130
#>  New local cases:            65 ( 50.0%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 20 / 29%
#>  New Hospital / ICU:          3 / 1
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,178
#>  Total first dose:    6,981
#>  Total second dose:   102,016
#>  Total Pfizer:        71,342
#>  Total AZ:            37,655
#>  Total infected:      145  ( 0.1% of the 199,997 population)
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
#> $ new_cases_i             <dbl> 10, 24, 41, 70
#> $ new_local_cases_i       <dbl> 10, 24, 36, 65
#> $ new_os_cases_i          <dbl> 0, 0, 5, 5
#> $ new_cases_vaccinated2_i <dbl> 5, 9, 16, 20
#> $ new_dead_i              <dbl> 0, 0, 0, 0
#> $ new_dead_vaccinated2_i  <dbl> 0, 0, 0, 0
#> $ new_vaccinated_i        <dbl> 100781, 2212, 2196, 2178
#> $ new_maybe_infected_i    <int> NA, 33, 74, 130
#> $ new_hosp_i              <int> NA, 0, 6, 3
#> $ new_icu_i               <int> NA, 0, 3, 1
#> $ total_vaccinated1_i     <int> NA, 3628, 5342, 6981
#> $ total_vaccinated2_i     <int> NA, 101204, 101613, 102016
#> $ total_pf_i              <int> NA, 67177, 69300, 71342
#> $ total_az_i              <int> NA, 37655, 37655, 37655
#> $ total_cases_i           <dbl> 10, 34, 75, 145
#> $ total_dead_i            <dbl> 0, 0, 0, 0
#> $ total_vaccinated_i      <dbl> 100781, 102993, 105189, 107367
#> $ in_population           <int> 199997, 199997, 199997, 199997
#> $ current_hosp_i          <dbl> 0, 0, 6, 9
#> $ current_icu_i           <dbl> 0, 0, 3, 2
#> $ rt_i                    <dbl> NA, 2.400000, 1.500000, 1.585366
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
#>  Vaccination rate, dose 2:   49.9%
#>  Maybe infected:             56
#>  New local cases:            37 ( 66.1%  of maybe infected)
#>  New overseas cases:         0
#>  New cases fully vaccinated: 10 / 27%
#>  New Hospital / ICU:          3 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,216
#>  Total first dose:    3,643
#>  Total second dose:   100,258
#>  Total Pfizer:        78,577
#>  Total AZ:            25,324
#>  Total infected:      47  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:   52.0%
#>  Vaccination rate, dose 2:   50.1%
#>  Maybe infected:             223
#>  New local cases:            111 ( 49.8%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 21 / 18%
#>  New Hospital / ICU:          14 / 4
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,201
#>  Total first dose:    5,369
#>  Total second dose:   100,654
#>  Total Pfizer:        80,699
#>  Total AZ:            25,324
#>  Total infected:      163  ( 0.1% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:   53.0%
#>  Vaccination rate, dose 2:   50.3%
#>  Maybe infected:             784
#>  New local cases:            394 ( 50.3%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 65 / 16%
#>  New Hospital / ICU:          43 / 7
#>  New dead:                    3       0%  were fully vaccinated
#>  New vaccinated:      2,183
#>  Total first dose:    7,011
#>  Total second dose:   101,048
#>  Total Pfizer:        82,735
#>  Total AZ:            25,324
#>  Total infected:      562  ( 0.3% of the 199,997 population)
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
#>  Maybe infected:             21
#>  New local cases:            14 ( 66.7%  of maybe infected)
#>  New overseas cases:         0
#>  New cases fully vaccinated: 7 / 50%
#>  New Hospital / ICU:          0 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,075
#>  Total first dose:    3,426
#>  Total second dose:   114,549
#>  Total Pfizer:        78,998
#>  Total AZ:            38,977
#>  Total infected:      24  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  2  ( day  10 )           
#>  Vaccination rate, dose 1:   59.0%
#>  Vaccination rate, dose 2:   57.3%
#>  Maybe infected:             37
#>  New local cases:            18 ( 48.6%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 10 / 43%
#>  New Hospital / ICU:          0 / 1
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,046
#>  Total first dose:    4,967
#>  Total second dose:   114,967
#>  Total Pfizer:        80,957
#>  Total AZ:            38,977
#>  Total infected:      47  ( 0.0% of the 199,997 population)
#> 
#> Iteration:  3  ( day  15 )           
#>  Vaccination rate, dose 1:   60.0%
#>  Vaccination rate, dose 2:   57.5%
#>  Maybe infected:             59
#>  New local cases:            27 ( 45.8%  of maybe infected)
#>  New overseas cases:         5
#>  New cases fully vaccinated: 11 / 34%
#>  New Hospital / ICU:          6 / 0
#>  New dead:                    0       NA  were fully vaccinated
#>  New vaccinated:      2,014
#>  Total first dose:    6,478
#>  Total second dose:   115,336
#>  Total Pfizer:        82,837
#>  Total AZ:            38,977
#>  Total infected:      79  ( 0.0% of the 199,997 population)
glimpse(sim_r4_50)
#> Rows: 4
#> Columns: 27
#> Groups: runid [1]
#> $ scenario                <chr> "1", "1", "1", "1"
#> $ runid                   <int> 1, 1, 1, 1
#> $ iteration               <dbl> 0, 1, 2, 3
#> $ day                     <dbl> 0, 5, 10, 15
#> $ new_cases_i             <dbl> 10, 14, 23, 32
#> $ new_local_cases_i       <dbl> 10, 14, 18, 27
#> $ new_os_cases_i          <dbl> 0, 0, 5, 5
#> $ new_cases_vaccinated2_i <dbl> 6, 7, 10, 11
#> $ new_dead_i              <dbl> 0, 0, 0, 0
#> $ new_dead_vaccinated2_i  <dbl> 0, 0, 0, 0
#> $ new_vaccinated_i        <dbl> 114172, 2075, 2046, 2014
#> $ new_maybe_infected_i    <int> NA, 21, 37, 59
#> $ new_hosp_i              <int> NA, 0, 0, 6
#> $ new_icu_i               <int> NA, 0, 1, 0
#> $ total_vaccinated1_i     <int> NA, 3426, 4967, 6478
#> $ total_vaccinated2_i     <int> NA, 114549, 114967, 115336
#> $ total_pf_i              <int> NA, 78998, 80957, 82837
#> $ total_az_i              <int> NA, 38977, 38977, 38977
#> $ total_cases_i           <dbl> 10, 24, 47, 79
#> $ total_dead_i            <dbl> 0, 0, 0, 0
#> $ total_vaccinated_i      <dbl> 114172, 116247, 118293, 120307
#> $ in_population           <int> 199997, 199997, 199997, 199997
#> $ current_hosp_i          <dbl> 0, 0, 0, 6
#> $ current_icu_i           <dbl> 0, 0, 0, 0
#> $ rt_i                    <dbl> NA, 1.400000, 1.285714, 1.173913
#> $ in_R                    <dbl> 4, 4, 4, 4
#> $ in_vaccination_levels   <list> <0.00, 0.40, 0.60, 0.60, 0.60, 0.70, 0.90, 0.9…
```
