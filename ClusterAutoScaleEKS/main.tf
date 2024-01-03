# AWS Provider Configuration
provider "aws" {
  region = var.region
}

# IAM Policy Creation for Auto Scaling
resource "aws_iam_policy" "autoscaling_policy" {
  name   = "autoscaling_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
        ],
        Resource = "*",
        Effect   = "Allow",
      },
    ],
  })
}

# IAM Policy Attachment to Role
resource "aws_iam_role_policy_attachment" "autoscaling_policy_attachment" {
  policy_arn = aws_iam_policy.autoscaling_policy.arn
  role       = "EKS_WorkerNodeRole"
}
