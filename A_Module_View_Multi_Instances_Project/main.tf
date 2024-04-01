module "server" {
  source = "./server"
}

#fetch output from module
output "server" {
  value = module.server.public_ip
}