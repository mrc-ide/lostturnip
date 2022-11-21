test_that("root finding works on trivial case", {
  tol <- 1e-5
  maxit <- 100
  result <- test_find_result(function(x) x - 5, 0, 10, tol, maxit)
  expect_equal(result$x, 5)
  expect_equal(result$fx, 0)
  expect_equal(result$iterations, 1)
  expect_true(result$converged)
})
