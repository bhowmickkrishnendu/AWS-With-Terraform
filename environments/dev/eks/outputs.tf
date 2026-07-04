output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "The platform version for the cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster_sg.id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.eks_node_sg.id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS nodes"
  value       = aws_iam_role.eks_node_role.arn
}

output "node_groups" {
  description = "EKS node groups"
  value = {
    for key, ng in aws_eks_node_group.main :
    key => {
      id             = ng.id
      arn            = ng.arn
      status         = ng.status
      capacity_type  = ng.capacity_type
      instance_types = ng.instance_types
      scaling_config = ng.scaling_config
    }
  }
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Identity Provider for IRSA"
  value       = try(aws_iam_openid_connect_provider.eks_oidc[0].arn, null)
}

output "oidc_provider_url" {
  description = "URL of the OIDC Identity Provider for IRSA"
  value       = try(aws_eks_cluster.main.identity[0].oidc[0].issuer, null)
}

output "oidc_provider_thumbprint" {
  description = "Thumbprint of the OIDC Identity Provider certificate"
  value       = try(data.tls_certificate.eks_oidc[0].certificates[0].sha1_fingerprint, null)
}

output "cluster_addons" {
  description = "Details of installed EKS add-ons"
  value = {
    for addon_name, addon in aws_eks_addon.addons :
    addon_name => {
      addon_version = addon.addon_version
      status        = addon.status
      arn           = addon.arn
      created_at    = addon.created_at
      modified_at   = addon.modified_at
    }
  }
}
