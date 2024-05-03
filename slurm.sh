#!/bin/bash

# ********************************************************
#--- slurm commands ---
# ********************************************************

#SBATCH --job-name=bcftools
#SBATCH --partition=longrun 	# partition to submit to, e.g. debug, longrun
#SBATCH --time=06:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=20G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=''          # email address

# ********************************************************
# activate conda environment
# ********************************************************

source "${HOME}/miniforge3/etc/profile.d/conda.sh"
conda activate snakemake

# ********************************************************
#--- snakemake commands ---
# ********************************************************
snakemake --unlock

snakemake \
	--use-conda \
	--conda-frontend mamba \
	--cores 4 \
	--jobs 2 \
	--rerun-incomplete

# ********************************************************
#--- end ---
# ********************************************************
conda deactivate
