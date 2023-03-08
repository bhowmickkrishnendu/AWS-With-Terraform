# Define the AWS provider
provider "aws" {
  region = var.region
}

# Create the IAM policy
resource "aws_iam_policy" "autoscaling_policy" {
  name        = "autoscaling_policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
    }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "autoscaling_policy_attachment" {
  policy_arn = aws_iam_policy.autoscaling_policy.arn
  role       = "EKS_WorkerNodeRole" 
}
