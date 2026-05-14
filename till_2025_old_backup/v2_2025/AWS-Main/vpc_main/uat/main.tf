module "ref" {
  source = "D:\\my_github\\AWS-With-Terraform\\v2_2025\\module\\AWS-Reference-Main-Module-For-All"

    region             = var.region
    availability_zone  = var.availability_zone
    availability_zone1 = var.availability_zone1
    project_name       = var.project_name
}

module "vpc" {
  source = "D:\\my_github\\AWS-With-Terraform\\v2_2025\\module\\AWS-VPC-Module"

    region             = module.ref.region
    availability_zone  = module.ref.availability_zone
    availability_zone1 = module.ref.availability_zone1
    project_name       = module.ref.project_name
    vpc_cidr           = var.vpc_cidr
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    environment        = var.environment
    enable_vpc_peering = var.enable_vpc_peering
    peer_vpc_id       = var.peer_vpc_id
    enable_nat_gateway = var.enable_nat_gateway 
}
