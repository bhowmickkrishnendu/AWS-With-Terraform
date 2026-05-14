# Provider configuration for AWS
provider "aws" {
  alias  = "main"        # Alias to distinguish multiple provider configurations
  region = var.region    # AWS region specified as a variable
}

# S3 Bucket resource
resource "aws_s3_bucket" "name" {
  bucket = var.bucketname  # Bucket name specified as a variable
  tags = {
    Name = var.bucketname  # Tagging the bucket with its name
  }
}

# S3 Bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "bucketcontrol" {
  bucket = aws_s3_bucket.name.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 Bucket ACL (Access Control List)
resource "aws_s3_bucket_acl" "bucketacl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucketcontrol]

  bucket = aws_s3_bucket.name.id
  acl = "private"
}

# IAM policy document for S3 bucket access
data "aws_iam_policy_document" "policy_details" {
  statement {
    sid = "AllowPublicRead"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.name.arn,
      "${aws_s3_bucket.name.arn}/*",
    ]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["10.0.0.0/16"]
    }
  }
}

# Apply S3 bucket policy based on the IAM policy document
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.name.id
  policy = data.aws_iam_policy_document.policy_details.json
}

# SNS Topic resource
resource "aws_sns_topic" "topicname" {
  name = var.topicname
  display_name = var.topicname
  tags = {
    Name = var.topicname
  }
}

# SNS Topic policy
resource "aws_sns_topic_policy" "snspolicyname" {
  arn    = aws_sns_topic.topicname.arn
  policy = data.aws_iam_policy_document.sns_policy.json
}

# IAM policy document for SNS topic
data "aws_iam_policy_document" "sns_policy" {
  statement {
    sid       = "__default_statement_ID"
    actions   = ["SNS:Publish", "SNS:RemovePermission", "SNS:SetTopicAttributes", "SNS:DeleteTopic", "SNS:ListSubscriptionsByTopic", "SNS:GetTopicAttributes", "SNS:AddPermission", "SNS:Subscribe"]
    resources = [aws_sns_topic.topicname.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid       = "__console_pub_0"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.topicname.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid       = "__console_sub_0"
    actions   = ["SNS:Subscribe"]
    resources = [aws_sns_topic.topicname.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# S3 Bucket notification configuration
resource "aws_s3_bucket_notification" "bucketnotify" {
  bucket = aws_s3_bucket.name.id

  topic {
    topic_arn = aws_sns_topic.topicname.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# SNS Topic subscription (example: email subscription)
resource "aws_sns_topic_subscription" "sns_subscription_1" {
  topic_arn = aws_sns_topic.topicname.arn
  protocol  = "email"
  endpoint  = "9635.krishnendu@gmail.com"
}

# Output the ARN of the created S3 bucket
output "s3_arn" {
  value = aws_s3_bucket.name.arn
}

# Output the ARN of the created SNS topic
output "sns_arn" {
  value = aws_sns_topic.topicname.arn
}
