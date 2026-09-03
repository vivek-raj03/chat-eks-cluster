# terraform {
#   backend "s3" {
#     bucket       = "chat-eks-cluster-tfstate-prod"
#     key          = "prod/eks/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }