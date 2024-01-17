# AWS provider configuration
provider "AWS" {
  alias = "main"
  region = var.region
}

resource "aws_sns_topic" "topicname" {
  name = var.topicname
  display_name = var.topicname
  tags = {
    Name = var.topicname
  }
}