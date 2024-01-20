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

