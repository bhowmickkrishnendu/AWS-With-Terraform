variable "region" {}
variable "availability_zone" {}
variable "availability_zone1" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "environment" {}
variable "enable_vpc_peering" { default = false } # New boolean variable
variable "peer_vpc_id" { default = "" } # Default empty if peering is false
variable "enable_nat_gateway" { default = true }  # Toggle NAT Gateway
variable "nat_gateway_eip_id" { default = "" }  # Option to use existing Elastic IP