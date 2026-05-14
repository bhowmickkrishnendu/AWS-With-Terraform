# Define the variable for the AWS region (Mumbai)
variable "region" {
  description = "This is the AWS region for the S3 bucket in Mumbai"
  default     = "ap-south-1"
}

# Define the variable for the first folder
variable "first_folder" {
  description = "This is the first folder in the S3 bucket"
  default     = "folder_sun/"
}

# Define the variable for the second folder
variable "second_folder" {
  description = "This is the second folder in the S3 bucket"
  default     = "folder_moon/"
}

# Define the variable for the sub-folder of the second folder
variable "sub_folder_of_second" {
  description = "This is the sub-folder of the second folder in the S3 bucket"
  default     = "folder_moon/folder_galaxy/"
}
