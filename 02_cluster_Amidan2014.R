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

remotes::install_github("tnaake/MsQuality", upgrade = "always", force = TRUE)
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
sps <- Spectra(fls, backend = MsBackendMzR())

## save the Spectra object as RDS file
saveRDS(sps, file = "Amidan2014/Amidan2014_sps.RDS")
print("read Spectra object.")
sps <- readRDS("Amidan2014/Amidan2014_sps.RDS")
print("finished reading Spectra object.")
print("")

##
##
## Calculate the metrics via MsQuality
print("calculate metrics.")
.metrics <- c("rtDuration", "rtOverTicQuantiles", "rtOverMsQuarters",
    "ticQuartileToQuartileLogRatio", "numberSpectra",
    "medianPrecursorMz", "rtIqr", "rtIqrRate", "areaUnderTic",
    "areaUnderTicRtQuantiles", "medianTicRtIqr", "medianTicOfRtRange",
    "mzAcquisitionRange", "rtAcquisitionRange", "precursorIntensityRange",
    "precursorIntensityQuartiles", "precursorIntensityMean",
    "precursorIntensitySd", "msSignal10xChange", "ratioCharge1over2",
    "ratioCharge3over2", "ratioCharge4over2", "meanCharge",
    "medianCharge")

.metrics_sps_msLevel1 <- MsQuality::calculateMetricsFromSpectra(spectra = sps,
    metrics = .metrics, msLevel = 1L, mode = "TIC")
.metrics_sps_msLevel2 <- MsQuality::calculateMetricsFromSpectra(spectra = sps,
    metrics = .metrics, msLevel = 2L, mode = "TIC")
saveRDS(.metrics_sps_msLevel1, file = "Amidan2014/Amidan2014_metrics_sps_msLevel1.RDS")
saveRDS(.metrics_sps_msLevel2, file = "Amidan2014/Amidan2014_metrics_sps_msLevel2.RDS")
print("calculate metrics finished.")
print("")

