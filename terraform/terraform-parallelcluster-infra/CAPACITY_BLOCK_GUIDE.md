# 🚀 **Capacity Block Configuration Guide**

## 📋 **Overview**

The ParallelCluster template now supports **AWS EC2 Capacity Blocks** and advanced configuration options. All options are included as **commented configurations** by default, allowing you to easily enable and customize them as needed.

## 🎯 **What Are Capacity Blocks?**

**EC2 Capacity Blocks** allow you to reserve compute capacity for a specific duration (1-7 days) at a discounted rate. This is ideal for:

- **Predictable workloads** with known start/end times
- **Cost optimization** for batch processing jobs
- **Guaranteed capacity** for critical workloads
- **GPU-intensive tasks** where spot instances aren't suitable

## 🔧 **Template Features Added**

### **1. Capacity Block Configuration**

Each compute resource now includes capacity block options:

```yaml
ComputeResources:
  - Name: high-gpu-nodes
    InstanceType: p5.4xlarge
    MinCount: 0
    MaxCount: 4
    # Capacity Block Configuration (uncomment and configure if using capacity blocks)
    # CapacityReservationTarget:
    #   CapacityReservationId: cr-1234567890abcdef0
    # CapacityType: capacity_block
```

### **2. Advanced Compute Options**

```yaml
# Advanced Options for High-Performance GPU Workloads
# SpotPrice: 15.00  # Set spot price for cost optimization
# Efa:  # Enhanced Fabric Adapter for HPC workloads
#   Enabled: true
#   GdrSupport: true  # GPU Direct RDMA support
# DisableSimultaneousMultithreading: false
# SchedulableMemory: 768000  # MB, adjust based on workload needs
```

### **3. Enhanced Slurm Settings**

```yaml
SlurmSettings:
  ScaledownIdletime: 10
  QueueUpdateStrategy: TERMINATE
  # Additional Slurm Settings (uncomment and configure as needed)
  # EnableMemoryBasedScheduling: true
  # Database:
  #   Uri: mysql://username:password@hostname:port/database_name
```

### **4. Additional Advanced Features**

- **Custom Actions** for lifecycle events
- **Login Nodes** for interactive access
- **Directory Service** integration
- **IMDS Configuration** for security
- **Additional IAM Policies**

## 📝 **How to Use Capacity Blocks**

### **Step 1: Purchase Capacity Block**

```bash
# List available capacity blocks
aws ec2 describe-capacity-block-offerings \
  --instance-type p5.4xlarge \
  --instance-count 4 \
  --start-date-range 2024-01-01T00:00:00.000Z \
  --end-date-range 2024-01-07T23:59:59.000Z

# Purchase capacity block
aws ec2 purchase-capacity-block \
  --capacity-block-offering-id cbo-1234567890abcdef0 \
  --instance-platform Linux/UNIX
```

### **Step 2: Configure ParallelCluster**

Edit your `pcluster-config.yaml` and uncomment the capacity block section:

```yaml
ComputeResources:
  - Name: high-gpu-nodes
    InstanceType: p5.4xlarge
    MinCount: 0
    MaxCount: 4
    # Uncomment and configure for capacity blocks
    CapacityReservationTarget:
      CapacityReservationId: cr-1234567890abcdef0  # Your capacity reservation ID
    CapacityType: capacity_block
```

### **Step 3: Deploy Cluster**

```bash
# Create cluster with capacity block
pcluster create-cluster --cluster-name my-hpc-cluster \
  --cluster-configuration pcluster-config.yaml
```

## 🎛️ **Configuration Options by Queue Type**

### **High-Performance GPU Queue (H100)**

```yaml
- Name: high-gpu-nodes
  InstanceType: p5.4xlarge
  # Capacity Block - Recommended for expensive GPU instances
  CapacityReservationTarget:
    CapacityReservationId: cr-1234567890abcdef0
  CapacityType: capacity_block
  # EFA for high-performance networking
  Efa:
    Enabled: true
    GdrSupport: true
  # High spot price as fallback
  SpotPrice: 15.00
```

### **GPU Inference Queue (L4)**

```yaml
- Name: gpu-nodes-g6f-l4
  InstanceType: g6f.2xlarge
  # Spot instances often suitable for inference
  SpotPrice: 2.50
  # Or use capacity blocks for guaranteed capacity
  # CapacityReservationTarget:
  #   CapacityReservationId: cr-abcdef1234567890
  # CapacityType: capacity_block
```

### **High-CPU Queue**

```yaml
- Name: highcpu-nodes
  InstanceType: c7i.16xlarge
  # Disable hyperthreading for CPU-intensive tasks
  DisableSimultaneousMultithreading: true
  # Use spot for cost optimization
  SpotPrice: 3.50
  # Adjust memory for specific workloads
  SchedulableMemory: 120000
```

## 💰 **Cost Optimization Strategies**

### **1. Hybrid Approach**

```yaml
# Mix capacity blocks with spot instances
ComputeResources:
  # Guaranteed capacity for critical jobs
  - Name: guaranteed-gpu-nodes
    InstanceType: p5.4xlarge
    MinCount: 0
    MaxCount: 2
    CapacityReservationTarget:
      CapacityReservationId: cr-1234567890abcdef0
    CapacityType: capacity_block
  
  # Additional capacity with spot instances
  - Name: spot-gpu-nodes
    InstanceType: p5.4xlarge
    MinCount: 0
    MaxCount: 8
    SpotPrice: 12.00
```

### **2. Time-Based Scheduling**

```yaml
# Use capacity blocks during peak hours
# Configure different queues for different time periods
SlurmSettings:
  CustomSlurmSettings:
    - Include: /opt/slurm/etc/time-based-scheduling.conf
```

## 🔍 **Monitoring and Management**

### **Check Capacity Block Status**

```bash
# List your capacity reservations
aws ec2 describe-capacity-reservations

# Monitor capacity block usage
aws ec2 describe-capacity-block-offerings \
  --capacity-reservation-ids cr-1234567890abcdef0
```

### **Slurm Commands for Capacity Management**

```bash
# Check node status
sinfo -o "%N %T %C %m %f %G"

# View capacity block nodes specifically
sinfo -p high-gpu-queue -o "%N %T %C %f"

# Submit job to specific capacity type
sbatch --constraint=capacity_block job.sh
```

## 📊 **Example Configurations**

### **Research Workload (7-day capacity block)**

```yaml
ComputeResources:
  - Name: research-gpu-nodes
    InstanceType: p5.4xlarge
    MinCount: 0
    MaxCount: 8
    CapacityReservationTarget:
      CapacityReservationId: cr-research-block-001
    CapacityType: capacity_block
    Efa:
      Enabled: true
      GdrSupport: true
    SchedulableMemory: 700000  # Reserve memory for large models
```

### **Batch Processing (Mixed capacity)**

```yaml
ComputeResources:
  # Guaranteed capacity for SLA jobs
  - Name: sla-cpu-nodes
    InstanceType: c7i.16xlarge
    MinCount: 2
    MaxCount: 10
    CapacityReservationTarget:
      CapacityReservationId: cr-batch-sla-001
    CapacityType: capacity_block
  
  # Spot capacity for best-effort jobs
  - Name: spot-cpu-nodes
    InstanceType: c7i.16xlarge
    MinCount: 0
    MaxCount: 50
    SpotPrice: 2.00
```

## ⚠️ **Important Considerations**

### **Capacity Block Limitations**

- **Duration**: 1-7 days only
- **Instance Types**: Limited to specific types
- **Regions**: Not available in all regions
- **Advance Purchase**: Must be purchased before use
- **No Interruption**: Cannot be terminated early

### **Best Practices**

1. **Plan Ahead**: Purchase capacity blocks well in advance
2. **Monitor Usage**: Track utilization to optimize costs
3. **Hybrid Strategy**: Combine with spot instances for flexibility
4. **Queue Design**: Separate queues for different capacity types
5. **Job Scheduling**: Use Slurm constraints to target specific capacity

## 🚀 **Getting Started**

1. **Review Template**: Check the commented options in `pcluster-config.yaml`
2. **Purchase Capacity**: Buy capacity blocks for your workload
3. **Configure Cluster**: Uncomment and customize the relevant sections
4. **Deploy**: Create your ParallelCluster with capacity block support
5. **Monitor**: Track usage and optimize configuration

Your ParallelCluster template is now **capacity block ready** with all advanced options available as commented configurations! 🎉