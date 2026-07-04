terraform {
  backend "s3" {
    bucket       = "krish-terraform-state-ap-south-1"
    key          = "dev/ecr/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
