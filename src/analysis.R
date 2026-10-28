# Forecasting with Seasonal Adjustment - Rainfall Data in Dhaka
# Reconstructed R analysis (NOT the original, unavailable R code)
# Research and manuscript: Minhazul Alam
# Data file: data/Dhaka_RT.csv (not bundled with the public portfolio repository)
# Method: 60-month out-of-sample comparison (2012-2016) for four approaches.
# Required: R >= 4.2 and the CRAN package "forecast".
# Run from the repository root: Rscript src/analysis.R data/Dhaka_RT.csv

suppressPackageStartupMessages({
  if (!requireNamespace("forecast", quietly = TRUE)) stop("Install 'forecast': install.packages('forecast')")
})
args <- commandArgs(trailingOnly = TRUE)
file <- if (length(args) >= 1) args[1] else "data/Dhaka_RT.csv"
if (!file.exists(file)) stop(paste0("CSV missing: ", file, ". See data/README.md."))
raw <- read.csv(file, check.names=FALSE, stringsAsFactors=FALSE)
required <- c("YEAR", "Month", "Max Temp", "Rainfall")
if (!all(required %in% names(raw))) stop("CSV must contain YEAR, Month, Max Temp, Rainfall")
raw$YEAR <- as.integer(raw$YEAR)
raw$Month <- as.integer(raw$Month)
raw$Rainfall <- as.numeric(raw$Rainfall)
raw$`Max Temp` <- as.numeric(raw$`Max Temp`)
if (anyNA(raw[, required])) stop("Dataset has missing or nonnumeric required entries")
if (any(raw$Month < 1 | raw$Month > 12) || any(raw$Rainfall < 0)) stop("Invalid month or negative observed rainfall")
raw <- raw[order(raw$YEAR, raw$Month),]
if (any(duplicated(paste(raw$YEAR, raw$Month)))) stop("Duplicate monthly entries")
periods <- seq(as.Date(sprintf("%04d-%02d-01", raw$YEAR[1], raw$Month[1])),
               as.Date(sprintf("%04d-%02d-01", tail(raw$YEAR,1),tail(raw$Month,1))), by="month")
if (length(periods) != nrow(raw) || any(format(periods, "%Y-%m") != sprintf("%04d-%02d", raw$YEAR, raw$Month))) stop("Monthly gaps found")
if (nrow(raw) != 768 || raw$YEAR[1] != 1953 || tail(raw$YEAR,1) != 2016) warning("Data differs from the uploaded manuscript-era file")

x <- ts(raw$Rainfall, start=c(raw$YEAR[1],raw$Month[1]), frequency=12)
# Hold out the last 60 months; no data leakage.
h <- 60L
if (length(x) <= 12L + h) stop("Insufficient observations")
train <- head(x,-h)
test <- tail(x,h)

fit_arima <- forecast::auto.arima(train, seasonal=TRUE, stepwise=TRUE, approximation=FALSE)
fit_ets <- forecast::ets(train)
fit_stl_arima <- forecast::stlm(train, s.window="periodic", method="arima", robust=TRUE)
fit_stl_ets <- forecast::stlm(train, s.window="periodic", method="ets", robust=TRUE)

all_predictions <- list(
  "Auto-ARIMA"=as.numeric(forecast::forecast(fit_arima,h=h)$mean),
  "ETS"=as.numeric(forecast::forecast(fit_ets,h=h)$mean),
  "STL + ARIMA"=as.numeric(forecast::forecast(fit_stl_arima,h=h)$mean),
  "STL + ETS"=as.numeric(forecast::forecast(fit_stl_ets,h=h)$mean),
  "Seasonal naive benchmark"=as.numeric(forecast::snaive(train,h=h)$mean)
)
actual <- as.numeric(test)
rmse <- function(pred) sqrt(mean((pred-actual)^2))
mae <- function(pred) mean(abs(pred-actual))
# Percentage-based metrics omitted because 107 monthly rainfall observations are zero.
comparison <- do.call(rbind,lapply(names(all_predictions),function(nm) {
  v<-all_predictions[[nm]]
  data.frame(Model=nm,RMSE=rmse(v),MAE=mae(v),MeanError=mean(v-actual),TestMonths=h,
             TrainingEnd="2011-12",TestPeriod="2012-01 to 2016-12")
}))
comparison <- comparison[order(comparison$RMSE),]

for (d in c("results","figures")) if(!dir.exists(d)) dir.create(d)
write.csv(comparison,"results/r_model_holdout_comparison.csv",row.names=FALSE)
forecast_table <- data.frame(Year=tail(raw$YEAR,h),Month=tail(raw$Month,h),ActualRainfall=actual)
for (nm in names(all_predictions)) forecast_table[[make.names(nm)]] <- all_predictions[[nm]]
write.csv(forecast_table,"results/r_holdout_predictions.csv",row.names=FALSE)
climatology <- aggregate(raw$Rainfall,by=list(Month=raw$Month),FUN=mean)
names(climatology)[2] <- "MeanRainfall"
write.csv(climatology,"results/r_monthly_climatology.csv",row.names=FALSE)

png("figures/R_01_monthly_climatology.png",width=1400,height=800,res=150)
barplot(climatology$MeanRainfall,names.arg=month.abb,main="Monthly mean rainfall, Dhaka 1953–2016",
        ylab="Rainfall (dataset units)",col="#71a5ff")
dev.off()

png("figures/R_02_holdout_forecasts.png",width=1500,height=850,res=150)
plot(as.numeric(test),type="l",col="black",lwd=2,xlab="Month in 2012–2016 holdout",
     ylab="Rainfall (dataset units)",main="Out-of-sample comparison (not original thesis forecasts)")
lines(all_predictions[["Auto-ARIMA"]],col="#4d86e8",lwd=2)
lines(all_predictions[["ETS"]],col="#f27971",lwd=2)
lines(all_predictions[["STL + ARIMA"]],col="#2b9a80",lwd=1.5,lty=2)
legend("topright",legend=c("Observed","Auto-ARIMA","ETS","STL + ARIMA"),
       col=c("black","#4d86e8","#f27971","#2b9a80"),lty=c(1,1,1,2),lwd=2,cex=.8)
dev.off()

png("figures/R_03_stl_decomposition.png",width=1400,height=950,res=150)
plot(stl(x,s.window="periodic"),main="STL seasonal decomposition")
dev.off()

png("figures/R_04_arima_diagnostics.png",width=1400,height=950,res=150)
forecast::checkresiduals(fit_arima)
dev.off()

cat("CSV validated:",nrow(raw),"rows,",sum(raw$Rainfall==0),"zero-rainfall months\n")
print(comparison,row.names=FALSE)
cat("Warning: original thesis model definitions and the holdout protocol may differ. This is a new reconstruction.\n")
