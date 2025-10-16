#!/bin/bash
# Configuration values for SLURM job submission.
# One leading hash ahead of the word SBATCH is not a comment, but two are.
#SBATCH --time=24:00:00 
#SBATCH --job-name=mutation_processing
#SBATCH -n 1 
#SBATCH -N 1
##SBATCH --gres=gpu:a100:1
##SBATCH --partition=gpu-queue-high
#SBATCH --partition=cpu-queue-default
##SBATCH --constraint=cpu-nodes-c7i-4xl
##SBATCH --mem=80gb
#SBATCH --cpus-per-task=1  
#SBATCH --output /shared/content/output/mutation_aa_processing-%j.out

WORKING_DIR="/shared/EvolvePro"

cd $WORKING_DIR 

source ~/.bashrc

conda activate evolvepro 

# Working Directory
#python prepare_processing.py
/home/ubuntu/anaconda3/envs/evolvepro/bin/python prepare_processing.py

