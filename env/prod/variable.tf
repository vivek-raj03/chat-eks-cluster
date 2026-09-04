##############################################
# General
##############################################

variable "project_name" {
  description = "Name of the project, used as a prefix for resource naming"
  type        = string
  default     = "chat-aws-foundation"
}

variable "environment" {
  description = "Environment name for this root module"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region to deploy the prod EKS cluster into"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all resources in prod"
  type        = map(string)
  default = {
    Project     = "chat-aws-foundation"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

##############################################
# Remote State - VPC repo
##############################################

variable "vpc_state_bucket" {
  description = "S3 bucket holding the chat-aws-foundation VPC repo's Terraform state"
  type        = string
  default     = "chat-aws-foundation-tfstate-prod"
}

variable "vpc_state_key" {
  description = "State file key/path within the VPC repo's state bucket"
  type        = string
  default     = "prod/vpc/terraform.tfstate"
}

##############################################
# Cluster
##############################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "chat-aws-foundation-prod"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.31"
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS public API endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS private API endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint. Must be set to your real IP(s) as X.X.X.X/32 - no wide-open default provided intentionally."
  type        = list(string)
  # No default - must be supplied explicitly, e.g. via terraform.tfvars
}

##############################################
# Node Group
##############################################

variable "node_instance_types" {
  description = "List of EC2 instance types for the primary node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes in the primary node group"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of nodes in the primary node group"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of nodes in the primary node group"
  type        = number
  default     = 6
}

variable "node_disk_size" {
  description = "EBS root volume size (GiB) for worker nodes"
  type        = number
  default     = 50
}

variable "node_capacity_type" {
  description = "Capacity type for the node group: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

##############################################
# Add-ons
##############################################

variable "vpc_cni_version" {
  description = "Version of the VPC CNI add-on to install"
  type        = string
  default     = null
}

variable "coredns_version" {
  description = "Version of the CoreDNS add-on to install"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy add-on to install"
  type        = string
  default     = null
}