#!/bin/bash
#SBATCH -A huber                	# group to which you belong
#SBATCH -N 1                        # number of nodes
#SBATCH -n 10                       # number of cores
#SBATCH --mem 64G                  # memory pool for all cores
#SBATCH -t 14-0:00:00                # runtime limit (D-HH:MM:SS)
#SBATCH -o slurm.%N.%j.out          # STDOUT
#SBATCH -e slurm.%N.%j.err          # STDERR
#SBATCH --mail-type=END,FAIL        # notifications for job done & fail
#SBATCH --mail-user=naake@embl.de # send-to address


cd /g/huber/users/naake/GitHub/MsQuality_manuscript/Amidan2014
./bumbershoot/quameter /scratch/naake/Amidan2014/3_of_5/*.mzML -MetricsType idfree -OutputFilepath metrics_quameter_03.tsv -cpus 10
