# lost turnips on a GPU

Compile with `make`, building the executable `lostturnip`. Running this will produce a csv on stdout which can be compared with uniroot in R via `compare.R`:

```
make
./lostturnip > results.csv
Rscript compare.R
make clean
```

Or just run

```
make test
```
