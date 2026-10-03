# Supply bucket, key, Region, locking, and encryption at init time.
# No AWS account or state bucket is fixed in this reusable root.
terraform {
  backend "s3" {}
}
