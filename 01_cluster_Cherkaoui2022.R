## set working directory
setwd("/g/huber/users/naake/GitHub/MsQuality_manuscript/")

## load libraries
library("Spectra")
library("MsQuality")
library("peakRAM")

##
##
## read the file with protein intensities
.path <- "/scratch/naake/Cherkaoui2022/"
fls <- dir(.path, full.names = TRUE)

## create the Spectra object
sps <- Spectra(fls, backend = MsBackendMzR())

## save the Spectra object as RDS file
saveRDS(sps, file = "Cherkaoui2022/Cherkaoui2022_sps.RDS")

##
##
## Calculate the metrics via MsQuality
.metrics <- c("numberSpectra", "areaUnderTic", "mzAcquisitionRange")
.metrics_sps <- MsQuality::calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics)
saveRDS(.metrics_sps, file = "Cherkaoui2022/Cherkaoui2022_metrics_sps.RDS")


##
##
## Calculate Peak RAM Used
library("peakRAM")
.metrics <- c("numberSpectra", "areaUnderTic", "mzAcquisitionRange")
df_ram <- peakRAM(
    {register(MulticoreParam(1)); calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics)},
    {register(MulticoreParam(2)); calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics)},
    {register(MulticoreParam(4)); calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics)},
    {register(MulticoreParam(8)); calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics)},
    {register(MulticoreParam(16)); calculateMetricsFromSpectra(spectra = sps, 
    metrics = .metrics)}
)

## save the data.frame
saveRDS(df_ram, file = "Cherkaoui2022/Cherkaoui2022_df_ram.RDS")