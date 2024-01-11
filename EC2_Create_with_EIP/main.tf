# AWS provider configuration
provider "aws" {
  alias = "main"
  region = var.region
}