aws_region  = "ap-south-1"
environment = "dev"

repositories = {
  app = {
    description            = "Docker images for main application"
    image_tag_mutability   = "MUTABLE"
    scan_on_push           = true
    encryption_type        = "AES256"
    force_delete           = false
    image_retention_count  = 10
    lifecycle_days_expired = 30
    tags = {
      Service = "application"
    }
  }

  # Uncomment and add more repositories as needed
  # web = {
  #   description            = "Docker images for web frontend"
  #   image_tag_mutability   = "MUTABLE"
  #   scan_on_push           = true
  #   encryption_type        = "AES256"
  #   force_delete           = false
  #   image_retention_count  = 10
  #   lifecycle_days_expired = 30
  #   tags = {
  #     Service = "web"
  #   }
  # }
  #
  # api = {
  #   description            = "Docker images for API service"
  #   image_tag_mutability   = "MUTABLE"
  #   scan_on_push           = true
  #   encryption_type        = "AES256"
  #   force_delete           = false
  #   image_retention_count  = 10
  #   lifecycle_days_expired = 30
  #   tags = {
  #     Service = "api"
  #   }
  # }
}

common_tags = {
  Project = "AWS-Infrastructure"
  Owner   = "DevOps"
}
