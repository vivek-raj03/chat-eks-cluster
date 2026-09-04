##############################################
# Security Group - EKS Control Plane <-> Nodes
##############################################

resource "aws_security_group" "cluster" {
  name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-eks-cluster-sg"
  })
}

##############################################
# EKS Cluster (control plane)
##############################################

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = values(var.private_app_subnet_ids)
    security_group_ids       = [aws_security_group.cluster.id]
    endpoint_public_access    = var.cluster_endpoint_public_access
    endpoint_private_access   = var.cluster_endpoint_private_access
    public_access_cidrs       = var.cluster_endpoint_public_access_cidrs
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
  ]
}