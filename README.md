### Setup environment
https://stackoverflow.com/questions/58068818/how-to-use-jupyter-notebooks-in-a-conda-environment


### Setup the demo


### job script


```bash
gpu-queue-high*        up   infinite      1   idle gpu-queue-high-st-gpu-nodes-p4d-1
gpu-queue-infernece    up   infinite     10  idle~ gpu-queue-infernece-dy-gpu-nodes-g6e-[1-10]
cpu-queue-high         up   infinite     50  idle~ cpu-queue-high-dy-highcpu-nodes-[1-50]
cpu-queue-default      up   infinite     50  idle~ cpu-queue-default-dy-defaultcpu-nodes-[1-50]
```# hpc-demo-evolvepro
