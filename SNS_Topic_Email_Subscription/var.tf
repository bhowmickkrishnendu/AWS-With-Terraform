# Define the variable for the AWS region (Mumbai)
variable "region" {
  description = "This is the Mumbai region"
  default     = "ap-south-1"
}

# Define the variable for the SNS Topic name
variable "topicname" {
  default = "Demo-Topic_Name"
}
