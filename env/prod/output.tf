output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "node_iam_role_arn" {
  value = module.eks.node_iam_role_arn
}

output "node_iam_role_name" {
  value = module.eks.node_iam_role_name
}

output "node_group_id" {
  value = module.eks.node_group_id
}

output "node_group_status" {
  value = module.eks.node_group_status
}

output "node_group_asg_names" {
  value = module.eks.node_group_asg_names
}