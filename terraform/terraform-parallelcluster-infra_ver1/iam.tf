# IAM Roles for ParallelCluster
# Note: ParallelCluster automatically creates the necessary IAM roles
# This file is a placeholder for any additional IAM configurations

# Data source to get the current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get the current AWS region
data "aws_region" "current" {}

# Output the account ID for reference
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

# Additional IAM policies can be added here if needed
# Example:
# resource "aws_iam_policy" "custom_policy" {
#   name        = "${var.cluster_name}-custom-policy"
#   description = "Custom policy for ParallelCluster"
#   
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject"
#         ]
#         Resource = "arn:aws:s3:::your-bucket/*"
#       }
#     ]
#   })
#   
#   tags = local.common_tags
# }