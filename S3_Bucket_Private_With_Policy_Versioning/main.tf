# AWS provider configuration for the specified region
provider "aws" {
    alias  = "main"
    region = var.region  # Set the AWS region based on the 'region' variable
}

# AWS S3 bucket resource for Tomcat server logs
resource "aws_s3_bucket" "bucket_name" {
    bucket = "krish_tomcat_log"  # Specify the desired S3 bucket name
    tags = {
      Name = "Krishnendu's Tomcat Server Log"  # Add a tag for better identification
    }
}

# S3 Bucket Ownership Controls for BucketOwnerPreferred
resource "aws_s3_bucket_ownership_controls" "bucket_control" {
    bucket  = aws_s3_bucket.bucket_name.id  # Reference the created S3 bucket

    rule {
      object_ownership = "BucketOwnerPreferred"  # Set object ownership to BucketOwnerPreferred
    }
}

# S3 Bucket ACL with Private Access
resource "aws_s3_bucket_acl" "bucket_acl" {
    depends_on = [ aws_s3_bucket_ownership_controls.bucket_control ]

    bucket = aws_s3_bucket.bucket_name.id  # Reference the created S3 bucket
    acl    = "private"  # Set ACL to private for restricted access
}

# IAM policy document for allowing public read access with IP condition
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
        aws_s3_bucket.bucket_name.arn,
        "${aws_s3_bucket.bucket_name.arn}/*",
      ]
      condition {
        test     = "IpAddress"
        variable = "aws:SourceIp"
        values   = ["10.0.0.0/16", "0.0.0.0/0"]
      }
    } 
}

# Apply IAM policy to the S3 bucket for public read access with IP condition
resource "aws_s3_bucket_policy" "bucket_policy" {
    bucket = aws_s3_bucket.bucket_name.id
    policy = data.aws_iam_policy_document.policy_details.json
}
