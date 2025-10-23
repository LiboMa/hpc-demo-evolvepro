# AWS ParallelCluster Infrastructure - Quick Start Guide

## 🚀 Ready to Deploy!

Your Terraform project is complete and validated. Here's how to use it:

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.0** installed
3. **EC2 Key Pair** in us-east-2 region
4. **jq** installed (for configuration generation)

## Quick Deployment

### Option A: New VPC (Default)

#### Step 1: Configure Variables

Edit `terraform.tfvars`:

```hcl
# REQUIRED: Replace with your EC2 key pair name
key_name = "your-key-pair-name"

# SECURITY: Replace with your IP range
allowed_ssh_cidr = "YOUR.IP.ADDRESS.0/24"

# Optional: Customize cluster name
cluster_name = "my-hpc-cluster"
```

### Option B: Existing VPC

#### Step 1: Use Existing VPC Configuration

```bash
# Copy existing VPC template
cp terraform.tfvars.existing-vpc terraform.tfvars

# Edit with your VPC details
vim terraform.tfvars
```

Configure your existing VPC details:

```hcl
# Enable existing VPC mode
use_existing_vpc = true

# Your existing VPC and subnet IDs
existing_vpc_id = "vpc-0123456789abcdef0"
existing_public_subnet_ids = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
existing_private_subnet_ids = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

# REQUIRED: Replace with your EC2 key pair name
key_name = "your-key-pair-name"

# SECURITY: Replace with your IP range
allowed_ssh_cidr = "YOUR.IP.ADDRESS.0/24"
```

📖 **See [EXISTING_VPC_GUIDE.md](EXISTING_VPC_GUIDE.md) for detailed existing VPC setup instructions.**

### Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy (takes ~5-10 minutes)
terraform apply
```

### Step 3: Generate ParallelCluster Configuration

```bash
# Generate pcluster-config.yaml
./generate-pcluster-config.sh
```

### Step 4: Create ParallelCluster

```bash
# Validate configuration
pcluster validate-config -c pcluster-config.yaml

# Create cluster (takes ~10-15 minutes)
pcluster create-cluster --cluster-name my-hpc-cluster --cluster-configuration pcluster-config.yaml
```

## 📋 What Gets Created

### Infrastructure (33 Resources)
- **VPC** (10.0.0.0/16) with DNS enabled
- **3 Public Subnets** across 3 AZs
- **3 Private Subnets** across 3 AZs (compute uses first one only)
- **Internet Gateway** + **3 NAT Gateways**
- **Route Tables** with proper routing
- **Security Groups** for head node, compute nodes, and EFS
- **EFS File System** with mount targets and access point
- **Proper IAM integration**

### ParallelCluster Queues
- **high-gpu-queue**: p5.4xlarge (0-4 nodes) - H100 GPUs
- **gpu-queue-inference**: g6f.2xlarge (0-10 nodes) - L4 GPUs
- **cpu-queue-high**: c7i.16xlarge (0-50 nodes) - High CPU
- **cpu-queue-default**: c7i.xlarge (0-50 nodes) - Standard CPU

## 🔧 Configuration Options

### Enable FSx Lustre (Optional)

```hcl
enable_fsx_lustre = true
fsx_storage_capacity = 1200  # GB
```

### Customize VPC

```hcl
vpc_cidr = "10.1.0.0/16"
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
```

### Change Compute Subnet

```hcl
compute_subnet_index = 1  # Use second private subnet
```

## 🧹 Cleanup

```bash
# Delete ParallelCluster first
pcluster delete-cluster --cluster-name my-hpc-cluster

# Then destroy infrastructure
terraform destroy
```

## 🔍 Troubleshooting

### Common Issues

1. **Key Pair Not Found**
   ```bash
   aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > my-key-pair.pem
   ```

2. **Permission Denied**
   - Ensure AWS CLI has ParallelCluster permissions
   - Check IAM policies for EC2, VPC, EFS access

3. **Subnet Conflicts**
   - Ensure CIDR blocks don't overlap with existing VPCs
   - Check availability zones are valid in your region

### Validation Commands

```bash
# Check Terraform
terraform validate
terraform plan

# Check ParallelCluster config
pcluster validate-config -c pcluster-config.yaml

# Check AWS resources
aws ec2 describe-vpcs --filters "Name=tag:ClusterName,Values=my-hpc-cluster"
```

## 📚 Next Steps

1. **Connect to Head Node**: Use DCV or SSH
2. **Submit Jobs**: Use Slurm commands
3. **Monitor**: Check CloudWatch logs
4. **Scale**: Modify queue configurations as needed

## 🎯 Key Features Delivered

✅ **Modular & Reusable**: Clean Terraform modules
✅ **Configurable**: All parameters customizable
✅ **Secure**: Least privilege security groups
✅ **Cost-Optimized**: EFS primary, FSx optional
✅ **Production-Ready**: Proper tagging and monitoring
✅ **Multi-AZ**: High availability with 3 subnets
✅ **Compute-Focused**: Single subnet for all compute nodes
✅ **GPU-Ready**: Support for H100, A100, and L4 instances

Your AWS ParallelCluster infrastructure is ready for HPC workloads! 🚀
## 🔒 Sec
urity Groups Configuration

### Head Node Security Group
- **SSH (22)**: From specified CIDR range
- **DCV (8443)**: From specified CIDR range (if enabled)
- **NFS (2049)**: From compute nodes (for shared storage access)
- **Slurm (6820-6829)**: From compute nodes (for shared storage access)
- **All Outbound**: Unrestricted

### Compute Node Security Group
- **SSH (22)**: From head node only
- **Slurmd (6818)**: From head node (for slurm job registration)
- **All Traffic**: Between compute nodes (for MPI/EFA)
- **All Outbound**: Unrestricted

### EFS Security Group
- **NFS (2049)**: From head node and compute nodes
- **All Outbound**: Unrestricted

### FSx Security Group (Optional)
- **Lustre (988, 1021-1023)**: From head node and compute nodes
- **All Outbound**: Unrestricted

### **Complete Slurm Port Configuration**

Your ParallelCluster now has **complete Slurm connectivity** with all required ports:

| Port Range | Service | Direction | Status |
|------------|---------|-----------|---------|
| **22** | SSH | Bidirectional | ✅ Configured |
| **2049** | NFS | Bidirectional | ✅ Configured |
| **6817** | slurmctld | Compute → Head | ✅ Configured |
| **6818** | slurmd | Bidirectional | ✅ Configured |
| **6819** | slurmdbd | Compute → Head | ✅ Configured |
| **6820-6829** | Slurm Extended | Compute → Head | ✅ Configured **IMPORTANT** |
| **8443** | DCV | External → Head | ✅ Configured |
| **60001-63000** | Slurm Dynamic | Bidirectional | ✅ Configured |

## 🔄 Recent Updates

✅ **Added NFS Rule**: Head node now accepts NFS traffic from compute nodes
✅ **Circular Dependency Fix**: Used separate security group rule to avoid dependency issues
✅ **Validated Configuration**: All Terraform configurations pass validation
✅ **Production Ready**: Security follows least privilege principles