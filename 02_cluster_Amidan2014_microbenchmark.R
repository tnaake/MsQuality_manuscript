## set working directory
setwd("/g/huber/users/naake/GitHub/MsQuality_manuscript/")

## install libraries
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repos = "http://cran.us.r-project.org")
if (!require("remotes", quietly = TRUE))
    install.packages("remotes", repos = "http://cran.us.r-project.org")
if (!require("Rhdf5lib", quietly = TRUE))
    BiocManager::install("Rhdf5lib", ask = FALSE)
if (!require("mzR", quietly = TRUE))
    BiocManager::install("mzR", ask = FALSE, upgrade = "always")
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
fls <- fls[!fls %in% c(
    "/scratch/naake/Amidan2014/1_of_5/QC_Shew_12_02_Run-01_11Sep12_Eagle_12-06-09.mzML",
    "/scratch/naake/Amidan2014/1_of_5/QC_Shew_12_02_Run-01_12Dec12_Lion_12-10-03.mzML",
    "/scratch/naake/Amidan2014/1_of_5/QC_Shew_LS_30ug_500min_2.mzML",
    "/scratch/naake/Amidan2014/1_of_5/QC_Shew_LS_30ug_500min_3_130316102052.mzML",
    "/scratch/naake/Amidan2014/1_of_5/QC_Shew_LS_30ug_500min_3.mzML",
    "/scratch/naake/Amidan2014/2_of_5/QC_Shew_11_05_E_3Nov11_Cougar_11-07-23.mzML",
    "/scratch/naake/Amidan2014/2_of_5/QC_Shew_11_05_F_31Oct11_Cougar_11-09-09.mzML",
    "/scratch/naake/Amidan2014/2_of_5/QC_Shew_11_05_F_3Nov11_Cougar_11-09-09.mzML",
    "/scratch/naake/Amidan2014/2_of_5/QC_Shew_11_05_G_31Oct11_Cougar_11-07-42.mzML",
    "/scratch/naake/Amidan2014/2_of_5/QC_Shew_12_02_Run-04_3Aug12_Roc_12-04-09.mzML",
    "/scratch/naake/Amidan2014/4_of_5/QC_Shew_11_03_pt5_d_12Oct11__11-06-30.mzML",
    "/scratch/naake/Amidan2014/4_of_5/QC_Shew_11_06_5pt_34_22Dec11_Jaguar_11-09-18.mzML",
    "/scratch/naake/Amidan2014/4_of_5/QC_Shew_12_02_b_21Oct12_Cougar_12-06-04.mzML",
    "/scratch/naake/Amidan2014/4_of_5/QC_Shew_12_02_B_4Aug12_Cougar_12-06-11.mzML"
)]

## create the Spectra object
##sps <- Spectra(fls, backend = MsBackendMzR())

## save the Spectra object as RDS file
##saveRDS(sps, file = "Amidan2014/Amidan2014_sps.RDS")
print("read Spectra object.")
sps <- readRDS("Amidan2014/Amidan2014_sps.RDS")
print("finished reading Spectra object.")
print("")


##
##
## Calculate Peak RAM Used
print("start microbenchmark.")
library("microbenchmark")
.path <- "/scratch/naake/Amidan2014"
fls <- dataOrigin(sps) |>
	unique()
fls <- fls[1:500]
sps <- sps[sps$dataOrigin %in% fls, ]

.metrics <- c("rtDuration", "rtOverTicQuantile", 
    "ticQuartileToQuartileLogRatio", "numberSpectra",
    "medianPrecursorMz", "rtIqr", "rtIqrRate", "areaUnderTic",
    "areaUnderTicRtQuantiles", "medianTicRtIqr", "medianTicOfRtRange",
    "mzAcquisitionRange", "rtAcquisitionRange", "precursorIntensityRange",
    "precursorIntensityQuartiles", "precursorIntensityMean",
    "precursorIntensitySd", "msSignal10xChange", "ratioCharge1over2",
    "ratioCharge3over2", "ratioCharge4over2", "meanCharge",
    "medianCharge")

df_mb <- microbenchmark(
    workers_1 = calculateMetricsFromSpectra(spectra = sps,
            metrics = .metrics, msLevel = 1, 
            BPPARAM = MulticoreParam(workers = 1, stop.on.error = TRUE)),
    workers_2 = calculateMetricsFromSpectra(spectra = sps,
            metrics = .metrics, msLevel = 1, 
            BPPARAM = MulticoreParam(workers = 2, stop.on.error = TRUE)),
    workers_4 = calculateMetricsFromSpectra(spectra = sps,
            metrics = .metrics, msLevel = 1, 
            BPPARAM = MulticoreParam(workers = 4, stop.on.error = TRUE)),
    workers_8 = calculateMetricsFromSpectra(spectra = sps,
            metrics = .metrics, msLevel = 1, 
            BPPARAM = MulticoreParam(workers = 8, stop.on.error = TRUE)),
    workers_16 = calculateMetricsFromSpectra(spectra = sps,
            metrics = .metrics, msLevel = 1, 
            BPPARAM = MulticoreParam(workers = 16, stop.on.error = TRUE)),
    times = 32L, control = list(warmup = 2), check = "equal"
)

## save the data.frame
saveRDS(df_mb, file = "Amidan2014/Amidan2014_df_mb.RDS")
print("finish microbenchmark.")
print("")



