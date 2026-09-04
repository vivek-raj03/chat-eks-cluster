##############################################
# Provider
##############################################

provider "aws" {
  region = var.aws_region
}

##############################################
# Remote State - reads outputs from chat-aws-foundation (VPC repo)
##############################################

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_state_bucket
    key    = var.vpc_state_key
    region = var.aws_region
  }
}

##############################################
# EKS Module Call
##############################################

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  tags         = var.tags

  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  private_app_subnet_ids = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids
  pod_subnet_ids          = data.terraform_remote_state.vpc.outputs.pod_subnet_ids

  cluster_name                         = var.cluster_name
  cluster_version                       = var.cluster_version
  cluster_endpoint_public_access         = var.cluster_endpoint_public_access
  cluster_endpoint_private_access         = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs     = var.cluster_endpoint_public_access_cidrs

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_disk_size      = var.node_disk_size
  node_capacity_type  = var.node_capacity_type

  vpc_cni_version    = var.vpc_cni_version
  coredns_version    = var.coredns_version
  kube_proxy_version = var.kube_proxy_version
}