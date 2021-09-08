#' Get vaccine efficacy
#'
#' @name get_vaccine_efficacy
#'
#' @description Return an efficacy value based on protection (infection or hospitalisation), vaccine type, dose and days since dosage.
#'
#' @param protection_against a character vector or element: "poi" (protection against infection) or "poh" (protection against hospitalisation)
#' @param vaccine_type a character element "pf" (Pfizer) or "az" (Astrazeneca)
#' @param vaccine_dose a numeric element 1 for first dose or 2 for second dose
#' @param days_since_dosage a numeric element 1 for first dose or 2 for second dose
#'
#' @export

get_vaccine_efficacy <- function(protection_against,
                                 vaccine_type,
                                 vaccine_dose,
                                 days_since_dosage) {

  get_efficacy_ <- function(po, vt, vd, day) {

    if (day <= 0 | vt == "none") return(0)

    if (po == "poi") {
      if (vt == "pf") {
        if (vd == 1) return(covidReff::ved_list$ved_poi_pf1[day]) else return(covidReff::ved_list$ved_poi_pf2[day])
      } else {
        if (vd == 1) return(covidReff::ved_list$ved_poi_az1[day]) else return(covidReff::ved_list$ved_poi_az2[day])
      }

    } else {
      if (vt == "pf") {
        if (vd == 1) return(covidReff::ved_list$ved_poh_pf1[day]) else return(covidReff::ved_list$ved_poh_pf2[day])
      } else {
        if (vd == 1) return(covidReff::ved_list$ved_poh_az1[day]) else return(covidReff::ved_list$ved_poh_az2[day])
      }
    }
  }

  args <- list(po = protection_against,
               vt = vaccine_type,
               vd = vaccine_dose,
               day = days_since_dosage
  )

  ret <- pmap_dbl(args, get_efficacy_)

  return(ret)
}
