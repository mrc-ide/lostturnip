f <- function(c, a, b) {
  g <- function(x) (x + c) * (x - 1) * (x - 1) + 0.1
  tryCatch(uniroot(g, c(a, b), tol = 0.000001, maxiter = 1000)$root,
           error = function(e) NaN)
}

results <- read.csv("results.csv")
x <- vapply(results$c, function(x) f(x, -4, 4 / 3), numeric(1))
## Requires relaxed tolerance because gpu version only in single
## precision.
testthat::expect_equal(results$x, x, tolerance = 1e-5)
message("All ok!")
