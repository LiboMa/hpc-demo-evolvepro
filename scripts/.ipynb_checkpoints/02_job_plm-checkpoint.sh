#!/bin/bash
# Configuration values for SLURM job submission.
# One leading hash ahead of the word SBATCH is not a comment, but two are.

#SBATCH --time=24:00:00 
##SBATCH -x node[110]
#SBATCH --job-name=esm_plm
#SBATCH -n 1
#SBATCH -N 1   
#SBATCH --partition=gpu-queue-high
##SBATCH --gres=gpu:a100:8
#SBATCH --cpus-per-task=1
#SBATCH --constraint=gpu-nodes-p4d
#SBATCH --mem=80gb  
#SBATCH --output /shared/content/output/esm_plm-%j.out


OUTPUT=${1:-"/shared/content/output"}
WORKING_DIR=/shared/EvolvePro

cd $WORKING_DIR

source ~/.bashrc

# conda init bash
# conda activate plm

# /home/ubuntu/anaconda3/envs/plm/bin/python evolvepro/plm/esm/extract.py esm1b_t33_650M_UR50S $OUTPUT/kelsic.fasta $OUTPUT/kelsic_esm1b_t33_650M_UR50S \
/home/ubuntu/anaconda3/envs/evolvepro/bin/python evolvepro/plm/esm/extract.py esm1b_t33_650M_UR50S $OUTPUT/kelsic.fasta $OUTPUT/kelsic_esm1b_t33_650M_UR50S \
    --toks_per_batch 512 \
    --include mean \
    --concatenate_dir $OUTPUT
