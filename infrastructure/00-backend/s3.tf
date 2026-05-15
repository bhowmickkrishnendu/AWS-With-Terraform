resource "aws_s3_bucket" "terraform_state" {
  bucket = "krish-terraform-state-ap-south-1"

  tags = {
    Name        = "terraform-state"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}