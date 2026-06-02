aws_region = "ap-south-1"

environment = "dev"

buckets = {
  "krish-dev-app-data" = {}
  "krish-dev-public-assets" = {
    public = true
  }
}