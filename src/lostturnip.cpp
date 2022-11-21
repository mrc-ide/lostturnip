#include <lostturnip.hpp>

#include <cpp11/doubles.hpp>
#include <cpp11/function.hpp>
#include <cpp11/list.hpp>

[[cpp11::register]]
cpp11::sexp test_find_result(cpp11::function f, double a, double b,
                             double tol, int max_iterations) {
  const auto fn = [&](double x) {
                    const auto r_x = cpp11::writable::doubles{x};
                    return cpp11::as_cpp<double>(f(r_x));
                  };
  const auto result = lostturnip::find_result(fn, a, b, tol, max_iterations);

  using namespace cpp11::literals;
  return cpp11::writable::list({"x"_nm = result.x,
                                "fx"_nm = result.fx,
                                "iterations"_nm = result.iterations,
                                "converged"_nm = result.converged
    });
}
