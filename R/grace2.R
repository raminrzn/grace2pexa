# GRACE 2.0 one-year models (Fox KAA, et al. BMJ Open 2014;4:e004425).
# Coefficients, knots and baseline survival: "GRACE Risk Score V2 Coefficients
# (02/06/2017)", sections 1A (death/MI) and 1B (death), as reproduced in
# Hara H, et al. EuroIntervention 2022;17:1362-1364, Supplementary Appendix 1.
# (c) 2012-2017 Center for Outcomes Research - University of Massachusetts
# Medical School; royalty-free material, used with this acknowledgement.
#
# P(event within 1 year) = 1 - S0(365)^exp(x'beta), with
#   age_10 = age / 10, sbp_20 = SBP / -20, pulse_30 = pulse / 30,
#   creatinine in mg/dL, and restricted cubic spline terms as defined in the
#   sheets (3 knots for age and SBP, 4 for pulse and creatinine).

.gr_knots <- list(age = c(4.8165, 6.6571, 8.3095), sbp = c(-9.02, -6.97, -5.32),
                  pulse = c(1.71, 2.31, 2.77, 3.95),
                  creat = c(0.685, 0.925, 1.145, 2.065))

.gr_coef <- list(
  death_mi = c(age = 0.14677, age_nl = 0.02090, sbp = 0.01797, sbp_nl = 0.01020,
               pulse = 0.04230, pulse_nl1 = 0.37817, pulse_nl2 = -1.25782,
               creat = -0.15965, creat_nl1 = 5.02142, creat_nl2 = -12.33887,
               killip2 = 0.53625, killip3 = 0.68594, killip4 = 1.15850,
               arrest = 0.67071, enzymes = 0.22710, st = 0.32831),
  death = c(age = 0.41157, age_nl = 0.01290, sbp = 0.08222, sbp_nl = 0.01020,
            pulse = 0.13138, pulse_nl1 = 0.40176, pulse_nl2 = -1.37249,
            creat = -0.51259, creat_nl1 = 7.52634, creat_nl2 = -18.23023,
            killip2 = 0.63827, killip3 = 0.85325, killip4 = 1.29372,
            arrest = 0.87185, enzymes = 0.37660, st = 0.44303)
)
.gr_s0 <- c(death_mi = 0.9865696068, death = 0.9983577131)

# Restricted cubic spline term with first knot k, using the last two knots
# (penultimate p, last l), exactly as written in the coefficient sheets.
.gr_rcs <- function(x, k, p, l) {
  pos3 <- function(v) if (v > 0) v^3 else 0
  pos3(x - k) - pos3(x - p) * (l - k) / (l - p) + pos3(x - l) * (p - k) / (l - p)
}

#' GRACE 2.0 one-year risk of death and of death or MI
#'
#' For patients presenting with an acute coronary syndrome, using values at
#' admission.
#'
#' @param age Age, years.
#' @param heart_rate Heart rate (pulse), beats per minute.
#' @param sbp Systolic blood pressure, mmHg.
#' @param creatinine Serum creatinine, in `creatinine_units`.
#' @param killip Killip class, 1-4.
#' @param cardiac_arrest Cardiac arrest at admission: yes/no.
#' @param positive_enzymes Positive initial cardiac enzymes: yes/no.
#' @param st_deviation ST-segment deviation: yes/no.
#' @param creatinine_units `"mg/dL"` (default) or `"umol/L"` (divided by 88.4).
#' @return A data frame with `risk_death_1y` and `risk_death_mi_1y` (0-1).
#' @references Fox KAA, FitzGerald G, Puymirat E, et al. *BMJ Open.*
#'   2014;4:e004425. \doi{10.1136/bmjopen-2013-004425}
#' @examples
#' grace2(age = 90, heart_rate = 92, sbp = 139, creatinine = 1.06, killip = 1,
#'        cardiac_arrest = "no", positive_enzymes = "yes", st_deviation = "yes")
#' @export
grace2 <- function(age, heart_rate, sbp, creatinine, killip, cardiac_arrest,
                   positive_enzymes, st_deviation, creatinine_units = "mg/dL") {
  age <- .gr_num(age, "age", 18, 110)
  hr  <- .gr_num(heart_rate, "heart_rate", 20, 300)
  sbp <- .gr_num(sbp, "sbp", 40, 300)
  cr  <- .gr_num(creatinine, "creatinine", 0.05, 3000)
  u <- tolower(gsub("[^a-zA-Z/]", "", creatinine_units))
  if (u %in% c("umol/l", "mol/l")) cr <- cr / 88.4 else if (u != "mg/dl") {
    stop('`creatinine_units` must be "mg/dL" or "umol/L".', call. = FALSE)
  }
  if (cr > 25) stop("Creatinine looks like umol/L; set `creatinine_units = \"umol/L\"`.",
                    call. = FALSE)
  k <- .gr_num(killip, "killip", 1, 4)
  if (k != round(k)) stop("`killip` must be 1, 2, 3 or 4.", call. = FALSE)

  a10 <- age / 10; s20 <- sbp / -20; p30 <- hr / 30
  ka <- .gr_knots$age; ks <- .gr_knots$sbp; kp <- .gr_knots$pulse; kc <- .gr_knots$creat
  x <- c(age = a10, age_nl = .gr_rcs(a10, ka[1], ka[2], ka[3]),
         sbp = s20, sbp_nl = .gr_rcs(s20, ks[1], ks[2], ks[3]),
         pulse = p30, pulse_nl1 = .gr_rcs(p30, kp[1], kp[3], kp[4]),
         pulse_nl2 = .gr_rcs(p30, kp[2], kp[3], kp[4]),
         creat = cr, creat_nl1 = .gr_rcs(cr, kc[1], kc[3], kc[4]),
         creat_nl2 = .gr_rcs(cr, kc[2], kc[3], kc[4]),
         killip2 = as.numeric(k == 2), killip3 = as.numeric(k == 3),
         killip4 = as.numeric(k == 4),
         arrest = .gr_yesno(cardiac_arrest, "cardiac_arrest"),
         enzymes = .gr_yesno(positive_enzymes, "positive_enzymes"),
         st = .gr_yesno(st_deviation, "st_deviation"))
  risk <- function(m) 1 - .gr_s0[[m]]^exp(sum(.gr_coef[[m]] * x[names(.gr_coef[[m]])]))
  data.frame(risk_death_1y = risk("death"), risk_death_mi_1y = risk("death_mi"))
}
