# Head Node Security Group
resource "aws_security_group" "head_node" {
  name_prefix = "${var.cluster_name}-head-node-"
  description = "Security group for ParallelCluster head node"
  vpc_id      = local.vpc_id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # DCV remote desktop (if enabled)
  dynamic "ingress" {
    for_each = var.enable_dcv ? [1] : []
    content {
      description = "DCV"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  }



  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-head-node-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Compute Node Security Group
resource "aws_security_group" "compute_node" {
  name_prefix = "${var.cluster_name}-compute-node-"
  description = "Security group for ParallelCluster compute nodes"
  vpc_id      = local.vpc_id

  # SSH from head node
  ingress {
    description     = "SSH from head node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.head_node.id]
  }

  # All traffic between compute nodes (for MPI, EFA)
  ingress {
    description = "All traffic between compute nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-compute-node-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EFS Security Group
resource "aws_security_group" "efs" {
  count = var.enable_efs ? 1 : 0

  name_prefix = "${var.cluster_name}-efs-"
  description = "Security group for EFS"
  vpc_id      = local.vpc_id

  # NFS from head node
  ingress {
    description     = "NFS from head node"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.head_node.id]
  }

  # NFS from compute nodes
  ingress {
    description     = "NFS from compute nodes"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.compute_node.id]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-efs-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# FSx Lustre Security Group
resource "aws_security_group" "fsx" {
  count = var.enable_fsx_lustre ? 1 : 0

  name_prefix = "${var.cluster_name}-fsx-"
  description = "Security group for FSx Lustre"
  vpc_id      = local.vpc_id

  # Lustre ports from head node
  ingress {
    description     = "Lustre from head node"
    from_port       = 988
    to_port         = 988
    protocol        = "tcp"
    security_groups = [aws_security_group.head_node.id]
  }

  ingress {
    description     = "Lustre from head node"
    from_port       = 1021
    to_port         = 1023
    protocol        = "tcp"
    security_groups = [aws_security_group.head_node.id]
  }

  # Lustre ports from compute nodes
  ingress {
    description     = "Lustre from compute nodes"
    from_port       = 988
    to_port         = 988
    protocol        = "tcp"
    security_groups = [aws_security_group.compute_node.id]
  }

  ingress {
    description     = "Lustre from compute nodes"
    from_port       = 1021
    to_port         = 1023
    protocol        = "tcp"
    security_groups = [aws_security_group.compute_node.id]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-fsx-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Separate security group rules to avoid circular dependency
# NFS access from compute nodes to head node (for shared storage)
resource "aws_security_group_rule" "nfs_from_compute_to_head" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.compute_node.id
  security_group_id        = aws_security_group.head_node.id
  description              = "NFS from compute nodes to head node"
}

# Slurm controller daemon (slurmctld) - CRITICAL for compute node registration
resource "aws_security_group_rule" "slurm_controller_from_compute" {
  type                     = "ingress"
  from_port                = 6817
  to_port                  = 6817
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.compute_node.id
  security_group_id        = aws_security_group.head_node.id
  description              = "Slurm controller daemon from compute nodes"
}

# Slurm database daemon (slurmdbd) - for accounting and job tracking
resource "aws_security_group_rule" "slurm_dbd_from_compute" {
  type                     = "ingress"
  from_port                = 6819
  to_port                  = 6819
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.compute_node.id
  security_group_id        = aws_security_group.head_node.id
  description              = "Slurm database daemon from compute nodes"
}

# Slurm node daemon communication - for job execution and monitoring
resource "aws_security_group_rule" "slurm_node_daemon_from_compute" {
  type                     = "ingress"
  from_port                = 6818
  to_port                  = 6818
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.compute_node.id
  security_group_id        = aws_security_group.head_node.id
  description              = "Slurm node daemon communication from compute nodes"
}

# Additional Slurm communication ports (range for dynamic allocation)
resource "aws_security_group_rule" "slurm_additional_ports_from_compute" {
  type                     = "ingress"
  from_port                = 60001
  to_port                  = 63000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.compute_node.id
  security_group_id        = aws_security_group.head_node.id
  description              = "Slurm additional communication ports from compute nodes"
}

# Reverse rules: Head node to compute nodes communication
# Slurm node daemon (slurmd) on compute nodes
resource "aws_security_group_rule" "slurm_node_daemon_to_compute" {
  type                     = "ingress"
  from_port                = 6818
  to_port                  = 6818
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.head_node.id
  security_group_id        = aws_security_group.compute_node.id
  description              = "Slurm node daemon communication to compute nodes"
}

# Additional Slurm ports for head node to compute communication
resource "aws_security_group_rule" "slurm_additional_ports_to_compute" {
  type                     = "ingress"
  from_port                = 60001
  to_port                  = 63000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.head_node.id
  security_group_id        = aws_security_group.compute_node.id
  description              = "Slurm additional communication ports to compute nodes"
}

# Slurm extended communication ports (6820-6829) from compute to head node
resource "aws_security_group_rule" "slurm_extended_ports_from_compute" {
  type                     = "ingress"
  from_port                = 6820
  to_port                  = 6830
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.compute_node.id
  security_group_id        = aws_security_group.head_node.id
  description              = "Slurm extended communication ports (6820-6829) from compute nodes"
}
