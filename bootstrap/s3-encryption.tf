# The deployed state bucket uses AES256. KMS migration needs a separate state and
# access review before changing the active backend.
#tfsec:ignore:aws-s3-encryption-customer-key:exp:2027-03-31
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
