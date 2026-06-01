output "bucket_name" {
  value = module.app_bucket.s3_bucket_id
}

output "bucket_arn" {
  value = module.app_bucket.s3_bucket_arn
}