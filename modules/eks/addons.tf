##############################################
# EKS Add-ons
##############################################

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "vpc-cni"
  addon_version = var.vpc_cni_version

  resolve_conflicts_on_update = "OVERWRITE"

  # Enables custom networking so pods pull IPs from var.pod_subnet_ids
  # (the secondary CIDR) instead of the primary VPC CIDR, and tells the
  # CNI to key off each node's AZ label when picking an ENIConfig.
  configuration_values = jsonencode({
    env = {
      AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
      ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
    }
  })

  tags = var.tags

  depends_on = [aws_eks_node_group.primary]
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "coredns"
  addon_version = var.coredns_version

  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  depends_on = [aws_eks_node_group.primary]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "kube-proxy"
  addon_version = var.kube_proxy_version

  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  depends_on = [aws_eks_node_group.primary]
}