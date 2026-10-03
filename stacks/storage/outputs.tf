output "bucket_names" {
  value = { for bucket_name, bucket in module.app_buckets : bucket_name => bucket.s3_bucket_id }
}

output "bucket_arns" {
  value = { for bucket_name, bucket in module.app_buckets : bucket_name => bucket.s3_bucket_arn }
}

output "public_buckets" {
  value = [for bucket_name, bucket_settings in var.buckets : bucket_name if try(bucket_settings.public, false)]
}