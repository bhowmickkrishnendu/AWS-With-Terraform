locals {
  public_buckets = {
    for bucket_name, bucket_settings in var.buckets : bucket_name => bucket_settings
    if try(bucket_settings.public, false)
  }
}

module "app_buckets" {
  for_each = var.buckets

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket = each.key

  force_destroy = false

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = try(each.value.public, false) ? false : true
  block_public_policy     = try(each.value.public, false) ? false : true
  ignore_public_acls      = try(each.value.public, false) ? false : true
  restrict_public_buckets = try(each.value.public, false) ? false : true

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  for_each = local.public_buckets

  bucket = module.app_buckets[each.key].s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${module.app_buckets[each.key].s3_bucket_arn}/*"
      }
    ]
  })
}