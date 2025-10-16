#!/bin/bash

## install conda environments

install_conda(){

cd runtime-env
curl -O https://repo.anaconda.com/archive/Anaconda3-2025.06-1-Linux-x86_64.sh 
bash -x Anaconda3-2025.06-1-Linux-x86_64.sh

}

## create conda env
#

setup_conda() {

cd /shared/EvolvePro
conda env create -f environment.yml
conda activate evolvepro

source ~/.bashrc

conda init
conda activate evolvepro
pip install -e .
python -m pip install --upgrade jupyter

pwd
}

setup_jupyter_service () {
cd /shared
sudo cp juypter_systemd_config/jupyterlab.service /etc/systemd/system/
sudo systemctl enable jupyterlab
sudo systemctl daemon-reload && sudo systemctl restart jupyterlab
}


install_conda
#setup_condg
setup_jupyter_service
