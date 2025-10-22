# Using Existing VPC with ParallelCluster Infrastructure

This guide explains how to configure the ParallelCluster infrastructure to use an existing VPC instead of creating a new one.

## Overview

The infrastructure supports two deployment modes:
1. **New VPC Mode** (default): Creates a complete new VPC with subnets, NAT gateways, etc.
2. **Existing VPC Mode**: Uses your existing VPC and subnets

## When to Use Existing VPC

Use existing VPC mode when:
- You have existing networking infrastructure you want to reuse
- You need to integrate with existing resources in your VPC
- You have specific networking requirements already configured
- You want to avoid creating duplicate networking resources

## Prerequisites for Existing VPC

Your existing VPC must have:

### Required Resources
- **VPC**: A VPC with DNS hostnames and DNS support enabled
- **Public Subnets**: At least 1 public subnet (for head node)
- **Private Subnets**: At least 1 private subnet (for compute nodes)
- **Internet Gateway**: Attached to the VPC for internet access

### Recommended Resources
- **NAT Gateway/Instance**: For private subnet internet access (if compute nodes need internet)
- **Route Tables**: Properly configured for public and private subnets
- **Security Groups**: Existing security groups (optional, new ones will be created)

## Configuration Steps

### Step 1: Gather VPC Information

Collect the following information from your existing VPC:

```bash
# Get VPC ID
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=your-vpc-name"

# Get subnet IDs
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Get Internet Gateway ID
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=vpc-xxxxxxxxx"
```

### Step 2: Configure terraform.tfvars

Create a configuration file or modify `terraform.tfvars`:

```hcl
# Enable existing VPC mode
use_existing_vpc = true

# VPC Configuration
existing_vpc_id = "vpc-0123456789abcdef0"

# Subnet Configuration
existing_public_subnet_ids = [
  "subnet-0123456789abcdef0",  # Public subnet 1
  "subnet-0123456789abcdef1",  # Public subnet 2
  "subnet-0123456789abcdef2"   # Public subnet 3
]

existing_private_subnet_ids = [
  "subnet-0123456789abcdef3",  # Private subnet 1 (compute nodes)
  "subnet-0123456789abcdef4",  # Private subnet 2 (storage)
  "subnet-0123456789abcdef5"   # Private subnet 3 (storage)
]

# Optional: Internet Gateway ID
existing_internet_gateway_id = "igw-0123456789abcdef0"

# Compute subnet selection
compute_subnet_index = 0  # Use first private subnet for compute nodes

# Disable NAT Gateway creation (assuming existing VPC has NAT)
enable_nat_gateway = false
```

### Step 3: Use Example Configuration

Copy the example configuration:

```bash
cp terraform.tfvars.existing-vpc terraform.tfvars
# Edit terraform.tfvars with your actual VPC details
```

## Important Configuration Notes

### Subnet Requirements

1. **Public Subnets**: Used for:
   - Head node (if you want it in public subnet)
   - NAT gateways (if creating new ones)
   - Load balancers (future use)

2. **Private Subnets**: Used for:
   - Compute nodes (specified by `compute_subnet_index`)
   - EFS mount targets
   - FSx file systems

### Compute Subnet Selection

The `compute_subnet_index` parameter determines which private subnet will host ALL compute nodes:

```hcl
compute_subnet_index = 0  # Use first private subnet
# All compute queues will use: existing_private_subnet_ids[0]
```

### Security Groups

New security groups will be created even when using existing VPC:
- Head node security group
- Compute node security group  
- EFS security group (if enabled)
- FSx security group (if enabled)

### NAT Gateway Considerations

When using existing VPC:
- Set `enable_nat_gateway = false` if your VPC already has NAT connectivity
- Set `enable_nat_gateway = true` only if you want to create additional NAT gateways

## Validation

The configuration includes validation to ensure:
- `existing_vpc_id` is provided when `use_existing_vpc = true`
- `existing_public_subnet_ids` list is not empty
- `existing_private_subnet_ids` list is not empty
- `compute_subnet_index` is within bounds of private subnets

## Example Deployment

```bash
# 1. Configure for existing VPC
cp terraform.tfvars.existing-vpc terraform.tfvars
vim terraform.tfvars  # Edit with your VPC details

# 2. Initialize and plan
terraform init
terraform plan

# 3. Apply configuration
terraform apply

# 4. Generate ParallelCluster config
./generate-pcluster-config.sh

# 5. Create cluster
pcluster create-cluster --cluster-name sansheng-hpc-cluster --cluster-configuration pcluster-config.yaml
```

## Troubleshooting

### Common Issues

1. **Invalid VPC ID**: Ensure the VPC exists and you have access
2. **Subnet not found**: Verify subnet IDs are correct and in the specified VPC
3. **No internet access**: Ensure NAT gateway or NAT instance exists for private subnets
4. **Security group errors**: Check that the VPC allows the required security group rules

### Validation Commands

```bash
# Verify VPC exists
aws ec2 describe-vpcs --vpc-ids vpc-xxxxxxxxx

# Verify subnets exist and are in correct VPC
aws ec2 describe-subnets --subnet-ids subnet-xxxxxxxxx

# Check route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"

# Verify internet gateway
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=vpc-xxxxxxxxx"
```

## Migration from New VPC to Existing VPC

If you want to migrate from new VPC mode to existing VPC mode:

1. **Export existing resources** (if you want to keep them)
2. **Destroy current infrastructure**: `terraform destroy`
3. **Update configuration** to use existing VPC
4. **Apply new configuration**: `terraform apply`

## Best Practices

1. **Use dedicated subnets** for ParallelCluster to avoid conflicts
2. **Document your VPC setup** for team members
3. **Test connectivity** before deploying large clusters
4. **Monitor costs** as existing VPC resources may have different pricing
5. **Backup configurations** before making changes

## Support

For issues with existing VPC configuration:
1. Check AWS VPC documentation
2. Verify network connectivity and routing
3. Review security group rules
4. Test with minimal configuration first