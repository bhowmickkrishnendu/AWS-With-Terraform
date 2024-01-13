# Define AWS Region Provider
provider "aws" {
  alias  = "main"
  region = var.region  # Set the AWS region based on the 'region' variable
}

# Define AWS S3 Bucket
resource "aws_s3_bucket" "bucket_name" {
    bucket = "krish-monitoring-log"  # Specify the desired S3 bucket name
    tags = {
      Name      = "Monitoring Application Logs"  # Add a tag for better identification
    }
}

# Define S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "ownership_access" {
    bucket  =   aws_s3_bucket.bucket_name.id  # Reference the created S3 bucket

    rule {
      object_ownership = "BucketOwnerPreferred"  # Set object ownership to BucketOwnerPreferred
    }
}

# Define S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.bucket_name.id  # Reference the created S3 bucket
    block_public_acls        = false  # Allow public ACLs
    block_public_policy      = false  # Allow public policies
    ignore_public_acls       = false  # Do not ignore public ACLs
    restrict_public_buckets  = false  # Do not restrict public buckets
}

# Define S3 Bucket ACL with Public Read Access
resource "aws_s3_bucket_acl" "bucket_acl" {
    depends_on = [ 
        aws_s3_bucket_ownership_controls.ownership_access,
        aws_s3_bucket_public_access_block.public_access,
    ]
    bucket = aws_s3_bucket.bucket_name.id  # Reference the created S3 bucket
    acl = "public-read"  # Set ACL to public-read for public access
}

# Define S3 Bucket Policy
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]  # You can replace "*" with specific AWS account IDs if needed
    }

    # Define allowed actions on the S3 bucket
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    # Specify the resources (S3 bucket and its objects) the policy applies to
    resources = [
      aws_s3_bucket.bucket_name.arn,
      "${aws_s3_bucket.bucket_name.arn}/*",
    ]
  }
}

# Associate IAM Policy Document with S3 Bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket_name.id  # Reference the created S3 bucket

  # Specify the IAM policy document by referencing the data block
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# Define S3 Objects

# Object representing the first folder "folder_smith/"
resource "aws_s3_object" "first_folder" {
  bucket  = aws_s3_bucket.bucket_name.id
  content = ""                                # Set the content as an empty string for a folder-like structure
  key     = "folder_smith/"  
}

# Object representing the second folder "folder_jhon"
resource "aws_s3_object" "second_folder" {
  bucket  = aws_s3_bucket.bucket_name.id
  content = ""                                # Set the content as an empty string for a folder-like structure
  key     = "folder_jhon/"  
}

# Object representing the sub-folder "folder_smith/folder_peter/"
resource "aws_s3_object" "sub_folder" {
  bucket  = aws_s3_bucket.bucket_name.id
  content = ""                                # Set the content as an empty string for a folder-like structure
  key     = "folder_smith/folder_peter/"  
}

# Define Terraform Output to expose S3 Bucket ARN
output "bucket_arn" {
    value = aws_s3_bucket.bucket_name.arn  # Expose the ARN of the created S3 bucket
}