# ============================================================================
# AWS ParallelCluster Infrastructure Configuration
# ============================================================================

# Basic Configuration
aws_region   = "us-east-2"
cluster_name = "sansheng-hpc-cluster"
key_name     = "sa-malibo-hpc-east-2"

# VPC and Networking Configuration
# Option 1: Create new VPC (default)
use_existing_vpc     = false
vpc_cidr             = "10.197.0.0/16"
availability_zones   = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnet_cidrs  = ["10.197.1.0/24", "10.197.2.0/24", "10.197.3.0/24"]
private_subnet_cidrs = ["10.197.11.0/24", "10.197.12.0/24", "10.197.13.0/24"]

# Option 2: Use existing VPC (uncomment and configure if needed)
# use_existing_vpc              = true
# existing_vpc_id               = "vpc-xxxxxxxxx"
# existing_public_subnet_ids    = ["subnet-xxxxxxxxx", "subnet-yyyyyyyyy", "subnet-zzzzzzzzz"]
# existing_private_subnet_ids   = ["subnet-aaaaaaaaa", "subnet-bbbbbbbbb", "subnet-ccccccccc"]
# existing_internet_gateway_id  = "igw-xxxxxxxxx"  # Optional

compute_subnet_index = 0
allowed_ssh_cidr     = "0.0.0.0/0" # CHANGE THIS TO YOUR IP RANGE

# DNS Configuration
enable_dns_hostnames = true
enable_dns_support   = true

# Public Subnet Options
map_public_ip_on_launch = true

# NAT Gateway Configuration
enable_nat_gateway = true
single_nat_gateway = true

# VPN Gateway (optional)
enable_vpn_gateway = false

# Head Node Configuration
os_image                = "ubuntu2204"
head_node_instance_type = "g6.xlarge"
enable_dcv              = true
root_volume_size        = 120

# Compute Queues Configuration
compute_queues = {
  "high-gpu-queue" = {
    instance_types          = ["p5.4xlarge"]
    min_count               = 0
    max_count               = 4
    root_volume_size        = 120
    root_volume_type        = "gp3"
    enable_placement_group  = true
    capacity_reservation_id = null
  }
  "gpu-queue-inference" = {
    instance_types          = ["g6f.2xlarge"]
    min_count               = 0
    max_count               = 10
    root_volume_size        = 120
    root_volume_type        = "gp3"
    enable_placement_group  = true
    capacity_reservation_id = null
  }
  "cpu-queue-high" = {
    instance_types          = ["c7i.16xlarge"]
    min_count               = 0
    max_count               = 50
    root_volume_size        = 120
    root_volume_type        = "gp3"
    enable_placement_group  = false
    capacity_reservation_id = null
  }
  "cpu-queue-default" = {
    instance_types          = ["c7i.xlarge"]
    min_count               = 0
    max_count               = 50
    root_volume_size        = 120
    root_volume_type        = "gp3"
    enable_placement_group  = false
    capacity_reservation_id = null
  }
}

# Storage Configuration
enable_efs                 = true
efs_performance_mode       = "generalPurpose"
efs_throughput_mode        = "bursting"
efs_provisioned_throughput = 250
efs_mount_dir              = "/shared"

enable_fsx_lustre               = false
fsx_storage_capacity            = 1200
fsx_deployment_type             = "SCRATCH_2"
fsx_per_unit_storage_throughput = 200
fsx_mount_dir                   = "/fsx"
fsx_s3_import_path              = null
fsx_s3_export_path              = null

# IAM and Security Configuration
additional_iam_policies = [
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
]

# Monitoring Configuration
enable_detailed_monitoring    = false
enable_cloudwatch_logs        = true
cloudwatch_log_retention_days = 14

# Resource Tagging
additional_tags = {
  Environment = "dev"
  Project     = "ParallelCluster"
  Owner       = "hpc-for-sansheng"
}
