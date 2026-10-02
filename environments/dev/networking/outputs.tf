output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "availability_zones" {
  value = var.availability_zones
}

output "s3_gateway_endpoint_id" {
  value = try(aws_vpc_endpoint.s3[0].id, null)
}

output "interface_endpoint_ids" {
  value = { for service, endpoint in aws_vpc_endpoint.interface : service => endpoint.id }
}
