test_that("root finding works on trivial case", {
  tol <- 1e-5
  maxit <- 100
  result <- test_find_result(function(x) x - 5, 0, 10, tol, maxit)
  expect_equal(result$x, 5)
  expect_equal(result$fx, 0)
  expect_equal(result$iterations, 1)
  expect_true(result$converged)
})


test_that("root finding works with wikipedia example", {
  tol <- 1e-5
  maxit <- 100
  result <- test_find_result(
    function(x) (x + 3) * (x - 1)^2, -4, 4 / 3, tol, maxit)
  expect_equal(result$x, -3, tolerance = tol)
  expect_equal(result$fx, 0, tolerance = tol)
  expect_equal(result$iterations, 9)
  expect_true(result$converged)
})


test_that("return boundary if at root, without iterating", {
  tol <- 1e-5
  maxit <- 100
  expect_identical(
    test_find_result(function(x) x - 5, 5, 10, tol, maxit),
    list(x = 5, fx = 0, iterations = 0L, converged = TRUE))
  expect_identical(
    test_find_result(function(x) x - 5, 0, 5, tol, maxit),
    list(x = 5, fx = 0, iterations = 0L, converged = TRUE))
})


test_that("return failure if root not bracketed", {
  tol <- 1e-5
  maxit <- 100
  expect_identical(
    test_find_result(function(x) x - 5, 6, 10, tol, maxit),
    list(x = NA_real_, fx = NA_real_, iterations = 0L, converged = FALSE))
})


test_that("return failure if iterations exceeded", {
  tol <- 1e-5
  maxit <- 5
  f <- function(x) (x + 3) * (x - 1)^2
  result <- test_find_result(f, -4, 4 / 3, tol, maxit)

  expect_equal(result$fx, f(result$x))
  expect_equal(result$iterations, maxit)
  expect_false(result$converged)
})
