// -*-c++-*-
#include <chrono>
#include <iostream>
#include <sstream>

#include <lostturnip.hpp>

static void throw_cuda_error(const char *file, int line, cudaError_t status) {
  std::stringstream msg;
  if (status == cudaErrorUnknown) {
    msg << file << "(" << line << ") An Unknown CUDA Error Occurred :(";
  } else {
    msg << file << "(" << line << ") CUDA Error Occurred:\n" <<
      cudaGetErrorString(status);
  }
#ifdef DUST_ENABLE_CUDA_PROFILER
  cudaProfilerStop();
#endif
  throw std::runtime_error(msg.str());
}

static void handle_cuda_error(const char *file, int line,
                              cudaError_t status = cudaGetLastError()) {
#ifdef _DEBUG
  cudaDeviceSynchronize();
#endif
  if (status != cudaSuccess || (status = cudaGetLastError()) != cudaSuccess) {
    throw_cuda_error(file, line, status);
  }
}

#define CUDA_CALL( err ) (handle_cuda_error(__FILE__, __LINE__ , err))

__device__
float f(float c, float a, float b) {
  const auto g = [&](float x) { return (x + c) * (x - 1) * (x - 1) + 0.1f; };
  const float tol = 0.000001f;
  const auto ret = lostturnip::find_result(g, a, b, tol, 100);
  return ret.x;
}

__global__
void kernel(float *c, float *roots, size_t n_threads, size_t n_roots) {
  const int i = blockIdx.x * blockDim.x + threadIdx.x;
  const float a = -4;
  const float b = 4.0f / 3.0f;
  if (i < n_roots) {
    roots[i] = f(c[i], a, b);
  }
}

void run(int n_roots, int n_threads) {
  const size_t blockSize = 128;
  const size_t blockCount = (n_threads + blockSize - 1) / blockSize;
  auto t0 = std::chrono::high_resolution_clock::now();

  // Generate a vector of parameters that we'll search over
  float *c_host = (float*)malloc(n_roots * sizeof(float));
  const float min = -2;
  const float max = 4;
  for (int i = 0; i < n_roots; ++i) {
    c_host[i] = (static_cast<float>(i) / (n_roots - 1)) * (max - min) + min;
  }

  float *roots;
  float *c;
  CUDA_CALL(cudaMalloc((void**)&c, n_roots * sizeof(float)));
  CUDA_CALL(cudaMalloc((void**)&roots, n_roots * sizeof(float)));

  cudaMemcpy(c, c_host, sizeof(float) * n_roots, cudaMemcpyHostToDevice);

  kernel<<<blockCount, blockSize>>>(c, roots, n_threads, n_roots);

  CUDA_CALL(cudaDeviceSynchronize());

  auto t1 = std::chrono::high_resolution_clock::now();

  std::chrono::duration<double> t = t1 - t0;

  float *roots_host = (float*) malloc(n_roots * sizeof(float));
  cudaMemcpy(roots_host, roots, sizeof(float) * n_roots,
             cudaMemcpyDeviceToHost);

  std::cout << "c,x" << std::endl;
  for (int i = 0; i < n_roots; ++i) {
    std::cout << c_host[i] << ", " << roots_host[i] << std::endl;
  }

  CUDA_CALL(cudaFree(c));
  CUDA_CALL(cudaFree(roots));
  free(c_host);
  free(roots_host);
}

int main(int argc, char *argv[]) {
  const int n_threads = 100;
  const int n_roots = 100;
  run(n_roots, n_threads);
  return 0;
}
