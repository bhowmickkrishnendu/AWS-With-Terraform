environment = "dev"

aws_region = "ap-south-1"
# aws_profile = "terraform-dev"

vpc_cidr = "10.0.0.0/16"

availability_zones   = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# A NAT gateway in each AZ avoids routing both private subnets through one AZ.
# These resources have a recurring AWS cost and must be reviewed before apply.
nat_gateway_mode            = "none"
enable_s3_gateway_endpoint  = false
interface_endpoint_services = []
