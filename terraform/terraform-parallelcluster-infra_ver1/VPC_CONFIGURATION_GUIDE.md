# VPC and Subnet Configuration Guide

## 🌐 Overview

This guide provides comprehensive VPC and subnet configuration options for your AWS ParallelCluster infrastructure, giving you full control over networking architecture.

## 🏗️ VPC Architecture

### Standard Architecture (Default)
```
VPC (10.0.0.0/16)
├── Public Subnets (3 AZs)
│   ├── 10.0.1.0/24 (us-east-2a) - Head Node, NAT Gateway
│   ├── 10.0.2.0/24 (us-east-2b) - NAT Gateway
│   └── 10.0.3.0/24 (us-east-2c) - NAT Gateway
├── Private Subnets (3 AZs)
│   ├── 10.0.11.0/24 (us-east-2a) - ALL Compute Nodes ⭐
│   ├── 10.0.12.0/24 (us-east-2b) - EFS Mount Target
│   └── 10.0.13.0/24 (us-east-2c) - EFS Mount Target
└── Internet Gateway + 3 NAT Gateways
```

## ⚙️ VPC Configuration Options

### Basic VPC Settings
```hcl
# VPC CIDR Block
vpc_cidr = "10.0.0.0/16"  # 65,536 total IPs

# DNS Configuration (Required for ParallelCluster)
enable_dns_hostnames = true  # Enable DNS hostnames
enable_dns_support   = true  # Enable DNS support
```

### Alternative VPC CIDR Examples
```hcl
# Large VPC (Class A private)
vpc_cidr = "10.0.0.0/8"     # 16,777,216 IPs (massive)

# Medium VPC (Class B private)  
vpc_cidr = "172.16.0.0/12"  # 1,048,576 IPs (large)

# Small VPC (Class C private)
vpc_cidr = "192.168.0.0/16" # 65,536 IPs (standard)

# Minimal VPC
vpc_cidr = "10.0.0.0/24"    # 256 IPs (dev/test only)
```

## 🌍 Availability Zone Configuration

### Multi-AZ Setup (Recommended)
```hcl
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
```

### Region-Specific Examples
```hcl
# US East 1 (Virginia)
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# US West 2 (Oregon)
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Europe West 1 (Ireland)
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# Asia Pacific Southeast 1 (Singapore)
availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
```

## 🔗 Subnet Configuration

### Public Subnets (Head Node & NAT Gateways)
```hcl
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
map_public_ip_on_launch = true  # Auto-assign public IPs
```

### Private Subnets (Compute Nodes & Storage)
```hcl
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
compute_subnet_index = 0  # ALL compute nodes use first private subnet
```

## 📏 Subnet Sizing Guide

### Subnet Size Reference
| CIDR | Usable IPs | Use Case |
|------|------------|----------|
| /20  | 4,094      | Very large compute clusters (1000+ nodes) |
| /21  | 2,046      | Large compute clusters (500-1000 nodes) |
| /22  | 1,022      | Medium compute clusters (200-500 nodes) |
| /23  | 510        | Small-medium clusters (100-200 nodes) |
| /24  | 254        | Standard clusters (50-100 nodes) |
| /25  | 126        | Small clusters (25-50 nodes) |
| /26  | 62         | Very small clusters (10-25 nodes) |
| /27  | 30         | Minimal dev/test (5-10 nodes) |

### Compute-Optimized Examples

#### Large Compute Cluster
```hcl
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]      # 254 IPs each
private_subnet_cidrs = ["10.0.16.0/20", "10.0.32.0/24", "10.0.33.0/24"]   # 4094, 254, 254 IPs
compute_subnet_index = 0  # Use the large /20 subnet for compute
```

#### Medium Compute Cluster
```hcl
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]      # 254 IPs each
private_subnet_cidrs = ["10.0.16.0/22", "10.0.20.0/24", "10.0.21.0/24"]   # 1022, 254, 254 IPs
compute_subnet_index = 0  # Use the /22 subnet for compute
```

#### Small Development Environment
```hcl
vpc_cidr = "192.168.0.0/24"  # Small VPC for dev/test
public_subnet_cidrs  = ["192.168.0.0/27", "192.168.0.32/27", "192.168.0.64/27"]    # 30 IPs each
private_subnet_cidrs = ["192.168.0.96/27", "192.168.0.128/27", "192.168.0.160/27"] # 30 IPs each
compute_subnet_index = 0
```

## 🌐 NAT Gateway Configuration

### Multi-AZ NAT Gateways (Production Recommended)
```hcl
enable_nat_gateway = true
single_nat_gateway = false  # One NAT Gateway per AZ (high availability)
```

### Single NAT Gateway (Cost Optimization)
```hcl
enable_nat_gateway = true
single_nat_gateway = true   # One NAT Gateway for all AZs (saves ~$90/month)
```

### No NAT Gateway (Private Only)
```hcl
enable_nat_gateway = false  # No internet access for compute nodes
```

## 🔒 Security Considerations

### SSH Access Control
```hcl
# Restrict to your IP (Recommended)
allowed_ssh_cidr = "203.0.113.0/24"  # Replace with your actual IP range

# Corporate network access
allowed_ssh_cidr = "10.0.0.0/8"      # Allow from private networks

# Open access (NOT recommended for production)
allowed_ssh_cidr = "0.0.0.0/0"       # Allow from anywhere
```

### VPN Gateway Integration
```hcl
enable_vpn_gateway = true  # Enable for hybrid cloud connectivity
```

## 🏷️ Subnet Tagging Strategy

Subnets are automatically tagged with:
- **Name**: Descriptive subnet name
- **Type**: Public or Private
- **AZ**: Availability zone
- **CIDR**: Subnet CIDR block
- **ComputeSubnet**: true/false (indicates compute subnet)
- **Purpose**: Compute Nodes or Storage/EFS

## 📊 Configuration Examples

### Example 1: High-Performance Computing
```hcl
# Large VPC for HPC workloads
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

# Standard public subnets
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

# Large compute subnet + standard storage subnets
private_subnet_cidrs = ["10.0.16.0/20", "10.0.32.0/24", "10.0.33.0/24"]
compute_subnet_index = 0  # 4094 IPs for compute nodes

# Multi-AZ NAT for high availability
enable_nat_gateway = true
single_nat_gateway = false
```

### Example 2: Cost-Optimized Development
```hcl
# Smaller VPC for development
vpc_cidr = "172.16.0.0/20"  # 4096 IPs total
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

# Smaller subnets
public_subnet_cidrs = ["172.16.0.0/26", "172.16.0.64/26", "172.16.0.128/26"]    # 62 IPs each
private_subnet_cidrs = ["172.16.1.0/24", "172.16.2.0/26", "172.16.2.64/26"]    # 254, 62, 62 IPs
compute_subnet_index = 0

# Single NAT Gateway for cost savings
enable_nat_gateway = true
single_nat_gateway = true
```

### Example 3: Multi-Region Setup
```hcl
# Different CIDR range to avoid conflicts
vpc_cidr = "172.20.0.0/16"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

public_subnet_cidrs = ["172.20.1.0/24", "172.20.2.0/24", "172.20.3.0/24"]
private_subnet_cidrs = ["172.20.11.0/24", "172.20.12.0/24", "172.20.13.0/24"]
compute_subnet_index = 0

# VPN Gateway for cross-region connectivity
enable_vpn_gateway = true
```

## 🔍 Validation and Testing

### Terraform Validation
```bash
terraform validate
terraform plan -var-file="terraform.tfvars.minimal"
```

### Network Connectivity Testing
```bash
# After deployment, test connectivity
aws ec2 describe-vpcs --filters "Name=tag:ClusterName,Values=my-cluster"
aws ec2 describe-subnets --filters "Name=tag:ClusterName,Values=my-cluster"
aws ec2 describe-nat-gateways --filter "Name=tag:ClusterName,Values=my-cluster"
```

## 💡 Best Practices

1. **Use /24 subnets** for most use cases (254 IPs)
2. **Reserve larger subnets** (/20 or /22) for compute if you plan to scale
3. **Use single NAT Gateway** for dev/test to save costs
4. **Use multi-AZ NAT Gateways** for production high availability
5. **Restrict SSH access** to your IP range or corporate network
6. **Plan CIDR blocks** to avoid conflicts with existing networks
7. **Use consistent naming** and tagging for resource management

## 🚨 Common Issues

### CIDR Overlap
```bash
# Error: CIDR blocks overlap
# Solution: Ensure subnets don't overlap with each other or existing VPCs
```

### Insufficient IPs
```bash
# Error: Not enough IP addresses
# Solution: Use larger subnet (smaller CIDR number)
```

### AZ Availability
```bash
# Error: AZ not available
# Solution: Check available AZs in your region
aws ec2 describe-availability-zones --region us-east-2
```

This comprehensive VPC configuration system provides maximum flexibility while maintaining best practices for AWS ParallelCluster deployments.