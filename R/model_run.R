.gr_vars <- c("age", "heart_rate", "sbp", "creatinine", "killip",
              "cardiac_arrest", "positive_enzymes", "st_deviation",
              "creatinine_units")
.gr_alias <- c(pulse = "heart_rate", hr = "heart_rate", systolic_bp = "sbp",
               creat = "creatinine", killip_class = "killip",
               arrest = "cardiac_arrest", enzymes = "positive_enzymes",
               positive_troponin = "positive_enzymes", st = "st_deviation")

#' GRACE 2.0 (ModelsCloud entry point)
#' @param model_input Named list of inputs; see [grace2()].
#' @param ... The same fields as named arguments.
#' @return See [grace2()].
#' @export
model_run <- function(model_input = NULL, ...) {
  args <- .gr_normalize(model_input, list(...), .gr_vars, .gr_alias)
  if (is.null(args) || length(args) == 0) args <- get_default_input()
  missing <- setdiff(setdiff(.gr_vars, "creatinine_units"), names(args))
  if (length(missing) > 0) {
    stop("Missing required variable(s): ", paste(missing, collapse = ", "), ".",
         call. = FALSE)
  }
  do.call(grace2, args)
}

#' Example GRACE 2.0 inputs: the two check patients on the authors' sheets
#' @param n Optional number of rows.
#' @param ... Ignored.
#' @export
get_sample_input <- function(n = NULL, ...) {
  df <- data.frame(age = c(90, 40), heart_rate = c(92, 82), sbp = c(139, 107),
                   creatinine = c(1.06, 1.00), killip = c(1, 1),
                   cardiac_arrest = c("no", "no"),
                   positive_enzymes = c("yes", "no"),
                   st_deviation = c("yes", "yes"), stringsAsFactors = FALSE)
  if (!is.null(n)) df <- utils::head(df, n)
  df
}

#' Default GRACE 2.0 input (first check patient on the authors' sheets)
#' @param ... Ignored.
#' @export
get_default_input <- function(...) {
  list(age = 90, heart_rate = 92, sbp = 139, creatinine = 1.06, killip = 1,
       cardiac_arrest = "no", positive_enzymes = "yes", st_deviation = "yes")
}
