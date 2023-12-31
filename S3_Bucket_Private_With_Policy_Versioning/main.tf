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
