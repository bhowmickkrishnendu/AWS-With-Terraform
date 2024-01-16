# AWS provider configuration
provider "AWS" {
  alias = "main"
  region = var.region
}

resource "aws_sns_topic" "topicname" {
  name = "user-exception"
}