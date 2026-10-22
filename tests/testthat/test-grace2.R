# Worked checks printed on the authors' GRACE Risk Score V2 coefficient sheets
# (sections 1A and 1B), to 2 decimals.
test_that("the authors' worked checks are reproduced", {
  a <- grace2(90, 92, 139, 1.06, 1, "no", "yes", "yes")
  b <- grace2(40, 82, 107, 1.00, 1, "no", "no", "yes")
  expect_equal(round(a$risk_death_mi_1y, 2), 0.34)
  expect_equal(round(b$risk_death_mi_1y, 2), 0.07)
  expect_equal(round(a$risk_death_1y, 2), 0.28)
  expect_equal(round(b$risk_death_1y, 2), 0.02)
})

test_that("categorical coefficients agree with the sheets' hazard ratios", {
  hr <- list(death_mi = c(killip2 = 1.71, killip3 = 1.99, killip4 = 3.19,
                          arrest = 1.96, enzymes = 1.26, st = 1.39),
             death = c(killip2 = 1.89, killip3 = 2.35, killip4 = 3.65,
                       arrest = 2.39, enzymes = 1.46, st = 1.56))
  # Within the sheets' 2-decimal rounding. Positive enzymes in the death/MI
  # model sits on the boundary: exp(.22710) = 1.25495, printed as 1.26.
  for (m in names(hr)) {
    b <- grace2pexa:::.gr_coef[[m]][names(hr[[m]])]
    expect_true(all(abs(exp(b) - hr[[m]]) <= 0.0051), label = m)
  }
})

test_that("spline terms behave as restricted cubic splines", {
  f <- grace2pexa:::.gr_rcs
  expect_equal(f(4, 4.8165, 6.6571, 8.3095), 0)      # below the first knot
  # beyond the last knot the term is linear in x
  d1 <- f(10, 4.8165, 6.6571, 8.3095) - f(9.5, 4.8165, 6.6571, 8.3095)
  d2 <- f(10.5, 4.8165, 6.6571, 8.3095) - f(10, 4.8165, 6.6571, 8.3095)
  expect_equal(d1, d2, tolerance = 1e-10)
})

test_that("umol/L creatinine is converted and bad input fails clearly", {
  a <- grace2(70, 80, 120, 1.2, 2, "no", "yes", "yes")
  b <- grace2(70, 80, 120, 1.2 * 88.4, 2, "no", "yes", "yes",
              creatinine_units = "umol/L")
  expect_equal(a, b, tolerance = 1e-12)
  expect_error(grace2(70, 80, 120, 106, 2, "no", "yes", "yes"), "umol/L")
  expect_error(grace2(70, 80, 120, 1.2, 5, "no", "yes", "yes"), "killip")
  expect_error(model_run(list(age = 70)), "Missing")
})
