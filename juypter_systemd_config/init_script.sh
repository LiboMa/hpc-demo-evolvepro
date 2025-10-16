#!/bin/bash 
#

## install Anconda env
curl https://repo.anaconda.com/archive/Anaconda3-2025.06-1-Linux-x86_64.sh -O Anaconda3-2025.06-1-Linux-x86_64.sh

bash -x Anaconda3-2025.06-1-Linux-x86_64.sh

## init evop env
#

cd ../

git clone https://github.com/mat10d/EvolvePro.git

cd EvolvePro
conda env create -f environment.yml
conda activate evolvepro

## Setup jupyter env

cd 
