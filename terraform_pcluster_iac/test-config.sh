#!/bin/bash

# Test script to validate Terraform configuration
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Terraform Configuration Test ===${NC}\n"

# Test 1: Terraform validation
echo -e "${YELLOW}1. Testing Terraform validation...${NC}"
if terraform validate; then
    echo -e "${GREEN}✓ Terraform validation passed${NC}"
else
    echo -e "${RED}✗ Terraform validation failed${NC}"
    exit 1
fi

# Test 2: Terraform plan
echo -e "\n${YELLOW}2. Testing Terraform plan...${NC}"
if terraform plan -out=test.tfplan > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Terraform plan succeeded${NC}"
    rm -f test.tfplan
else
    echo -e "${RED}✗ Terraform plan failed${NC}"
    exit 1
fi

# Test 3: Check required variables
echo -e "\n${YELLOW}3. Checking required variables in terraform.tfvars...${NC}"
required_vars=("cluster_name" "aws_region" "key_name" "vpc_cidr")
for var in "${required_vars[@]}"; do
    if grep -q "^${var}" terraform.tfvars; then
        echo -e "${GREEN}✓ Found variable: ${var}${NC}"
    else
        echo -e "${RED}✗ Missing variable: ${var}${NC}"
        exit 1
    fi
done

# Test 4: Check file structure
echo -e "\n${YELLOW}4. Checking file structure...${NC}"
required_files=("main.tf" "variables.tf" "outputs.tf" "security_groups.tf" "storage.tf" "versions.tf" "locals.tf")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ Found file: ${file}${NC}"
    else
        echo -e "${RED}✗ Missing file: ${file}${NC}"
        exit 1
    fi
done

# Test 5: Check ParallelCluster template
echo -e "\n${YELLOW}5. Checking ParallelCluster template...${NC}"
if [ -f "pcluster-config-template.yaml" ]; then
    echo -e "${GREEN}✓ Found ParallelCluster template${NC}"
else
    echo -e "${RED}✗ Missing ParallelCluster template${NC}"
    exit 1
fi

# Test 6: Check generate script
echo -e "\n${YELLOW}6. Checking generate script...${NC}"
if [ -f "generate-pcluster-config.sh" ] && [ -x "generate-pcluster-config.sh" ]; then
    echo -e "${GREEN}✓ Generate script is present and executable${NC}"
else
    echo -e "${RED}✗ Generate script missing or not executable${NC}"
    exit 1
fi

echo -e "\n${GREEN}=== All tests passed! Configuration is ready. ===${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update terraform.tfvars with your actual values (key_name, allowed_ssh_cidr)"
echo "2. Run: terraform apply"
echo "3. Run: ./generate-pcluster-config.sh"
echo "4. Create cluster: pcluster create-cluster --cluster-name sansheng-hpc-cluster --cluster-configuration pcluster-config.yaml"