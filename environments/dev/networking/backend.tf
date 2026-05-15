terraform {
  backend "s3" {
    bucket       = "krish-terraform-state-ap-south-1"
    key          = "dev/networking/terraform.tfstate"
    region       = "ap-south-1"
    # profile      = "terraform-dev"
    encrypt      = true
    use_lockfile = true
  }
}