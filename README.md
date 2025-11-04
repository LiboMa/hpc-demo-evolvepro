# Why this repo:

Many HCLS IT Engineering Lacks of HPC together with Model deployment experience, but they also need to use the model and deploy it in their daily work.  So that I develop the One-click deployment for the specific model(Evlopro, HCLS), and IaC(Terraform) as well for the customer. So that the similar customer needs can be done quickly.

# EvolvePro model deployment by Parallel Cluster

This guide is used for quick setup [EvolvePro](https://github.com/mat10d/EvolvePro.git)

## Setup environment

### 1. Implement the Infrastructure

See the [README.md](terraform_pcluster_iac/README.md)

### 2. Setup the environment

```bash 
bash -x setup.sh
```

This script will install the environment
* Conda environment
* Evopr git report and proper model and test sample data

### 3. Access the portal with Jupyter notebook  

**get the login token in /var/log/syslog**

**access the jupter url via: http://localhost:8888/ via token**

## Refernce 

* Slurm: https://slurm.schedmd.com/job_state_codes.html 
* Pre-install:  https://docs.aws.amazon.com/parallelcluster/latest/ug/install-v3-virtual-environment.html 
* official github: https://github.com/aws/aws-parallelcluster/tree/v3.13.2?tab=readme-ov-file 
configuration file reference: https://docs.aws.amazon.com/parallelcluster/latest/ug/cluster-configuration-file-v3.html 
* config examples: https://github.com/aws/aws-parallelcluster/tree/release-3.0/cli/tests/pcluster/example_configs 
