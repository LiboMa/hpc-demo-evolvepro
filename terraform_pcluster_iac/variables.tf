variable "cluster_name" {
  description = "Name of the HPC cluster"
  type        = string
  default     = "sansheng-hpc-cluster"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

# VPC Configuration with Enhanced Controls
variable "use_existing_vpc" {
  description = "Whether to use an existing VPC instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_vpc_id" {
  description = "ID of existing VPC to use (required if use_existing_vpc is true)"
  type        = string
  default     = ""
}

variable "existing_public_subnet_ids" {
  description = "List of existing public subnet IDs (required if use_existing_vpc is true)"
  type        = list(string)
  default     = []
}

variable "existing_private_subnet_ids" {
  description = "List of existing private subnet IDs (required if use_existing_vpc is true)"
  type        = list(string)
  default     = []
}

variable "existing_internet_gateway_id" {
  description = "ID of existing Internet Gateway (optional if use_existing_vpc is true)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (e.g., 10.0.0.0/16, 172.16.0.0/16, 192.168.0.0/16) - only used when creating new VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

# Availability Zone Configuration
variable "availability_zones" {
  description = "List of availability zones to use (must be at least 3 for high availability)"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
  validation {
    condition     = length(var.availability_zones) >= 3
    error_message = "At least 3 availability zones must be specified for high availability."
  }
}

# Public Subnet Configuration
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (for head node and NAT gateways)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  validation {
    condition     = length(var.public_subnet_cidrs) >= 3
    error_message = "At least 3 public subnets must be specified."
  }
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch for instances in public subnets"
  type        = bool
  default     = true
}

# Private Subnet Configuration
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (for compute nodes and storage)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  validation {
    condition     = length(var.private_subnet_cidrs) >= 3
    error_message = "At least 3 private subnets must be specified."
  }
}

# Compute Subnet Selection
variable "compute_subnet_index" {
  description = "Index of private subnet to use for ALL compute nodes (0-based)"
  type        = number
  default     = 0
  validation {
    condition     = var.compute_subnet_index >= 0
    error_message = "Compute subnet index must be 0 or greater."
  }
}

# NAT Gateway Configuration
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway for the VPC"
  type        = bool
  default     = false
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_dcv" {
  description = "Enable DCV for remote desktop"
  type        = bool
  default     = true
}

variable "enable_efs" {
  description = "Enable EFS shared storage"
  type        = bool
  default     = true
}

variable "enable_fsx_lustre" {
  description = "Enable FSx Lustre shared storage"
  type        = bool
  default     = false
}

variable "efs_performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
}

variable "efs_provisioned_throughput" {
  description = "EFS provisioned throughput in MiB/s"
  type        = number
  default     = 250
}

variable "efs_mount_dir" {
  description = "Mount directory for EFS"
  type        = string
  default     = "/shared"
}

variable "fsx_storage_capacity" {
  description = "FSx Lustre storage capacity in GB"
  type        = number
  default     = 1200
}

variable "fsx_deployment_type" {
  description = "FSx Lustre deployment type"
  type        = string
  default     = "SCRATCH_2"
}

variable "fsx_per_unit_storage_throughput" {
  description = "FSx Lustre per unit storage throughput"
  type        = number
  default     = 200
}

variable "fsx_mount_dir" {
  description = "Mount directory for FSx Lustre"
  type        = string
  default     = "/fsx"
}

variable "fsx_s3_import_path" {
  description = "S3 bucket path for FSx Lustre import"
  type        = string
  default     = null
}

variable "fsx_s3_export_path" {
  description = "S3 bucket path for FSx Lustre export"
  type        = string
  default     = null
}
variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "sa-malibo-hpc-east-2"
}

variable "os_image" {
  description = "OS image for cluster nodes"
  type        = string
  default     = "ubuntu2204"
}

variable "head_node_instance_type" {
  description = "Instance type for head node"
  type        = string
  default     = "g6.xlarge"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 120
}

# Enhanced Compute Queues Configuration
variable "compute_queues" {
  description = "Configuration for compute queues with full customization"
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
    "high-gpu-queue" = {
      instance_types = ["p5.4xlarge"]
      min_count     = 0
      max_count     = 4
      root_volume_size = 120
      root_volume_type = "gp3"
      enable_placement_group = true
      capacity_reservation_id = null
    }
    "gpu-queue-inference" = {
      instance_types = ["g6f.2xlarge"]
      min_count     = 0
      max_count     = 10
      root_volume_size = 120
      root_volume_type = "gp3"
      enable_placement_group = true
      capacity_reservation_id = null
    }
    "cpu-queue-high" = {
      instance_types = ["c7i.16xlarge"]
      min_count     = 0
      max_count     = 50
      root_volume_size = 120
      root_volume_type = "gp3"
      enable_placement_group = false
      capacity_reservation_id = null
    }
    "cpu-queue-default" = {
      instance_types = ["c7i.xlarge"]
      min_count     = 0
      max_count     = 50
      root_volume_size = 120
      root_volume_type = "gp3"
      enable_placement_group = false
      capacity_reservation_id = null
    }
  }
}

# Additional IAM Policies
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
}