# lostturnip

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R build status](https://github.com/mrc-ide/lostturnip/workflows/R-CMD-check/badge.svg)](https://github.com/mrc-ide/lostturnip/actions)
[![codecov.io](https://codecov.io/github/mrc-ide/lostturnip/coverage.svg?branch=main)](https://codecov.io/github/mrc-ide/lostturnip?branch=main)
<!-- badges: end -->

## One dimensional root finding from C++

This package exists to wrap [Brent's method](https://en.wikipedia.org/wiki/Brent%27s_method) for one dimensional root finding, implemented in C++ and available for use in other R packages via R's `LinkingTo` facility. It is designed to work well with [C++11 "lambda functions"](https://learn.microsoft.com/en-us/cpp/cpp/lambda-expressions-in-cpp?view=msvc-170) but will work with anything that compiler works out it can call.

## To use

In your package, add

```
LinkingTo: lostturnip
```

in your `DESCRIPTION` file, then in your C++ code:

```
#include <lostturnip.hpp>

// ...

  const auto fn = [&](double x) { return (x + c) * (x - 1) * (x - 1); };
  const auto root = lostturnip::find<double>(fn, -4, 4.0 / 3.0, 1e-6, 100);
```

There are two main entrypoints:

* `lostturnip::find` - search for the root and throw an error if it fails
* `lostturnup::find_result` - search for the root and never throw, returning an object that can be tested for convergence.  The `lostturnip::result` object has members `x` (the best point so far), `fx` (`f` evaluated at `x`, very close to 0 if converged), `iterations` (the number of iterations carried out) and `converged` (boolean, indicating if we have converged).

All root finding attempts require a bounds on the root; a lower bound `a` and upper bound `b` (i.e. we believe that the root exists in the interval `[a, b]`). There are several ways that convergence can fail:

* if `[a, b]` does not bracket the root (i.e., if `f(a)` has the same sign as `f(b)`). The result object contains `NaN` values for both `x` and `fx` in this case
* if the number of iterations is exceeded. The result object contains the best value so far in this case

If you use `lostturnip::find_result`, be sure to check convergence. If you use `lostturnip::find`, be sure you can handle an exception.

## Usage from cuda

This will work from CUDA without modification; see [`cuda`](cuda) for an example program. Be careful where the root is not found because `lostturnip::find` will call `__trap()` which will crash the kernel and require the program to be restarted to continue.

## Installation

To install `lostturnip`:

```r
remotes::install_github("mrc-ide/lostturnip", upgrade = FALSE)
```

## License

MIT © Imperial College of Science, Technology and Medicine
