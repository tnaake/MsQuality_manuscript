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
.path <- "/scratch/naake/Cherkaoui2022"
fls <- dir(.path, full.names = TRUE, pattern = "mzML")

## create the Spectra object
sps <- Spectra(fls, backend = MsBackendMzR())

## save the Spectra object as RDS file
saveRDS(sps, file = "Cherkaoui2022/Cherkaoui2022_sps.RDS")

##
##
## Calculate the metrics via MsQuality
.metrics <- c("numberSpectra", "areaUnderTic", "mzAcquisitionRange")
.metrics_sps <- calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics)
saveRDS(.metrics_sps, file = "Cherkaoui2022/Cherkaoui2022_metrics_sps.RDS")


##
##
## Calculate Peak RAM Used
library("peakRAM")
.path <- "/scratch/naake/Cherkaoui2022"
fls <- dir(.path, full.names = TRUE, pattern = "mzML")
.metrics <- c("numberSpectra", "areaUnderTic", "mzAcquisitionRange")
df_ram <- peakRAM(
    function() {
		##register(MulticoreParam(workers = 1))
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 1))
		##sps <- Spectra(fls, backend = MsBackendMzR())
		##calculateMetricsFromSpectra(spectra = sps, metrics = .metrics)
	},
    function() {
		##register(MulticoreParam(workers = 2))
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 2))
		##sps <- Spectra(fls, backend = MsBackendMzR())
		##calculateMetricsFromSpectra(spectra = sps, metrics = .metrics)
	},
    function() {
		##register(MulticoreParam(workers = 4))
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 4))
		##sps <- Spectra(fls, backend = MsBackendMzR())
		##calculateMetricsFromSpectra(spectra = sps, metrics = .metrics)
	},
    function() {
		##register(MulticoreParam(workers = 8))
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 8))
		##sps <- Spectra(fls, backend = MsBackendMzR())
		##calculateMetricsFromSpectra(spectra = sps, metrics = .metrics)
	},
    function() {
		##register(MulticoreParam(workers = 16))
		bplapply(fls, function(fls_i) {
			calculateMetricsFromSpectra(spectra = sps[sps$dataOrigin == fls_i, ], 
				metrics = .metrics)}, BPPARAM = MulticoreParam(workers = 16))
		##sps <- Spectra(fls, backend = MsBackendMzR())
		##calculateMetricsFromSpectra(spectra = sps, metrics = .metrics)
	}
)

## save the data.frame
saveRDS(df_ram, file = "Cherkaoui2022/Cherkaoui2022_df_ram.RDS")


##
##
## Calculate median time
library("microbenchmark")
.path <- "/scratch/naake/Cherkaoui2022"
fls <- dir(.path, full.names = TRUE, pattern = "mzML")
.metrics <- c("numberSpectra", "areaUnderTic", "mzAcquisitionRange")
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
	times = 110L, control = list(warmup = 10), check = "equal"
)

## save the data.frame
saveRDS(df_mb, file = "Cherkaoui2022/Cherkaoui2022_df_mb.RDS")



