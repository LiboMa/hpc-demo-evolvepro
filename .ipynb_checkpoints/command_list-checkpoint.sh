
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-8xl" hellojob.sh
sbatch -p cpu-queue --constraint="cpu-nodes-c7i-4xl" hellojob.sh


sbatch -p gpu-queue --constraint="gpu-nodes-p4d" hellojob.sh
sbatch -p gpu-queue --constraint="gpu-nodes-p5" hellojob.sh

sbatch -p gpu-queue --constraint="gpu-nodes-g6e" hellojob.sh


## show images
pcluster list-official-images


### jupyterlab
jupyter notebook


### show the Qeueu
squeue -u $USER