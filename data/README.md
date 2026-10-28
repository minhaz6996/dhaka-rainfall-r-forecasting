# Research dataset (not distributed)

Place your authorized copy of the original uploaded `Dhaka_RT.csv` here.

Expected headers: `YEAR`, `Month`, `Max Temp`, `Rainfall`. The uploaded file contained **768 monthly observations, January 1953–December 2016**, 0 missing values, and 107 zero-rainfall months.

The original data source and redistribution rights were not established from the supplied manuscript. For that reason, **the full CSV is deliberately excluded from this public GitHub package**.

To run locally:

```bash
Rscript src/analysis.R data/Dhaka_RT.csv
```

The unit of `Rainfall` was not verified; some thesis passages describe inches but numbers and graphs use another-looking numerical scale. Do not claim mm or inches without tracing the source.
