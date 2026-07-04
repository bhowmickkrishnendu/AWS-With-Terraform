aws_region  = "ap-south-1"
environment = "dev"

cluster_name       = "dev-eks-cluster"
kubernetes_version = "1.30"

endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["0.0.0.0/0"]

enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_days = 7

node_groups = {
  general = {
    desired_size   = 2
    min_size       = 1
    max_size       = 4
    instance_types = ["t3.medium"]
    disk_size      = 20
    capacity_type  = "ON_DEMAND"
    max_unavailable = 1
    tags = {
      NodeGroup = "general"
    }
  }

  # Uncomment to add a spot instance node group for cost optimization
  # spot = {
  #   desired_size   = 1
  #   min_size       = 0
  #   max_size       = 3
  #   instance_types = ["t3.medium", "t3a.medium"]
  #   disk_size      = 20
  #   capacity_type  = "SPOT"
  #   max_unavailable = 1
  #   tags = {
  #     NodeGroup = "spot"
  #   }
  # }
}

# ========================================
# OIDC Provider for IRSA
# ========================================
enable_oidc_provider = true

# ========================================
# EKS Add-ons Configuration
# ========================================
cluster_addons = {
  coredns = {
    addon_version               = "v1.10.1-eksbuild.2"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    preserve                    = false
    tags = {
      AddonType = "required"
    }
  }

  kube-proxy = {
    addon_version               = "v1.30.0-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    preserve                    = false
    tags = {
      AddonType = "required"
    }
  }

  vpc-cni = {
    addon_version               = "v1.18.1-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    preserve                    = false
    tags = {
      AddonType = "networking"
    }
  }

  # Uncomment to enable EBS CSI Driver for persistent volumes
  # aws-ebs-csi-driver = {
  #   addon_version               = "v1.28.0-eksbuild.1"
  #   resolve_conflicts_on_create = "OVERWRITE"
  #   resolve_conflicts_on_update = "OVERWRITE"
  #   preserve                    = false
  #   service_account_role_arn    = null  # Set IAM role ARN if needed
  #   tags = {
  #     AddonType = "storage"
  #   }
  # }

  # Uncomment to enable EFS CSI Driver
  # aws-efs-csi-driver = {
  #   addon_version               = "v1.7.0-eksbuild.1"
  #   resolve_conflicts_on_create = "OVERWRITE"
  #   resolve_conflicts_on_update = "OVERWRITE"
  #   preserve                    = false
  #   service_account_role_arn    = null  # Set IAM role ARN if needed
  #   tags = {
  #     AddonType = "storage"
  #   }
  # }

  # Uncomment to enable AWS Secrets Store CSI Driver for secrets management
  # aws-secrets-store-csi-driver = {
  #   addon_version               = "v1.0.1-eksbuild.1"
  #   resolve_conflicts_on_create = "OVERWRITE"
  #   resolve_conflicts_on_update = "OVERWRITE"
  #   preserve                    = false
  #   service_account_role_arn    = null  # Set IAM role ARN if needed
  #   tags = {
  #     AddonType = "secrets"
  #   }
  # }

  # Uncomment to enable CloudWatch Observability add-on
  # amazon-cloudwatch-observability = {
  #   addon_version               = "v1.7.2-eksbuild.1"
  #   resolve_conflicts_on_create = "OVERWRITE"
  #   resolve_conflicts_on_update = "OVERWRITE"
  #   preserve                    = false
  #   tags = {
  #     AddonType = "monitoring"
  #   }
  # }
}

common_tags = {
  Project = "AWS-Infrastructure"
  Owner   = "DevOps"
}
