# EFS File System
resource "aws_efs_file_system" "shared" {
  count = var.enable_efs ? 1 : 0

  creation_token   = "${var.cluster_name}-efs"
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = true

  provisioned_throughput_in_mibps = var.efs_throughput_mode == "provisioned" ? var.efs_provisioned_throughput : null

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-efs"
  })
}

# EFS Mount Targets (in all private subnets for redundancy)
resource "aws_efs_mount_target" "shared" {
  count = var.enable_efs ? length(local.private_subnet_ids) : 0

  file_system_id  = aws_efs_file_system.shared[0].id
  subnet_id       = local.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs[0].id]
}

# EFS Access Point
resource "aws_efs_access_point" "shared" {
  count = var.enable_efs ? 1 : 0

  file_system_id = aws_efs_file_system.shared[0].id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = var.efs_mount_dir
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-efs-access-point"
  })
}

# EFS Backup Policy
resource "aws_efs_backup_policy" "shared" {
  count = var.enable_efs ? 1 : 0

  file_system_id = aws_efs_file_system.shared[0].id

  backup_policy {
    status = "ENABLED"
  }
}

# FSx Lustre File System
resource "aws_fsx_lustre_file_system" "shared" {
  count = var.enable_fsx_lustre ? 1 : 0

  storage_capacity            = var.fsx_storage_capacity
  subnet_ids                  = [local.compute_subnet_id]
  deployment_type             = var.fsx_deployment_type
  per_unit_storage_throughput = var.fsx_per_unit_storage_throughput
  security_group_ids          = [aws_security_group.fsx[0].id]

  # Optional S3 integration
  import_path = var.fsx_s3_import_path
  export_path = var.fsx_s3_export_path

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-fsx-lustre"
  })
}