terraform {
  backend "s3" {
    bucket       = "krish-terraform-state-ap-south-1"
    key          = "dev/compute/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}