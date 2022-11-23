COMPUTE_VERSION=75
PROFILER_FLAGS=
CXXFLAGS=-O2 -std=c++14 --compiler-options="-Wall"
CUDAFLAGS=-Xptxas -dlcm=ca --cudart static -gencode arch=compute_$(COMPUTE_VERSION),code=sm_$(COMPUTE_VERSION) $(PROFILER_FLAGS)

TARGETS=lostturnip

all: $(TARGETS)

lostturnip: lostturnip.cu ../inst/include/lostturnip.hpp
	nvcc -I../inst/include $(CXXFLAGS) $(CUDAFLAGS) $< -o $@

results.txt: lostturnip
	./$< > $@

test: compare.R results.txt
	Rscript $<

clean:
	$(RM) $(TARGETS)
	$(RM) results.txt

.PHONY: clean test
