## set working directory
setwd("/g/huber/users/naake/GitHub/MsQuality_manuscript/")

## install libraries
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repos = "http://cran.us.r-project.org")
if (!require("Rhdf5lib", quietly = TRUE))
    BiocManager::install("Rhdf5lib", ask = FALSE)
if (!require("mzR", quietly = TRUE))
    BiocManager::install("mzR", ask = FALSE)
if (!require("remotes", quietly = TRUE))
    install.packages("remotes", repos = "http://cran.us.r-project.org")
if (!require("Spectra", quietly = TRUE))
	BiocManager::install("Spectra", ask = FALSE)

remotes::install_github("tnaake/MsQuality", upgrade = "always")
BiocManager::install("peakRAM", ask = FALSE)
BiocManager::install("microbenchmark", ask = FALSE)


## load libraries
library("Spectra")
library("MsQuality")
library("peakRAM")

##
##
## read the file with protein intensities
.path <- "/scratch/naake/Amidan2014"
fls <- dir(.path, full.names = TRUE, recursive = TRUE, pattern = "mzML")

## create the Spectra object
sps <- Spectra(fls, backend = MsBackendMzR())

## save the Spectra object as RDS file
saveRDS(sps, file = "Amidan2014/Amidan2014_sps.RDS")

##
##
## Calculate the metrics via MsQuality
.metrics <- c("rtDuration", "rtOverTicQuantile", "rtOverMsQuarters", 
    "ticQuantileToQuantileLogRatio", "numberSpectra", 
    "medianPrecursorMz", "rtIqr", "rtIqrRate", "areaUnderTic", 
    "areaUnderTicRtQuantiles", "medianTicRtIqr", "medianTicOfRtRange",
    "mzAcquisitionRange", "rtAcquisitionRange", "precursorIntensityRange", 
    "precursorIntensityQuartiles", "precursorIntensityMean", 
    "precursorIntensitySd", "msSignal10xChange", "ratioCharge1over2", 
    "ratioCharge3over2", "ratioCharge4over2", "meanCharge", 
    "medianCharge")

.metrics_sps_msLevel1 <- MsQuality::calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics, msLevel = 1L)
.metrics_sps_msLevel2 <- MsQuality::calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics, msLevel = 2L)

##
##
## Calculate Peak RAM Used
library("peakRAM")
.path <- "/scratch/naake/Amidan2014"
fls <- dir(.path, full.names = TRUE, recursive = TRUE, pattern = "mzML")
.metrics <- c("rtDuration", "rtOverTicQuantile", "rtOverMsQuarters", 
    "ticQuantileToQuantileLogRatio", "numberSpectra", 
    "medianPrecursorMz", "rtIqr", "rtIqrRate", "areaUnderTic", 
    "areaUnderTicRtQuantiles", "medianTicRtIqr", "medianTicOfRtRange",
    "mzAcquisitionRange", "rtAcquisitionRange", "precursorIntensityRange", 
    "precursorIntensityQuartiles", "precursorIntensityMean", 
    "precursorIntensitySd", "msSignal10xChange", "ratioCharge1over2", 
    "ratioCharge3over2", "ratioCharge4over2", "meanCharge", 
    "medianCharge")

df_ram <- peakRAM(
    function() {
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 1))
	},
    function() {
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 2))
	},
    function() {
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 4))
	},
    function() {
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 8))
	},
    function() {
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 16))
	}
)

## save the data.frame
saveRDS(df_ram, file = "Amidan2014/Amidan2014_df_ram.RDS")


##
##
## Calculate Peak RAM Used
library("microbenchmark")
.path <- "/scratch/naake/Amidan2014"
fls <- dir(.path, full.names = TRUE, recursive = TRUE, pattern = "mzML")
.metrics <- c("rtDuration", "rtOverTicQuantile", "rtOverMsQuarters", 
    "ticQuantileToQuantileLogRatio", "numberSpectra", 
    "medianPrecursorMz", "rtIqr", "rtIqrRate", "areaUnderTic", 
    "areaUnderTicRtQuantiles", "medianTicRtIqr", "medianTicOfRtRange",
    "mzAcquisitionRange", "rtAcquisitionRange", "precursorIntensityRange", 
    "precursorIntensityQuartiles", "precursorIntensityMean", 
    "precursorIntensitySd", "msSignal10xChange", "ratioCharge1over2", 
    "ratioCharge3over2", "ratioCharge4over2", "meanCharge", 
    "medianCharge")

df_mb <- microbenchmark(
    workers_1 = bplapply(fls, function(fls_i) {
		calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
			metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 1)),
    workers_2 = bplapply(fls, function(fls_i) {
		calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
			metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 2)),
    workers_4 = bplapply(fls, function(fls_i) {
		calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
			metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 4)),
    workers_8 = bplapply(fls, function(fls_i) {
		calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
			metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 8)),
    workers_16 = bplapply(fls, function(fls_i) {
		calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
			metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 16)), 
	times = 100L, control = list(warmup = 10), check = "equal"
)

## save the data.frame
saveRDS(df_mb, file = "Amidan2014/Amidan2014_df_mb.RDS")



