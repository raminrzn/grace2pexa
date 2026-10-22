test_that("gateway returns full-precision JSON and ignores platform fields", {
  js <- gateway(model_input = get_default_input(), execution_id = "z",
                callback_url = "https://example.invalid/cb")
  r <- jsonlite::fromJSON(js)
  ref <- model_run(get_default_input())
  expect_equal(r$risk_death_1y, ref$risk_death_1y, tolerance = 1e-12)
  x <- get_default_input(); x$creatinine_units <- NULL
  expect_equal(model_run(x)$risk_death_mi_1y, ref$risk_death_mi_1y)
})
