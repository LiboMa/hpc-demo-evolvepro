# 🔧 **Slurm Connectivity Issue - FIXED**

## ❌ **Problem Identified**

**Error**: `Unable to register: Unable to contact slurm controller (connect failure)`

**Root Cause**: Missing Slurm communication ports in security groups. Compute nodes couldn't communicate with the head node's Slurm controller daemon.

## ✅ **Solution Applied**

### **Added Essential Slurm Ports to Security Groups**

#### **Head Node Security Group** (Ingress from Compute Nodes)
- ✅ **Port 6817**: Slurm controller daemon (slurmctld) - **CRITICAL**
- ✅ **Port 6818**: Slurm node daemon communication
- ✅ **Port 6819**: Slurm database daemon (slurmdbd)
- ✅ **Ports 6820-6829**: Slurm extended communication ports - **NEWLY ADDED**
- ✅ **Ports 60001-63000**: Additional Slurm communication ports

#### **Compute Node Security Group** (Ingress from Head Node)
- ✅ **Port 6818**: Slurm node daemon (slurmd) on compute nodes
- ✅ **Ports 60001-63000**: Additional Slurm communication ports

### **Security Group Rules Added**

```hcl
# Critical: Slurm controller communication
resource "aws_security_group_rule" "slurm_controller_from_compute" {
  from_port                = 6817
  to_port                  = 6817
  protocol                 = "tcp"
  source_security_group_id = compute_node_sg
  security_group_id        = head_node_sg
  description              = "Slurm controller daemon from compute nodes"
}

# Node daemon communication (bidirectional)
resource "aws_security_group_rule" "slurm_node_daemon_from_compute" {
  from_port                = 6818
  to_port                  = 6818
  protocol                 = "tcp"
  source_security_group_id = compute_node_sg
  security_group_id        = head_node_sg
}

resource "aws_security_group_rule" "slurm_node_daemon_to_compute" {
  from_port                = 6818
  to_port                  = 6818
  protocol                 = "tcp"
  source_security_group_id = head_node_sg
  security_group_id        = compute_node_sg
}

# Database daemon communication
resource "aws_security_group_rule" "slurm_dbd_from_compute" {
  from_port                = 6819
  to_port                  = 6819
  protocol                 = "tcp"
  source_security_group_id = compute_node_sg
  security_group_id        = head_node_sg
}

# Extended Slurm communication ports (6820-6829) - NEWLY ADDED
resource "aws_security_group_rule" "slurm_extended_ports_from_compute" {
  from_port                = 6820
  to_port                  = 6829
  protocol                 = "tcp"
  source_security_group_id = compute_node_sg
  security_group_id        = head_node_sg
  description              = "Slurm extended communication ports (6820-6829) from compute nodes"
}

# Additional communication ports (bidirectional)
resource "aws_security_group_rule" "slurm_additional_ports_from_compute" {
  from_port                = 60001
  to_port                  = 63000
  protocol                 = "tcp"
  source_security_group_id = compute_node_sg
  security_group_id        = head_node_sg
}

resource "aws_security_group_rule" "slurm_additional_ports_to_compute" {
  from_port                = 60001
  to_port                  = 63000
  protocol                 = "tcp"
  source_security_group_id = head_node_sg
  security_group_id        = compute_node_sg
}
```

## 🎯 **What These Ports Do**

| Port | Service | Direction | Purpose |
|------|---------|-----------|---------|
| **6817** | slurmctld | Compute → Head | **Controller daemon - node registration** |
| **6818** | slurmd | Bidirectional | Node daemon communication |
| **6819** | slurmdbd | Compute → Head | Database daemon - job accounting |
| **6820-6829** | Slurm Extended | Compute → Head | **Extended Slurm communication ports** |
| **60001-63000** | Dynamic | Bidirectional | Additional Slurm communication |

## 🔍 **Verification Steps**

### **1. Check Security Group Rules**
```bash
# Head node security group
aws ec2 describe-security-groups --group-ids sg-01aed161b17f621f7 \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`6817`]'

# Compute node security group  
aws ec2 describe-security-groups --group-ids sg-09d2d1e4f8c03653f \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`6818`]'
```

### **2. Test Connectivity (from compute node)**
```bash
# Test Slurm controller port
telnet <head-node-ip> 6817

# Test node daemon port
telnet <head-node-ip> 6818

# Check Slurm status
sinfo
squeue
```

### **3. Monitor Slurm Logs**
```bash
# On head node
sudo tail -f /var/log/slurm/slurmctld.log

# On compute node
sudo tail -f /var/log/slurm/slurmd.log
```

## 🚀 **Next Steps**

### **1. Recreate ParallelCluster (Recommended)**
If you have an existing cluster with the connectivity issue:

```bash
# Delete existing cluster
pcluster delete-cluster --cluster-name sansheng-hpc-cluster

# Wait for deletion to complete
pcluster describe-cluster --cluster-name sansheng-hpc-cluster

# Create new cluster with fixed security groups
pcluster create-cluster --cluster-name sansheng-hpc-cluster \
  --cluster-configuration pcluster-config.yaml
```

### **2. Or Update Existing Cluster Security Groups**
If you want to keep the existing cluster:

```bash
# Get cluster security groups
pcluster describe-cluster --cluster-name sansheng-hpc-cluster

# Manually add the missing rules to existing security groups
aws ec2 authorize-security-group-ingress \
  --group-id <head-node-sg-id> \
  --protocol tcp \
  --port 6817 \
  --source-group <compute-node-sg-id>

# Restart Slurm services
sudo systemctl restart slurmctld  # On head node
sudo systemctl restart slurmd     # On compute nodes
```

## 🔧 **Troubleshooting Commands**

### **Network Connectivity**
```bash
# From compute node to head node
nc -zv <head-node-ip> 6817
nc -zv <head-node-ip> 6818
nc -zv <head-node-ip> 6819

# Check if ports are listening on head node
sudo netstat -tlnp | grep -E ':(6817|6818|6819)'
```

### **Slurm Service Status**
```bash
# Head node
sudo systemctl status slurmctld
sudo systemctl status slurmdbd

# Compute node
sudo systemctl status slurmd
```

### **Slurm Configuration**
```bash
# Check Slurm configuration
sudo scontrol show config | grep -i port
sudo scontrol show nodes
```

## 📋 **Prevention for Future Deployments**

This fix is now **permanently included** in the Terraform configuration. Future deployments will automatically have the correct Slurm ports configured.

### **Security Group Summary**
- ✅ **SSH (22)**: Admin access
- ✅ **DCV (8443)**: Remote desktop
- ✅ **NFS (2049)**: Shared storage
- ✅ **Slurm (6817-6819)**: Controller communication
- ✅ **Slurm Dynamic (60001-63000)**: Additional communication

## 🎯 **Expected Results After Fix**

1. **Compute nodes register successfully** with head node
2. **`sinfo` command shows nodes** in idle/allocated state
3. **Jobs can be submitted** and executed on compute nodes
4. **No "connect failure" errors** in Slurm logs
5. **Auto-scaling works properly** for compute queues

## ⚠️ **Important Notes**

- **Port 6817 is CRITICAL** - without it, compute nodes cannot register
- **Bidirectional communication** is required for proper Slurm operation
- **Security groups must allow** both ingress and egress on these ports
- **Restart Slurm services** after security group changes on existing clusters

Your ParallelCluster should now work correctly with proper Slurm communication! 🎉