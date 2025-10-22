#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== AWS ParallelCluster Configuration Generator ===${NC}\n"

# Check if we're in the terraform directory
if [ ! -f "terraform.tfstate" ] && [ ! -f "terraform-parallelcluster-infra/terraform.tfstate" ]; then
    echo -e "${RED}Error: terraform.tfstate not found. Please run 'terraform apply' first.${NC}"
    echo "Make sure you're in the project root or terraform-parallelcluster-infra directory."
    exit 1
fi

# Change to terraform directory if needed
if [ -f "terraform-parallelcluster-infra/terraform.tfstate" ]; then
    cd terraform-parallelcluster-infra
fi

# Get Terraform outputs
echo -e "${YELLOW}Extracting Terraform outputs...${NC}"
AWS_REGION=$(terraform output -raw aws_region)
CLUSTER_NAME=$(terraform output -raw cluster_name)
VPC_ID=$(terraform output -raw vpc_id)
HEAD_NODE_SUBNET_ID=$(terraform output -json public_subnet_ids | jq -r '.[0]')
COMPUTE_SUBNET_ID=$(terraform output -raw compute_subnet_id)
HEAD_NODE_SG_ID=$(terraform output -raw head_node_security_group_id)
COMPUTE_NODE_SG_ID=$(terraform output -raw compute_node_security_group_id)
KEY_NAME=$(terraform output -raw key_name)

# Get optional outputs
EFS_ID=$(terraform output -raw efs_file_system_id 2>/dev/null || echo "")
FSX_ID=$(terraform output -raw fsx_file_system_id 2>/dev/null || echo "")

# Get configuration from terraform
OS_IMAGE=$(terraform output -raw os_image)
HEAD_NODE_INSTANCE_TYPE=$(terraform output -raw head_node_instance_type)
ENABLE_DCV=$(terraform output -raw enable_dcv)
ROOT_VOLUME_SIZE=$(terraform output -raw root_volume_size)
EFS_MOUNT_DIR=$(terraform output -raw efs_mount_dir)
FSX_MOUNT_DIR=$(terraform output -raw fsx_mount_dir)

# Get compute queues configuration
COMPUTE_QUEUES_JSON=$(terraform output -json compute_queues)

echo -e "${GREEN}Configuration:${NC}"
echo "  Region: $AWS_REGION"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  VPC ID: $VPC_ID"
echo "  Head Node Subnet: $HEAD_NODE_SUBNET_ID"
echo "  Compute Subnet: $COMPUTE_SUBNET_ID"
echo "  Head Node SG: $HEAD_NODE_SG_ID"
echo "  Compute Node SG: $COMPUTE_NODE_SG_ID"
echo "  Key Name: $KEY_NAME"
echo "  OS Image: $OS_IMAGE"
echo "  Head Node Type: $HEAD_NODE_INSTANCE_TYPE"
echo "  DCV Enabled: $ENABLE_DCV"
echo "  Root Volume Size: ${ROOT_VOLUME_SIZE}GB"

# Build shared storage configuration
SHARED_STORAGE_CONFIG=""

if [ -n "$EFS_ID" ] && [ "$EFS_ID" != "null" ]; then
    echo "  EFS ID: $EFS_ID"
    echo "  EFS Mount Dir: $EFS_MOUNT_DIR"
    SHARED_STORAGE_CONFIG="
  - MountDir: $EFS_MOUNT_DIR
    Name: efs-shared
    StorageType: Efs
    EfsSettings:
      FileSystemId: $EFS_ID"
fi

if [ -n "$FSX_ID" ] && [ "$FSX_ID" != "null" ]; then
    echo "  FSx ID: $FSX_ID"
    echo "  FSx Mount Dir: $FSX_MOUNT_DIR"
    if [ -n "$SHARED_STORAGE_CONFIG" ]; then
        SHARED_STORAGE_CONFIG="${SHARED_STORAGE_CONFIG}
  - MountDir: $FSX_MOUNT_DIR
    Name: fsx-lustre-shared
    StorageType: FsxLustre
    FsxLustreSettings:
      FileSystemId: $FSX_ID"
    else
        SHARED_STORAGE_CONFIG="
  - MountDir: $FSX_MOUNT_DIR
    Name: fsx-lustre-shared
    StorageType: FsxLustre
    FsxLustreSettings:
      FileSystemId: $FSX_ID"
    fi
fi

if [ -z "$SHARED_STORAGE_CONFIG" ]; then
    SHARED_STORAGE_CONFIG=" []"
fi

# Build Slurm queues configuration
SLURM_QUEUES_CONFIG=""
echo "  Compute Queues:"

# Parse compute queues JSON and build configuration
echo "$COMPUTE_QUEUES_JSON" | jq -r 'to_entries[] | @base64' | while IFS= read -r queue_data; do
    queue_info=$(echo "$queue_data" | base64 --decode)
    queue_name=$(echo "$queue_info" | jq -r '.key')
    queue_config=$(echo "$queue_info" | jq -r '.value')
    
    instance_types=$(echo "$queue_config" | jq -r '.instance_types[]' | tr '\n' ',' | sed 's/,$//')
    min_count=$(echo "$queue_config" | jq -r '.min_count')
    max_count=$(echo "$queue_config" | jq -r '.max_count')
    root_volume_size=$(echo "$queue_config" | jq -r '.root_volume_size // 120')
    capacity_reservation_id=$(echo "$queue_config" | jq -r '.capacity_reservation_id // empty')
    
    echo "    - $queue_name: $instance_types ($min_count-$max_count nodes)"
    
    # Build queue configuration for YAML
    queue_yaml="
    - Name: $queue_name
      Networking:
        SubnetIds:
          - $COMPUTE_SUBNET_ID
        SecurityGroups:
          - $COMPUTE_NODE_SG_ID
        PlacementGroup:
          Enabled: true
      ComputeSettings:
        LocalStorage:
          RootVolume:
            Size: $root_volume_size
            VolumeType: gp3
      ComputeResources:"
    
    # Add compute resources for each instance type
    IFS=',' read -ra INSTANCE_TYPES <<< "$instance_types"
    for instance_type in "${INSTANCE_TYPES[@]}"; do
        resource_name=$(echo "$instance_type" | sed 's/\./-/g')
        queue_yaml="$queue_yaml
        - Name: ${queue_name}-${resource_name}
          InstanceType: $instance_type
          MinCount: $min_count
          MaxCount: $max_count"
        
        # Add capacity reservation if specified
        if [ -n "$capacity_reservation_id" ] && [ "$capacity_reservation_id" != "null" ]; then
            queue_yaml="$queue_yaml
          CapacityReservationTarget:
            CapacityReservationId: $capacity_reservation_id"
        fi
    done
    
    SLURM_QUEUES_CONFIG="$SLURM_QUEUES_CONFIG$queue_yaml"
done

# Generate the configuration file
echo -e "\n${YELLOW}Generating pcluster-config.yaml...${NC}"

# Export variables for template substitution
export AWS_REGION CLUSTER_NAME HEAD_NODE_SUBNET_ID COMPUTE_SUBNET_ID
export HEAD_NODE_SG_ID COMPUTE_NODE_SG_ID KEY_NAME
export OS_IMAGE HEAD_NODE_INSTANCE_TYPE ENABLE_DCV ROOT_VOLUME_SIZE
export SHARED_STORAGE_CONFIG SLURM_QUEUES_CONFIG

# Generate configuration from template
envsubst < pcluster-config-template.yaml > pcluster-config.yaml

echo -e "${GREEN}✓ Configuration file generated: pcluster-config.yaml${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the configuration: cat pcluster-config.yaml"
echo "2. Validate the configuration: pcluster validate-config -c pcluster-config.yaml"
echo "3. Create the cluster: pcluster create-cluster --cluster-name $CLUSTER_NAME --cluster-configuration pcluster-config.yaml"
echo ""
echo -e "${YELLOW}Optional: Add capacity reservations${NC}"
echo "Edit pcluster-config.yaml and add CapacityReservationTarget under ComputeResources if you have reservations."
