##############################################
# EKS Managed Node Group
##############################################

resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.environment}-primary"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = values(var.private_app_subnet_ids)

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size
  capacity_type  = var.node_capacity_type

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-primary-node-group"
  })

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]
}