#!/bin/bash
# Configuration values for SLURM job submission.

cp jupyterlab.service /etc/systemd/system/
sudo systemctl enable jupyterlab
sudo systemctl daemon-reload && sudo systemctl restart jupyterlab