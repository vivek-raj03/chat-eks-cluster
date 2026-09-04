##############################################
# Kubernetes provider - auths against the cluster we just created
##############################################

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

##############################################
# VPC CNI Custom Networking - one ENIConfig per AZ
##############################################

# Tells the CNI plugin to look at a node's topology.kubernetes.io/zone
# label to decide which ENIConfig (and therefore which pod subnet) to use
resource "kubernetes_manifest" "eniconfig" {
  for_each = var.pod_subnet_ids

  manifest = {
    apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
    kind       = "ENIConfig"
    metadata = {
      name = each.key
    }
    spec = {
      subnet = each.value
      securityGroups = [
        aws_security_group.cluster.id
      ]
    }
  }

  depends_on = [aws_eks_addon.vpc_cni]
}