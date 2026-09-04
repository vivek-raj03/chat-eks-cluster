##############################################
# Cluster
##############################################

output "cluster_id" {
  description = "Name/ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster, used for kubeconfig"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = aws_eks_cluster.this.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data, required for kubeconfig"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "ID of the security group attached to the EKS control plane"
  value       = aws_security_group.cluster.id
}

##############################################
# OIDC / IRSA
##############################################

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider, required when building IRSA role trust policies for workloads"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the cluster's OIDC issuer (without https:// prefix), used in IRSA trust policy conditions"
  value       = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

##############################################
# IAM Roles
##############################################

output "cluster_iam_role_arn" {
  description = "ARN of the EKS cluster (control plane) IAM role"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "ARN of the EKS worker node IAM role"
  value       = aws_iam_role.node.arn
}

output "node_iam_role_name" {
  description = "Name of the EKS worker node IAM role"
  value       = aws_iam_role.node.name
}

##############################################
# Node Group
##############################################

output "node_group_id" {
  description = "ID of the primary EKS managed node group"
  value       = aws_eks_node_group.primary.id
}

output "node_group_status" {
  description = "Status of the primary EKS managed node group"
  value       = aws_eks_node_group.primary.status
}

output "node_group_asg_names" {
  description = "Autoscaling group names backing the primary node group, useful for Cluster Autoscaler/Karpenter configuration"
  value       = aws_eks_node_group.primary.resources[0].autoscaling_groups[*].name
}