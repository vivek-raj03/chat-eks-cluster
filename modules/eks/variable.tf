##############################################
# General
##############################################

variable "project_name" {
  description = "Name of the project, used as a prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be one of: dev, prod."
  }
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

##############################################
# Networking (consumed from the VPC repo via remote state, passed in as plain values here)
##############################################

variable "vpc_id" {
  description = "ID of the VPC this cluster will be deployed into"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Map of AZ -> private app-tier subnet ID, where the EKS control plane ENIs and node groups live"
  type        = map(string)
}

variable "pod_subnet_ids" {
  description = "Map of AZ -> pod subnet ID (secondary CIDR), used for VPC CNI custom networking configuration"
  type        = map(string)
}

##############################################
# Cluster
##############################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane (e.g. 1.30)"
  type        = string
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
  description = "CIDR blocks allowed to reach the public EKS API endpoint. Must be explicitly set (e.g. your IP as X.X.X.X/32) — no default, to force a conscious choice rather than accidentally leaving this open to the internet."
  type        = list(string)

  validation {
    condition     = !contains(var.cluster_endpoint_public_access_cidrs, "0.0.0.0/0")
    error_message = "cluster_endpoint_public_access_cidrs must not contain 0.0.0.0/0 - restrict to specific IPs/CIDRs for production."
  }
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
}

variable "node_min_size" {
  description = "Minimum number of nodes in the primary node group"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of nodes in the primary node group"
  type        = number
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

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be either ON_DEMAND or SPOT."
  }
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