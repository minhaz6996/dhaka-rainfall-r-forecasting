# Methodology, source checks and execution status

## Source files
- `My Thesis(1).pdf`, 24 pages, research title *Forecasting with Seasonal Adjustment - An Application to Rainfall Data in Dhaka*, submitted by **Minhazul Alam**.
- `Dhaka_RT.csv`, 768 rows, 4 columns. Original file is used locally, not redistributed here.
- Original R code was not supplied/found. `src/analysis.R` is a new **reconstruction**, not a recovered original script.

## Verified dataset
- Inclusive dates: Jan 1953–Dec 2016; no gaps/duplicates.
- Missing values: 0 across all four fields.
- Zero-rainfall observations: 107; negative rainfall observations: 0.
- Rainfall numerical range: 0–856; numeric unit remains **unverified**.
- Highest long-run monthly mean: July (382.08, dataset units); lowest: January (6.78).

## Manuscript evidence and cautions
- p. 4: methods mention ARIMA, ETS, `auto.arima()` and `stlm()` adjustment.
- p. 6: text contains RMSE values 1.4917 and 1.5181 and literal `[insert value]` placeholders.
- p. 9: a complete RMSE/MAE/MSE table reports an alternative RMSE scale (ARIMA w/o SA 109.5019, ETS w/o SA 107.3584). **Do not infer that the p. 6 figures are correct or convert units without confirmation.**
- p. 10–11: text calls rainfall values inches but chart axes show data ranging into hundreds; **measurement units must be verified at source**.
- p. 22–24: historical forecast table begins Nov 1997, whereas the supplied CSV continues through Dec 2016. Training cutoff and original evaluation split are therefore not adequately documented.
- The p. 24 text interprets negative interval bounds as zero rainfall; negative forecast intervals instead reflect a model/bound limitation and do not establish a negative or zero observed rainfall amount.
- Reported p. 9 metrics are transcribed in `results/manuscript_reported_metrics_UNVERIFIED.csv` with explicit attribution.

## Independent benchmarking (Python, **not** claimed as R output)
- Training: 1953-01–2011-12; test: 2012-01–2016-12 (**60 months**).
- Seasonal naive: RMSE **88.4878**, MAE **57.6850**.
- Additive seasonal exponential smoothing (statsmodels): RMSE **95.6706**, MAE **69.6291**.
- Values are forecasts of rainfall in the source dataset's **unspecified units**.
- These methods and the test period are not necessarily the same as the manuscript's model/evaluation protocol; **results are not directly comparable**.
- The chart files in `figures/` were built from the private supplied dataset with Python, not rendered by R.

## R reproduction
- Run `Rscript src/analysis.R data/Dhaka_RT.csv` from repository root.
- R script uses CRAN package `forecast` and estimates Auto-ARIMA, ETS, STL+ARIMA, STL+ETS and seasonal naive. It creates charts and CSV tables.
- The reconstructed R script was successfully executed locally in RStudio using R 4.4.2 and forecast 8.24.0. Five forecasting models were evaluated on the 2012–2016 holdout period. The original thesis code and evaluation protocol remain unavailable, and significant residual autocorrelation was identified in the Auto-ARIMA diagnostics.
- Consider rolling-origin cross-validation and transformation/nonnegative forecast strategies before treating this as a deployment-ready system.

## Publication ethics
The manuscript is attributed to Minhazul Alam; no other person is claimed as author. The original manuscript, student ID and raw dataset are not shipped in this package. This portfolio is not presented as a live weather forecasting service.
