provider "aws" {
    alias  = "main"
    region = var.region  
}

resource "aws_s3_bucket" "name" {
  bucket = var.bucketname
  tags = {
    Name = var.bucketname
  }
}



resource "aws_s3_bucket_ownership_controls" "bucketcontrol" {
  bucket = aws_s3_bucket.name.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucketacl" {
  depends_on = [ aws_s3_bucket_ownership_controls.bucketcontrol ]

  bucket = aws_s3_bucket.name.id
  acl = "private"
}

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

resource "aws_s3_bucket_policy" "bucket_policy" {
    bucket = aws_s3_bucket.name.id
    policy = data.aws_iam_policy_document.policy_details.json
}

resource "aws_sns_topic" "topicname" {
  name = var.topicname
  display_name = var.topicname
  tags = {
    Name = var.topicname
  }
}

resource "aws_sns_topic_policy" "snspolicyname" {
  arn = aws_sns_topic.topicname.arn
  policy = data.aws_iam_policy_document.sns_policy.json
}

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

resource "aws_s3_bucket_notification" "bucketnotify" {
  bucket = aws_s3_bucket.name.id

  topic {
    topic_arn = aws_sns_topic.topicname.arn
    events = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sns_topic_subscription" "sns_subscription_1" {
  topic_arn = aws_sns_topic.topicname.arn
  protocol = "email"
  endpoint = "9635.krishnendu@gmail.com"
}

output "s3_arn" {
  value = aws_s3_bucket.name.arn
}

output "sns_arn" {
  value = aws_sns_topic.topicname.arn
}
