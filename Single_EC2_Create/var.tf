# Define the variable for the AWS region (Mumbai)
variable "region" {
  description = "This is the Mumbai region"
  default     = "ap-south-1"
}

# Define the variable for an AWS availability zone in Mumbai region (Zone 'a')
variable "availability_zone" {
  description = "This is an Availability Zone in the Mumbai region (Zone 'a')"
  default     = "ap-south-1a"
}
