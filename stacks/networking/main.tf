module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${var.environment}-vpc"

  cidr = var.vpc_cidr

  azs = var.availability_zones

  public_subnets = var.public_subnet_cidrs

  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway     = var.nat_gateway_mode != "none"
  single_nat_gateway     = var.nat_gateway_mode == "single"
  one_nat_gateway_per_az = var.nat_gateway_mode == "per_az"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Gateway endpoints use the private route tables without adding interface endpoint
# hourly charges. Workloads still need IAM permission to access S3.
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name        = "${var.environment}-s3-gateway-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Interface endpoints are optional because each selected service creates an
# endpoint network interface in every private subnet and has ongoing cost.
resource "aws_security_group" "interface_endpoints" {
  count = length(var.interface_endpoint_services) > 0 ? 1 : 0

  name        = "${var.environment}-interface-endpoints-sg"
  description = "HTTPS from private subnets to interface endpoints"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = toset(var.private_subnet_cidrs)

    content {
      description = "HTTPS from private subnet ${ingress.value}"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  tags = {
    Name        = "${var.environment}-interface-endpoints-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.interface_endpoint_services

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.interface_endpoints[0].id]

  tags = {
    Name        = "${var.environment}-${replace(each.key, ".", "-")}-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
