#!/bin/bash
# Configuration values for SLURM job submission.
# One leading hash ahead of the word SBATCH is not a comment, but two are.
#SBATCH --time=24:00:00 
#SBATCH --job-name=run_evolve_rounds
#SBATCH -n 1 
#SBATCH -N 1
##SBATCH --gres=gpu:a100:8
#SBATCH --partition=gpu-queue-infernece
## SBATCH --constraint=gpu-nodes-g6e
#SBATCH --mem=80gb
##SBATCH --cpus-per-task=1  
#SBATCH --output /shared/content/output/run_evolve_rounds-%j.out

WORKING_DIR="/shared/EvolvePro"

cd $WORKING_DIR 

source ~/.bashrc
conda activate evolvepro 

# Working Directory
/home/ubuntu/anaconda3/envs/evolvepro/bin/python run_evolvepro_rounds.py

