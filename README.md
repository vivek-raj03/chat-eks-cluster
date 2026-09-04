# chat-eks-cluster

Terraform repository for the EKS cluster that runs the chat application's Kubernetes microservices. Consumes networking (VPC, subnets) from the `chat-aws-foundation` repo via remote state. Follows the same module + environment root architecture as that repo.

## Purpose

This repo is scoped to **cluster infrastructure only**: the EKS control plane, worker nodes, core add-ons, IAM/IRSA foundation, and cluster access. It does not include application workloads, Helm charts, or GitOps configuration — those live in separate repos that consume this repo's outputs.


## What this repo creates

### IAM (`iam.tf`)
- EKS cluster IAM role (control plane's own AWS identity)
- EKS worker node IAM role (`AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`)
- IAM OIDC Identity Provider, registering the cluster's OIDC issuer with AWS IAM — the foundation for IRSA (IAM Roles for Service Accounts), used later by workload ServiceAccounts

### Cluster (`cluster.tf`)
- Security group for the EKS control plane
- The EKS cluster itself (`aws_eks_cluster`), deployed into the private app-tier subnets from `chat-aws-foundation`

### Node Group (`node-group.tf`)
- One managed EKS node group, autoscaling within configured min/max, in the private app-tier subnets

### Add-ons (`addons.tf`)
- `vpc-cni` — configured for **custom networking**, so pods pull IP addresses from the secondary pod CIDR (from `chat-aws-foundation`) instead of the primary VPC CIDR, avoiding IP exhaustion at scale
- `coredns` — in-cluster DNS
- `kube-proxy` — Service routing rules on every node

### CNI Custom Networking (`cni-custom-networking.tf`)
- Kubernetes provider, authenticated against this cluster
- One `ENIConfig` custom resource per Availability Zone, mapping each AZ to its corresponding pod subnet — this is what makes the `vpc-cni` custom networking setting actually take effect

### Cluster Access (`access.tf`)
- EKS Access Entry + Access Policy Association granting the IAM identity running `terraform apply` cluster-admin permissions — the modern replacement for the legacy `aws-auth` ConfigMap approach, and what makes `kubectl` actually work after this is applied

## Design decisions

- **Raw AWS resources, not the community `terraform-aws-modules/eks/aws` module** — deliberate choice, consistent with the VPC repo, prioritizing learning the underlying mechanics (OIDC/IRSA trust chain, IAM role separation, add-on management) over speed of setup.
- **EKS API endpoint**: both public and private access enabled, but public access restricted to a specific IP/CIDR (no `0.0.0.0/0` — enforced by a validation rule in the module's `variable.tf`) rather than fully private-only, to keep `kubectl` usable without a bastion/VPN while still closing off open internet access.
- **Custom networking for pod IPs** — pods use the secondary CIDR block from the VPC repo, not the primary VPC CIDR, to avoid the common EKS production failure mode of running out of IPs as pod count grows.
- **Separate IAM roles for cluster vs. nodes** — least-privilege separation; the control plane's permissions and the worker nodes' permissions are never combined into one role.

## Dependency on `chat-aws-foundation`

This repo does not create any networking resources itself. `env/prod/main.tf` reads `vpc_id`, `private_app_subnet_ids`, and `pod_subnet_ids` from `chat-aws-foundation`'s prod state file via a `terraform_remote_state` data source. The VPC repo's `env/prod/backend.tf` bucket/key values must stay consistent for this lookup to keep working.

## What this repo does NOT include (by design)

Application workloads, Helm charts, Kubernetes manifests for the chat app itself, ArgoCD/GitOps configuration, the AWS Load Balancer Controller installation (its IAM role is prepared for via IRSA/OIDC here, but the controller itself is installed later, in the Helm repo), workload-specific IRSA roles, Cluster Autoscaler/Karpenter (IAM prep only, controller installation is a later step).

## Known operational caveat

The `kubernetes_manifest` resources in `cni-custom-networking.tf` require the cluster to already be reachable at plan time. On a completely fresh `apply`, this can require a two-step process — applying the cluster first (e.g. targeted apply on `module.eks.aws_eks_cluster.this`), then a full apply — rather than one atomic run. This is a known characteristic of mixing AWS and Kubernetes-native Terraform resources in a single configuration, not a bug in this repo.

## Outputs

Exposed via `env/prod/output.tf`: cluster ID/name/ARN/endpoint/version, certificate authority data (for kubeconfig), cluster security group ID, OIDC provider ARN and issuer URL (for building IRSA trust policies), cluster and node IAM role ARNs, node group ID/status, and the node group's backing Auto Scaling Group names (for future Cluster Autoscaler/Karpenter configuration).
