# Terraform AWS ParallelCluster Infrastructure - Comprehensive Project Specification

## Project Overview

Create a complete Terraform project to provision AWS infrastructure for AWS ParallelCluster, including VPC with 3 subnets (using only 1 for compute), security groups, EFS (primary), and optional FSx Lustre shared storage.

## Requirements Based on Your Configuration Template

### 1. AWS Region and Basic Setup

- **Region**: us-east-2 (as specified in your template)
- **Terraform Version**: >= 1.0
- **AWS Provider**: ~> 5.0

### 2. VPC Configuration (Fully Configurable)

- **CIDR Block**: Configurable (default: 10.0.0.0/16)
- **Availability Zones**: Configurable list (default: us-east-2a, us-east-2b, us-east-2c)
- **Subnets Structure**: Fully configurable CIDR blocks
  - Public subnets (default: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24) - for head node and NAT gateways
  - Private subnets (default: 10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24) - for compute nodes
- **Compute Subnet Selection**: Configurable index (default: first private subnet)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateways**: One per AZ for private subnet internet access
- **Route Tables**: Proper routing for public/private subnets
- **DNS**: Enable DNS hostnames and DNS support

### 3. Security Groups (Based on Your Template)

- **Head Node Security Group**:
  - SSH (port 22) from configurable CIDR (default: your IP)
  - DCV remote desktop (port 8443) from configurable CIDR
  - HTTPS (port 443) outbound for package downloads
  - NFS (port 2049) from compute node security groups
  - All outbound traffic
- **Compute Node Security Group**:
  - SSH from head node security group
  - All traffic between compute nodes (for MPI, EFA communication)
  - All outbound traffic for package downloads
- **EFS Security Group**:
  - NFS (port 2049) from head node and compute node security groups
- **FSx Security Group** (Optional):
  - Lustre ports (988, 1021-1023) from head node and compute nodes

### 4. Storage Configuration (Fully Configurable)

#### EFS (Primary - Configurable)

- **Enable/Disable**: Configurable (default: enabled)
- **Encryption**: Enabled at rest and in transit
- **Performance Mode**: Configurable (generalPurpose/maxIO, default: generalPurpose)
- **Throughput Mode**: Configurable (bursting/provisioned, default: bursting)
- **Provisioned Throughput**: Configurable (1-4000 MiB/s, default: 250)
- **Mount Directory**: Configurable (default: /shared)
- **Mount Targets**: In all private subnets for redundancy
- **Access Point**:
  - Path: Configurable mount directory
  - POSIX user: uid/gid 1000
  - Permissions: 755
- **Backup**: Enabled with configurable retention

#### FSx for Lustre (Optional - Fully Configurable)

- **Enable/Disable**: Configurable (default: disabled)
- **Deployment Type**: Configurable (SCRATCH_1/SCRATCH_2/PERSISTENT_1/PERSISTENT_2, default: SCRATCH_2)
- **Storage Capacity**: Configurable (1200-19200 GB in valid increments, default: 1200)
- **Throughput**: Configurable (50/100/200 MB/s/TiB, default: 200)
- **Mount Directory**: Configurable (default: /fsx)
- **Subnet**: Uses selected compute subnet
- **Security Group**: FSx security group
- **S3 Integration**: Configurable import/export paths (optional)

### 5. Variables Configuration (Fully Configurable)

```hcl
# Required Variables
variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "3s-hpc-key"  # From your template
}

# Basic Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Name of the HPC cluster"
  type        = string
  default     = "sansheng-hpc-cluster"
}

# VPC Configuration (Fully Configurable)
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "compute_subnet_index" {
  description = "Index of private subnet to use for compute nodes (0-based)"
  type        = number
  default     = 0
  validation {
    condition     = var.compute_subnet_index >= 0 && var.compute_subnet_index < 3
    error_message = "Compute subnet index must be between 0 and 2."
  }
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # Should be restricted to your IP
}

# Instance Configuration (Fully Configurable)
variable "os_image" {
  description = "OS image for cluster nodes"
  type        = string
  default     = "ubuntu2404"
  validation {
    condition = contains([
      "ubuntu2404", "ubuntu2204", "ubuntu2004",
      "alinux2", "centos7", "rhel8", "rhel9"
    ], var.os_image)
    error_message = "OS image must be one of: ubuntu2404, ubuntu2204, ubuntu2004, alinux2, centos7, rhel8, rhel9."
  }
}

variable "head_node_instance_type" {
  description = "Instance type for head node"
  type        = string
  default     = "g6.xlarge"
}

variable "enable_dcv" {
  description = "Enable DCV for remote desktop"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 120
  validation {
    condition     = var.root_volume_size >= 20 && var.root_volume_size <= 1000
    error_message = "Root volume size must be between 20 and 1000 GB."
  }
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
  validation {
    condition = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2."
  }
}

# Queue Configuration (Configurable Instance Types)
variable "compute_queues" {
  description = "Configuration for compute queues"
  type = map(object({
    instance_types = list(string)
    min_count     = number
    max_count     = number
    root_volume_size = optional(number, 120)
    root_volume_type = optional(string, "gp3")
    enable_placement_group = optional(bool, true)
    capacity_reservation_id = optional(string, null)
  }))
  default = {
    "gpu-queue-h100" = {
      instance_types = ["p5.4xlarge"]
      min_count     = 0
      max_count     = 5
      capacity_reservation_id = "cr-083bf84b0fe759052"
    }
    "gpu-queue-a100" = {
      instance_types = ["p4d.24xlarge"]
      min_count     = 0
      max_count     = 5
      capacity_reservation_id = "cr-06ec517ae4a3d013e"
    }
    "gpu-queue-inference" = {
      instance_types = ["g6f.2xlarge"]
      min_count     = 0
      max_count     = 10
    }
    "cpu-queue-high" = {
      instance_types = ["c7i.16xlarge"]
      min_count     = 0
      max_count     = 50
    }
    "cpu-queue-default" = {
      instance_types = ["c7i.2xlarge"]
      min_count     = 0
      max_count     = 50
    }
  }
}

# Storage Configuration (Fully Configurable)
variable "enable_efs" {
  description = "Enable EFS shared storage"
  type        = bool
  default     = true
}

variable "efs_performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"
  validation {
    condition = contains(["generalPurpose", "maxIO"], var.efs_performance_mode)
    error_message = "EFS performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
  validation {
    condition = contains(["bursting", "provisioned"], var.efs_throughput_mode)
    error_message = "EFS throughput mode must be either 'bursting' or 'provisioned'."
  }
}

variable "efs_provisioned_throughput" {
  description = "EFS provisioned throughput in MiB/s (only used if throughput_mode is provisioned)"
  type        = number
  default     = 250
  validation {
    condition     = var.efs_provisioned_throughput >= 1 && var.efs_provisioned_throughput <= 4000
    error_message = "EFS provisioned throughput must be between 1 and 4000 MiB/s."
  }
}

variable "efs_mount_dir" {
  description = "Mount directory for EFS"
  type        = string
  default     = "/shared"
}

variable "enable_fsx_lustre" {
  description = "Enable FSx Lustre shared storage"
  type        = bool
  default     = false
}

variable "fsx_storage_capacity" {
  description = "FSx Lustre storage capacity in GB"
  type        = number
  default     = 1200
  validation {
    condition = contains([1200, 2400, 4800, 7200, 9600, 12000, 14400, 16800, 19200], var.fsx_storage_capacity)
    error_message = "FSx Lustre storage capacity must be one of: 1200, 2400, 4800, 7200, 9600, 12000, 14400, 16800, 19200 GB."
  }
}

variable "fsx_deployment_type" {
  description = "FSx Lustre deployment type"
  type        = string
  default     = "SCRATCH_2"
  validation {
    condition = contains(["SCRATCH_1", "SCRATCH_2", "PERSISTENT_1", "PERSISTENT_2"], var.fsx_deployment_type)
    error_message = "FSx deployment type must be one of: SCRATCH_1, SCRATCH_2, PERSISTENT_1, PERSISTENT_2."
  }
}

variable "fsx_per_unit_storage_throughput" {
  description = "FSx Lustre per unit storage throughput"
  type        = number
  default     = 200
  validation {
    condition = contains([50, 100, 200], var.fsx_per_unit_storage_throughput)
    error_message = "FSx per unit storage throughput must be one of: 50, 100, 200 MB/s/TiB."
  }
}

variable "fsx_mount_dir" {
  description = "Mount directory for FSx Lustre"
  type        = string
  default     = "/fsx"
}

variable "fsx_s3_import_path" {
  description = "S3 bucket path for FSx Lustre import (optional)"
  type        = string
  default     = null
}

variable "fsx_s3_export_path" {
  description = "S3 bucket path for FSx Lustre export (optional)"
  type        = string
  default     = null
}

# Additional IAM Policies (Configurable)
variable "additional_iam_policies" {
  description = "Additional IAM policies to attach to compute nodes"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
}

# Monitoring Configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for instances"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_log_retention_days)
    error_message = "CloudWatch log retention must be a valid retention period."
  }
}

# Tagging (Configurable)
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

### 6. Outputs Required

```hcl
# Network Outputs
output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "compute_subnet_id" { value = aws_subnet.private[0].id }  # Only first subnet

# Security Group Outputs
output "head_node_security_group_id" { value = aws_security_group.head_node.id }
output "compute_node_security_group_id" { value = aws_security_group.compute_node.id }

# Storage Outputs
output "efs_file_system_id" {
  value = var.enable_efs ? aws_efs_file_system.shared[0].id : null
}
output "efs_access_point_id" {
  value = var.enable_efs ? aws_efs_access_point.shared[0].id : null
}
output "fsx_file_system_id" {
  value = var.enable_fsx_lustre ? aws_fsx_lustre_file_system.shared[0].id : null
}

# Configuration Outputs for ParallelCluster
output "cluster_name" { value = var.cluster_name }
output "aws_region" { value = var.aws_region }
output "key_name" { value = var.key_name }
```

### 7. Tags Strategy

All resources should be tagged with:

```hcl
locals {
  common_tags = {
    Environment = "hpc-demo"
    Project     = "sansheng-hpc"
    Owner       = "hpc-for-sansheng"
    ManagedBy   = "terraform"
    ClusterName = var.cluster_name
  }
}
```

### 8. File Structure

```
terraform-parallelcluster-infra/
├── main.tf                      # Provider, VPC, subnets, routing
├── variables.tf                 # All configurable input variables
├── security_groups.tf           # Security groups for head/compute/storage
├── storage.tf                   # EFS and FSx Lustre resources
├── outputs.tf                   # All output values
├── locals.tf                    # Local values and tags
├── versions.tf                  # Terraform and provider versions
├── README.md                    # Comprehensive documentation
├── terraform.tfvars.example     # Example variables file with all options
├── terraform.tfvars.minimal     # Minimal example with required variables only
├── pcluster-config-template.yaml # ParallelCluster config template
└── generate-pcluster-config.sh  # Updated helper script
```

### 9. ParallelCluster Integration (Fully Configurable)

- Generate `pcluster-config-template.yaml` that uses Terraform outputs
- Update `generate-pcluster-config.sh` to work with new infrastructure
- **Configurable Queue System**: Define any number of queues with custom:
  - Instance types (multiple per queue supported)
  - Min/max counts
  - Root volume size and type
  - Placement groups
  - Capacity reservations
- **Default Queue Configurations** (fully customizable):
  - gpu-queue-h100: p5.4xlarge (0-5 nodes) - H100 GPUs with capacity reservation
  - gpu-queue-a100: p4d.24xlarge (0-5 nodes) - A100 GPUs with capacity reservation
  - gpu-queue-inference: g6f.2xlarge (0-10 nodes) - L4 GPUs for inference
  - cpu-queue-high: c7i.16xlarge (0-50 nodes) - High-performance CPU
  - cpu-queue-default: c7i.2xlarge (0-50 nodes) - Standard CPU

### 10. Validation Requirements

1. **Syntax Validation**: All .tf files must pass `terraform validate`
2. **Plan Validation**: `terraform plan` should show expected resources
3. **Security Validation**: Security groups properly configured
4. **Network Validation**: Proper subnet routing and NAT gateway setup
5. **Storage Validation**: EFS mount targets in correct subnets
6. **Integration Validation**: Generated ParallelCluster config should be valid

### 11. Success Criteria

- ✅ All Terraform files syntactically correct
- ✅ `terraform init` and `terraform validate` pass
- ✅ `terraform plan` shows expected infrastructure
- ✅ VPC has 3 subnets but compute uses only first private subnet
- ✅ EFS enabled by default with proper security
- ✅ FSx Lustre optional and configurable
- ✅ Security groups allow proper ParallelCluster communication
- ✅ All resources properly tagged
- ✅ ParallelCluster config generation works
- ✅ Supports your specific queue and instance configurations

### 12. Implementation Priority

1. **Phase 1**: Core infrastructure (VPC, subnets, security groups)
2. **Phase 2**: EFS storage (primary requirement)
3. **Phase 3**: FSx Lustre (optional)
4. **Phase 4**: ParallelCluster integration and validation
5. **Phase 5**: Documentation and examples

### 13. Configuration Examples

#### terraform.tfvars.example (Full Configuration)

```hcl
# Basic Configuration
aws_region   = "us-east-2"
cluster_name = "my-hpc-cluster"
key_name     = "my-key-pair"

# VPC Configuration
vpc_cidr               = "10.0.0.0/16"
availability_zones     = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
compute_subnet_index   = 0  # Use first private subnet for compute
allowed_ssh_cidr       = "203.0.113.0/24"  # Replace with your IP

# Instance Configuration
os_image                 = "ubuntu2404"
head_node_instance_type  = "g6.xlarge"
enable_dcv              = true
root_volume_size        = 120
root_volume_type        = "gp3"

# Compute Queues (Fully Customizable)
compute_queues = {
  "gpu-h100" = {
    instance_types = ["p5.4xlarge"]  # H100 GPUs - Latest and most powerful
    min_count     = 0
    max_count     = 5
    capacity_reservation_id = "cr-083bf84b0fe759052"
    root_volume_size = 200
  }
  "gpu-a100" = {
    instance_types = ["p4d.24xlarge"]  # A100 GPUs - High performance
    min_count     = 0
    max_count     = 5
    capacity_reservation_id = "cr-06ec517ae4a3d013e"
  }
  "gpu-inference" = {
    instance_types = ["g6f.2xlarge", "g6f.4xlarge"]  # L4 GPUs - Cost-effective inference
    min_count     = 0
    max_count     = 10
    root_volume_size = 200
  }
  "cpu-high" = {
    instance_types = ["c7i.16xlarge", "c7i.24xlarge"]  # High-performance CPU
    min_count     = 0
    max_count     = 50
  }
  "cpu-default" = {
    instance_types = ["c7i.2xlarge"]  # Standard CPU
    min_count     = 0
    max_count     = 50
  }
}

# Storage Configuration
enable_efs                    = true
efs_performance_mode          = "generalPurpose"
efs_throughput_mode          = "provisioned"
efs_provisioned_throughput   = 500
efs_mount_dir               = "/shared"

enable_fsx_lustre           = true
fsx_storage_capacity        = 2400
fsx_deployment_type         = "SCRATCH_2"
fsx_per_unit_storage_throughput = 200
fsx_mount_dir              = "/fsx"
fsx_s3_import_path         = "s3://my-bucket/data/"
fsx_s3_export_path         = "s3://my-bucket/results/"

# Additional Configuration
additional_iam_policies = [
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
]

enable_detailed_monitoring     = false
enable_cloudwatch_logs        = true
cloudwatch_log_retention_days = 14

additional_tags = {
  Environment = "production"
  Project     = "my-hpc-project"
  Owner       = "my-team"
}
```

#### terraform.tfvars.minimal (Minimal Configuration)

```hcl
# Required
key_name = "my-key-pair"

# Basic customization
cluster_name = "my-cluster"
allowed_ssh_cidr = "203.0.113.0/24"  # Your IP range

# Simple queue configuration with GPU support
compute_queues = {
  "gpu-h100" = {
    instance_types = ["p5.4xlarge"]  # H100 GPUs
    min_count     = 0
    max_count     = 2
  }
  "cpu-default" = {
    instance_types = ["c7i.2xlarge"]
    min_count     = 0
    max_count     = 10
  }
}

# Use EFS only (FSx disabled by default)
enable_efs = true
enable_fsx_lustre = false
```

## Ready to Proceed?

This enhanced specification now provides **FULL CONFIGURABILITY** for:

- ✅ **VPC & Subnets**: Custom CIDR blocks, AZs, and subnet selection
- ✅ **Instance Types**: Configurable queues with multiple instance types per queue
- ✅ **Storage**: Complete EFS and FSx Lustre configuration options
- ✅ **Networking**: Custom security groups and access controls
- ✅ **Monitoring**: Configurable CloudWatch and detailed monitoring
- ✅ **Tagging**: Custom tags for resource management
- ✅ **Validation**: Input validation for all critical parameters

**Key Configurability Features:**

- **Queue System**: Define unlimited queues with custom instance types, counts, and settings
- **Storage Flexibility**: Choose EFS, FSx, both, or neither with full parameter control
- **Network Customization**: Custom VPC, subnets, and compute subnet selection
- **Instance Variety**: Support for any EC2 instance type with validation
- **Capacity Reservations**: Optional capacity reservation integration
- **S3 Integration**: Optional FSx Lustre S3 import/export paths

Would you like me to proceed with implementing this fully configurable Terraform project?
