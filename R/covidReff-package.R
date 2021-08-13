#' covidReff
#' @description Simulate Covid based on reproduction and vaccination inputs.
#' @import data.table
#' @importFrom dplyr bind_rows
#' @importFrom dplyr count
#' @importFrom dplyr filter
#' @importFrom dplyr group_by
#' @importFrom dplyr if_else
#' @importFrom dplyr lag
#' @importFrom dplyr mutate
#' @importFrom dplyr n
#' @importFrom dplyr relocate
#' @importFrom dplyr select
#' @importFrom dplyr summarise
#' @importFrom dplyr pull
#' @importFrom dplyr starts_with
#' @importFrom dplyr left_join
#' @importFrom dqrng dqrunif
#' @importFrom magrittr %>%
#' @importFrom purrr map_dfr
#' @importFrom tibble tibble
#' @importFrom tidyr uncount
#' @importFrom tidyr replace_na
#' @importFrom scales comma
#' @importFrom scales percent
#' @importFrom stats weighted.mean
#' @importFrom stats runif
#' @importFrom stats rlnorm
#' @importFrom stats rpois
#' @importFrom stats rbeta

#' @import crayon


#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL
