#!/bin/bash

## install conda environments

install_conda(){

curl https://repo.anaconda.com/archive/Anaconda3-2025.06-1-Linux-x86_64.sh -O runtime-env/Anaconda3-2025.06-1-Linux-x86_64.sh

bash -x runtime-env/Anaconda3-2025.06-1-Linux-x86_64.sh

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

# used for setup jupyter service
echo "this is used for setup jupiter service"

}


install_conda
setup_conda

setup_jupyter_service
