provider "AWS" {
  alias = "main"
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

data "aws_iam_policy_document" "bucketdata" {
  statement {
    sid = "AllowPublicRead"
    principals {
      type = "AWS"
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
      test = "IpAddress"
      variable = "aws:SourceIp"
      values = ["0.0.0.0/0", "10.0.0.0/16"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucketpolicy" {
  bucket = aws_s3_bucket.name.id
  policy = data.aws_iam_policy_document.bucketdata.json
}

resource "aws_sns_topic" "topicname" {
  name = var.topicname
  display_name = var.topicname
  tags = {
    Name = var.topicname
  }
}

data "aws_iam_policy_document" "snspolicydocs" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
        "SNS:Subscribe",
        "SNS:Receive",
        "SNS:Publish",
    ]
    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "*",
      ]
    }
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.topicname.arn,
    ]
  }
}

resource "aws_sns_topic_policy" "snspolicyname" {
  arn = aws_sns_topic.topicname.arn
  policy = data.aws_iam_policy_document.snspolicydocs.json
}
