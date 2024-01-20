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