data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "krish-terraform-state-ap-south-1"
    key    = "dev/networking/terraform.tfstate"
    region = "ap-south-1"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-eks-cluster-role"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description = "Allow worker nodes to communicate with cluster API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-eks-cluster-sg"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(data.terraform_remote_state.networking.outputs.private_subnet_ids, data.terraform_remote_state.networking.outputs.public_subnet_ids)
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller
  ]

  tags = merge(
    var.common_tags,
    {
      Name        = var.cluster_name
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )
}

# CloudWatch Log Group for EKS Cluster Logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-eks-logs"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )
}

# IAM Role for EKS Node Groups
resource "aws_iam_role" "eks_node_role" {
  name = "${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-eks-node-role"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Security Group for EKS Node Groups
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.environment}-eks-node-sg"
  description = "Security group for EKS node groups"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow pod to pod communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  ingress {
    description     = "Allow worker kubelet API"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-eks-node-sg"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )
}

# EKS Node Groups
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-${each.key}-ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.terraform_remote_state.networking.outputs.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size
  capacity_type  = each.value.capacity_type

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name        = "${var.environment}-${each.key}-ng"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy
  ]
}

# ========================================
# OIDC Provider for IRSA (IAM Roles for Service Accounts)
# ========================================

data "tls_certificate" "eks_oidc" {
  count = var.enable_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  count = var.enable_oidc_provider ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-eks-oidc"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )
}

# ========================================
# EKS Add-ons
# ========================================

resource "aws_eks_addon" "addons" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value.addon_version
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  preserve                    = each.value.preserve
  service_account_role_arn    = each.value.service_account_role_arn

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name        = "${var.environment}-${each.key}-addon"
      Environment = var.environment
      Module      = "eks"
      ManagedBy   = "terraform"
    }
  )

  depends_on = [aws_eks_cluster.main]
}
