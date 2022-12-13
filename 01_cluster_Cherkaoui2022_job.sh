#!/bin/bash
#SBATCH -A huber                	# group to which you belong
#SBATCH -N 1                        # number of nodes
#SBATCH -n 31                       # number of cores
#SBATCH --mem 64G                  # memory pool for all cores
#SBATCH -t 7-0:00:00                # runtime limit (D-HH:MM:SS)
#SBATCH -o slurm.%N.%j.out          # STDOUT
#SBATCH -e slurm.%N.%j.err          # STDERR
#SBATCH --mail-type=END,FAIL        # notifications for job done & fail
#SBATCH --mail-user=naake@embl.de # send-to address

module load R-bundle-Bioconductor/3.15-foss-2021b-R-4.2.0
cd /g/huber/users/naake/GitHub/MsQuality_manuscript/
Rscript 01_cluster_Cherkaoui2022.R
