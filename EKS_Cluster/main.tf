# Define the AWS provider
provider "aws" {
  region = var.region
}

# Create the Amazon VPC using a CloudFormation template
resource "aws_cloudformation_stack" "eks_vpc_stack" {
  name         = "EKS-VPC-Private"
  template_url = "http://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-08-12/amazon-eks-vpc-private-subnets.yaml"
}

# Create the IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name = "EKS_ClusterRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the Amazon EKS cluster policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create the IAM role for node worker group
resource "aws_iam_role" "eks_worker_node_role" {
  name = "EKS_WorkerNodeRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach policies to the IAM role for node worker group
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment_3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node_role.name
}
