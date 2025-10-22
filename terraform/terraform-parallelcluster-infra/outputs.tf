# Basic Outputs Required by Scripts
output "vpc_id" {
  description = "ID of the VPC"
  value       = local.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = local.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = local.private_subnet_ids
}

output "compute_subnet_id" {
  description = "ID of the compute subnet"
  value       = local.compute_subnet_id
}

output "head_node_security_group_id" {
  description = "ID of the head node security group"
  value       = aws_security_group.head_node.id
}

output "compute_node_security_group_id" {
  description = "ID of the compute node security group"
  value       = aws_security_group.compute_node.id
}

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = var.enable_efs ? aws_efs_file_system.shared[0].id : null
}

output "fsx_file_system_id" {
  description = "ID of the FSx file system"
  value       = var.enable_fsx_lustre ? aws_fsx_lustre_file_system.shared[0].id : null
}

output "cluster_name" {
  description = "Name of the cluster"
  value       = var.cluster_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "key_name" {
  description = "EC2 Key Pair name"
  value       = var.key_name
}

# Enhanced VPC Outputs
output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.use_existing_vpc ? data.aws_vpc.existing[0].cidr_block : aws_vpc.main[0].cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = local.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.use_existing_vpc ? [] : aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = var.use_existing_vpc ? [] : aws_eip.nat[*].public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = var.use_existing_vpc ? null : aws_route_table.public[0].id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = var.use_existing_vpc ? [] : aws_route_table.private[*].id
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = !var.use_existing_vpc && var.enable_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

# Subnet Details
output "public_subnet_details" {
  description = "Detailed information about public subnets"
  value = var.use_existing_vpc ? {
    for idx, subnet_id in var.existing_public_subnet_ids : idx => {
      id                = subnet_id
      cidr_block        = "N/A (existing subnet)"
      availability_zone = "N/A (existing subnet)"
    }
  } : {
    for idx, subnet in aws_subnet.public : idx => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}

output "private_subnet_details" {
  description = "Detailed information about private subnets"
  value = var.use_existing_vpc ? {
    for idx, subnet_id in var.existing_private_subnet_ids : idx => {
      id                = subnet_id
      cidr_block        = "N/A (existing subnet)"
      availability_zone = "N/A (existing subnet)"
      is_compute_subnet = idx == var.compute_subnet_index
    }
  } : {
    for idx, subnet in aws_subnet.private : idx => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      is_compute_subnet = idx == var.compute_subnet_index
    }
  }
}

# Network Configuration Summary
output "network_configuration" {
  description = "Summary of network configuration"
  value = {
    vpc_cidr              = var.use_existing_vpc ? data.aws_vpc.existing[0].cidr_block : aws_vpc.main[0].cidr_block
    availability_zones    = local.availability_zones
    compute_subnet_index  = var.compute_subnet_index
    compute_subnet_id     = local.compute_subnet_id
    compute_subnet_cidr   = var.use_existing_vpc ? "N/A (existing subnet)" : aws_subnet.private[var.compute_subnet_index].cidr_block
    single_nat_gateway    = var.single_nat_gateway
    enable_vpn_gateway    = var.enable_vpn_gateway
    use_existing_vpc      = var.use_existing_vpc
  }
}

# Additional Outputs for Script Compatibility
output "os_image" {
  description = "OS image for cluster nodes"
  value       = var.os_image
}

output "head_node_instance_type" {
  description = "Instance type for head node"
  value       = var.head_node_instance_type
}

output "enable_dcv" {
  description = "Whether DCV is enabled"
  value       = var.enable_dcv
}

output "root_volume_size" {
  description = "Root volume size in GB"
  value       = var.root_volume_size
}

output "efs_mount_dir" {
  description = "EFS mount directory"
  value       = var.efs_mount_dir
}

output "fsx_mount_dir" {
  description = "FSx mount directory"
  value       = var.fsx_mount_dir
}