# Data sources for existing VPC resources
data "aws_vpc" "existing" {
  count = var.use_existing_vpc ? 1 : 0
  id    = var.existing_vpc_id
}

data "aws_subnets" "existing_public" {
  count = var.use_existing_vpc ? 1 : 0
  filter {
    name   = "subnet-id"
    values = var.existing_public_subnet_ids
  }
}

data "aws_subnets" "existing_private" {
  count = var.use_existing_vpc ? 1 : 0
  filter {
    name   = "subnet-id"
    values = var.existing_private_subnet_ids
  }
}

data "aws_internet_gateway" "existing" {
  count = var.use_existing_vpc && var.existing_internet_gateway_id != "" ? 1 : 0
  filter {
    name   = "internet-gateway-id"
    values = [var.existing_internet_gateway_id]
  }
}

# VPC with Enhanced Configuration (only create if not using existing)
resource "aws_vpc" "main" {
  count = var.use_existing_vpc ? 0 : 1

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-vpc"
    Type = "Main VPC"
  })
}

# Internet Gateway (only create if not using existing)
resource "aws_internet_gateway" "main" {
  count = var.use_existing_vpc ? 0 : 1

  vpc_id = aws_vpc.main[0].id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-igw"
  })
}

# Public Subnets (for head node, NAT gateways, and internet access) - only create if not using existing
resource "aws_subnet" "public" {
  count = var.use_existing_vpc ? 0 : length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-public-subnet-${count.index + 1}"
    Type = "Public"
    AZ   = local.availability_zones[count.index]
    CIDR = var.public_subnet_cidrs[count.index]
  })
}

# Private Subnets (for compute nodes and storage) - only create if not using existing
resource "aws_subnet" "private" {
  count = var.use_existing_vpc ? 0 : length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name          = "${var.cluster_name}-private-subnet-${count.index + 1}"
    Type          = "Private"
    AZ            = local.availability_zones[count.index]
    CIDR          = var.private_subnet_cidrs[count.index]
    ComputeSubnet = count.index == var.compute_subnet_index ? "true" : "false"
    Purpose       = count.index == var.compute_subnet_index ? "Compute Nodes" : "Storage/EFS"
  })
}

# Elastic IPs for NAT Gateways (only create if not using existing VPC and NAT is enabled)
resource "aws_eip" "nat" {
  count = !var.use_existing_vpc && var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(aws_subnet.public)) : 0

  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-nat-eip-${count.index + 1}"
    Type = var.single_nat_gateway ? "Single NAT Gateway" : "Multi-AZ NAT Gateway"
  })
}

# NAT Gateways (only create if not using existing VPC and NAT is enabled)
resource "aws_nat_gateway" "main" {
  count = !var.use_existing_vpc && var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(aws_subnet.public)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-nat-gw-${count.index + 1}"
  })
}

# Route Table for Public Subnets (only create if not using existing VPC)
resource "aws_route_table" "public" {
  count = var.use_existing_vpc ? 0 : 1

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-public-rt"
  })
}

# Route Table Associations for Public Subnets (only create if not using existing VPC)
resource "aws_route_table_association" "public" {
  count = var.use_existing_vpc ? 0 : length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Route Tables for Private Subnets (only create if not using existing VPC)
resource "aws_route_table" "private" {
  count = var.use_existing_vpc ? 0 : length(aws_subnet.private)

  vpc_id = aws_vpc.main[0].id

  # Route to NAT Gateway (use single NAT Gateway if enabled, otherwise use per-AZ NAT Gateway)
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-private-rt-${count.index + 1}"
  })
}

# Route Table Associations for Private Subnets (only create if not using existing VPC)
resource "aws_route_table_association" "private" {
  count = var.use_existing_vpc ? 0 : length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPN Gateway (Optional) - only create if not using existing VPC
resource "aws_vpn_gateway" "main" {
  count = !var.use_existing_vpc && var.enable_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-vpn-gw"
    Type = "VPN Gateway"
  })
}

# VPN Gateway Route Propagation (only create if not using existing VPC)
resource "aws_vpn_gateway_route_propagation" "private" {
  count = !var.use_existing_vpc && var.enable_vpn_gateway ? length(aws_route_table.private) : 0

  vpn_gateway_id = aws_vpn_gateway.main[0].id
  route_table_id = aws_route_table.private[count.index].id
}