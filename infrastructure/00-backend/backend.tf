terraform {
  backend "s3" {
    bucket       = "krish-terraform-state-ap-south-1"
    key          = "bootstrap/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
