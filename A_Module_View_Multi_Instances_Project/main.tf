module "server" {
  source = "./server"
}

module "server_with_output_logs" {
  source = "./server_with_output_logs"
}

#fetch output from module
output "server_with_output_logs" {
  value = module.server_with_output_logs.public_ip
}