# Define the variable for the AWS region (Mumbai)
variable "region" {
  description = "This is the Mumbai region"  # Description of the variable, indicating it's for the Mumbai region
  default     = "ap-south-1"                 # Default value set to the AWS Mumbai region code
}

# Define variable for S3 bucket name
variable "bucketname" {
  default = "krish-s3-demo"  # Default value set to the desired S3 bucket name
}

# Define variable for SNS topic name
variable "topicname" {
  default = "krish-s3-demo"  # Default value set to the desired SNS topic name
}
