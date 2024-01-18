# AWS provider configuration
provider "AWS" {
  alias  = "main"
  region = var.region
}

# AWS SNS Topic
resource "aws_sns_topic" "topicname" {
  name        = var.topicname
  display_name = var.topicname
  tags = {
    Name = var.topicname
  }
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "sns_subscription_1" {
  topic_arn = aws_sns_topic.topicname.arn
  protocol  = "email"
  endpoint  = "9635.krishnendu@gmail.com"
}

resource "aws_sns_topic_subscription" "sns_subscription_2" {
  topic_arn = aws_sns_topic.topicname.arn
  protocol  = "email"
  endpoint  = "1234.krishnendu@gmail.com"
}

# Output the ARN of the SNS Topic
output "topic_arn" {
  value = aws_sns_topic.topicname.arn
}
