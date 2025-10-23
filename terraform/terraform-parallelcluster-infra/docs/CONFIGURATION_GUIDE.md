# AWS ParallelCluster Configuration Guide

## 🎯 Overview

This guide provides comprehensive configuration options for your AWS ParallelCluster infrastructure, based on your specific template requirements.

## 📋 Configuration Files

### 1. `terraform.tfvars.example` - Full Configuration
Complete example with all available options, including:
- Multiple queue types with different instance families
- Advanced storage configurations
- Comprehensive monitoring and tagging
- Detailed comments and instance type reference

### 2. `terraform.tfvars.minimal` - Essential Configuration
Minimal setup matching your ParallelCluster template:
- 4 queues exactly as specified in your template
- Essential head node configuration
- Basic storage and security settings

## 🖥️ Head Node Configuration

### Instance Types
```hcl
head_node_instance_type = "g6.xlarge"  # GPU-enabled for visualization
# Alternatives:
# "t3.medium"   # Cost-effective, no GPU
# "m6i.large"   # Balanced CPU/memory
# "g5.xlarge"   # Previous gen GPU
```

### Operating System
```hcl
os_image = "ubuntu2204"  # Matches your template
# Options: ubuntu2204, ubuntu2404, alinux2, centos7, rhel8, rhel9
```

### Remote Access
```hcl
enable_dcv = true  # Enable DCV remote desktop (matches your template)
```

## 🚀 Compute Queue Configuration

### Queue Types (Based on Your Template)

#### 1. High-Performance GPU Queue
```hcl
"high-gpu-queue" = {
  instance_types = ["p5.4xlarge"]  # H100 GPUs for training/HPC
  min_count     = 0
  max_count     = 4                # Matches your template
  root_volume_size = 120
  enable_placement_group = true    # For high-performance networking
}
```

#### 2. GPU Inference Queue
```hcl
"gpu-queue-inference" = {
  instance_types = ["g6f.2xlarge"]  # L4 GPUs for inference
  min_count     = 0
  max_count     = 10               # Matches your template
  root_volume_size = 120
}
```

#### 3. High CPU Queue
```hcl
"cpu-queue-high" = {
  instance_types = ["c7i.16xlarge"]  # 64 vCPUs, 128 GiB memory
  min_count     = 0
  max_count     = 50                # Matches your template
  root_volume_size = 120
}
```

#### 4. Default CPU Queue
```hcl
"cpu-queue-default" = {
  instance_types = ["c7i.xlarge"]   # 4 vCPUs, 8 GiB memory
  min_count     = 0
  max_count     = 50               # Matches your template
  root_volume_size = 120
}
```

### Advanced Queue Options

#### Multiple Instance Types per Queue
```hcl
"mixed-gpu-queue" = {
  instance_types = ["g6f.2xlarge", "g6f.4xlarge", "g6f.8xlarge"]
  min_count     = 0
  max_count     = 15
}
```

#### Capacity Reservations
```hcl
"reserved-gpu-queue" = {
  instance_types = ["p4d.24xlarge"]
  capacity_reservation_id = "cr-06ec517ae4a3d013e"  # Your reservation ID
  min_count     = 0
  max_count     = 5
}
```

#### Custom Storage per Queue
```hcl
"high-storage-queue" = {
  instance_types = ["c7i.4xlarge"]
  root_volume_size = 500  # Larger storage for this queue
  root_volume_type = "gp3"
  min_count     = 0
  max_count     = 20
}
```

## 💾 Storage Configuration

### EFS (Primary Shared Storage)
```hcl
enable_efs = true
efs_performance_mode = "generalPurpose"  # or "maxIO" for >7000 file ops/sec
efs_throughput_mode = "provisioned"      # or "bursting"
efs_provisioned_throughput = 500         # MiB/s (for provisioned mode)
efs_mount_dir = "/shared"                # Matches your template
```

### FSx Lustre (High-Performance Storage)
```hcl
enable_fsx_lustre = false               # Optional, disabled by default
fsx_storage_capacity = 1200             # GB (minimum)
fsx_deployment_type = "SCRATCH_2"       # Cost-effective
fsx_per_unit_storage_throughput = 200   # MB/s/TiB
fsx_mount_dir = "/fsx"
```

### S3 Integration with FSx
```hcl
fsx_s3_import_path = "s3://my-bucket/input-data/"
fsx_s3_export_path = "s3://my-bucket/results/"
```

## 🔒 Security Configuration

### Network Security
```hcl
allowed_ssh_cidr = "203.0.113.0/24"  # Restrict to your IP range
```

### IAM Policies (Matches Your Template)
```hcl
additional_iam_policies = [
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
]
```

## 🌐 Network Configuration

### VPC Customization
```hcl
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
compute_subnet_index = 0  # All compute nodes use first private subnet
```

## 📊 Monitoring Configuration

### CloudWatch Integration (Matches Your Template)
```hcl
enable_detailed_monitoring = false      # Cost optimization
enable_cloudwatch_logs = true          # Enable logging
cloudwatch_log_retention_days = 14     # Matches your template
```

## 🏷️ Tagging Strategy

### Resource Tags (Matches Your Template)
```hcl
additional_tags = {
  Project     = "ParallelCluster"  # Matches your template
  Environment = "dev"              # Matches your template
  Owner       = "hpc-for-sansheng"
  ManagedBy   = "Terraform"        # Matches your template
}
```

## 🔧 Instance Type Reference

### GPU Instances
| Instance Type | GPUs | GPU Memory | vCPUs | RAM | Use Case |
|---------------|------|------------|-------|-----|----------|
| p5.4xlarge | 1x H100 | 80GB | 16 | 128 GiB | Latest training/HPC |
| p4d.24xlarge | 8x A100 | 40GB each | 96 | 1152 GiB | Multi-GPU training |
| g6f.2xlarge | 1x L4 | 24GB | 8 | 32 GiB | Cost-effective inference |
| g6f.4xlarge | 1x L4 | 24GB | 16 | 64 GiB | Inference + more CPU |

### CPU Instances
| Instance Type | vCPUs | RAM | Network | Use Case |
|---------------|-------|-----|---------|----------|
| c7i.xlarge | 4 | 8 GiB | Up to 12.5 Gbps | General compute |
| c7i.2xlarge | 8 | 16 GiB | Up to 12.5 Gbps | Standard compute |
| c7i.16xlarge | 64 | 128 GiB | 25 Gbps | High-performance compute |
| c7i.24xlarge | 96 | 192 GiB | 37.5 Gbps | Maximum compute |

### Memory-Optimized Instances
| Instance Type | vCPUs | RAM | Use Case |
|---------------|-------|-----|----------|
| r7i.2xlarge | 8 | 64 GiB | High memory workloads |
| r7i.4xlarge | 16 | 128 GiB | Very high memory |
| r7i.8xlarge | 32 | 256 GiB | Extreme memory requirements |

## 🚀 Quick Start Examples

### Minimal Setup (Cost-Optimized)
```bash
cp terraform.tfvars.minimal terraform.tfvars
# Edit key_name and allowed_ssh_cidr
terraform apply
```

### Full-Featured Setup
```bash
cp terraform.tfvars.example terraform.tfvars
# Customize as needed
terraform apply
```

### Custom Queue Setup
```hcl
compute_queues = {
  "my-custom-queue" = {
    instance_types = ["c7i.4xlarge", "c7i.8xlarge"]
    min_count = 0
    max_count = 20
    root_volume_size = 200
    enable_placement_group = false
  }
}
```

This configuration system provides maximum flexibility while maintaining compatibility with your existing ParallelCluster template requirements.