terraform {

  backend "s3" {
    bucket         = "krishnendu-tf-state-bucket"
    key            = "iam-role-policy/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}