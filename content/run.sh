#!/bin/bash
#SBATCH --job-name=esm-plm
##SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=200gb
#SBATCH --output=/shared/content/output/%j_stdout.log
#SBATCH --error=/shared/content/output/%j_error.log

source /home/ubuntu/anaconda3/etc/profile.d/conda.sh
conda activate evolvepro

export PYTHONPATH="/shared/EvolvePro:$PYTHONPATH"

# 设置多线程环境变量
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
export NUMBA_NUM_THREADS=8
python /shared/content/run.py
