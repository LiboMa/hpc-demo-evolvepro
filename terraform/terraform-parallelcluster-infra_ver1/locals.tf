locals {
  # Validation checks for existing VPC configuration
  validate_existing_vpc = var.use_existing_vpc ? (
    var.existing_vpc_id != "" ? true : tobool("existing_vpc_id must be provided when use_existing_vpc is true")
  ) : true

  validate_existing_public_subnets = var.use_existing_vpc ? (
    length(var.existing_public_subnet_ids) > 0 ? true : tobool("existing_public_subnet_ids must be provided when use_existing_vpc is true")
  ) : true

  validate_existing_private_subnets = var.use_existing_vpc ? (
    length(var.existing_private_subnet_ids) > 0 ? true : tobool("existing_private_subnet_ids must be provided when use_existing_vpc is true")
  ) : true

  validate_compute_subnet_index = var.use_existing_vpc ? (
    var.compute_subnet_index < length(var.existing_private_subnet_ids) ? true : tobool("compute_subnet_index must be within bounds of existing_private_subnet_ids")
  ) : (
    var.compute_subnet_index < length(var.private_subnet_cidrs) ? true : tobool("compute_subnet_index must be within bounds of private_subnet_cidrs")
  )

  # Common tags applied to all resources
  common_tags = merge({
    Environment = "hpc-demo"
    Project     = "sansheng-hpc"
    Owner       = "hpc-for-sansheng"
    ManagedBy   = "terraform"
    ClusterName = var.cluster_name
  }, var.additional_tags)

  # Availability zones - use provided list or default to first 3 AZs in region
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names

  # VPC ID - use existing or created VPC
  vpc_id = var.use_existing_vpc ? var.existing_vpc_id : aws_vpc.main[0].id

  # Subnet IDs - use existing or created subnets
  public_subnet_ids  = var.use_existing_vpc ? var.existing_public_subnet_ids : aws_subnet.public[*].id
  private_subnet_ids = var.use_existing_vpc ? var.existing_private_subnet_ids : aws_subnet.private[*].id

  # Compute subnet selection
  compute_subnet_id = var.use_existing_vpc ? var.existing_private_subnet_ids[var.compute_subnet_index] : aws_subnet.private[var.compute_subnet_index].id

  # Internet Gateway ID - use existing or created IGW
  internet_gateway_id = var.use_existing_vpc ? (var.existing_internet_gateway_id != "" ? var.existing_internet_gateway_id : null) : aws_internet_gateway.main[0].id
}

# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}