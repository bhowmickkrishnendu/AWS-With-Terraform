# Define the variable for the AWS region
variable "region" {
    description = "This is mumbai region"
    default = "ap-south-1"
}

# Define the variable for the AWS availability zone within the Mumbai region

variable "availability_zone" {
    description = "This is mumbai region a zone"
    default = "ap-south-1a"
}