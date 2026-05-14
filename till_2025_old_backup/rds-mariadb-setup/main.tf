provider "aws" {
  region = var.region
}

resource "aws_db_instance" "test_mariadb" {
  engine                 = "mariadb"
  engine_version         = "10.11.6"
  db_name                = "studentdb"
  identifier             = "testmdb"
  username               = "admin"
  password               = random_password.db_password.result
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  max_allocated_storage  = 1000
  availability_zone      = var.availability_zone
  vpc_security_group_ids = ["sg-0878feb5745da1fe4"]
  db_subnet_group_name   = aws_db_subnet_group.mariadb_subnet_group.name
  publicly_accessible    = false
  backup_retention_period = 7
  deletion_protection     = true
  skip_final_snapshot     = true
  apply_immediately      = true

  tags = {
    Name = "testmdb"
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "mariadb_subnet_group" {
  name        = "mariadb-subnet-group"
  description = "Subnet group for MariaDB instance"
  subnet_ids  = ["subnet-04d2127613eb2e422", "subnet-06cc846fc81336e69"]

  tags = {
    Name = "MariaDB Subnet Group"
  }
}

output "db_endpoint" {
  description = "The endpoint of the MariaDB instance"
  value       = aws_db_instance.test_mariadb.endpoint
}

output "db_password" {
  description = "The password for the MariaDB instance"
  value       = random_password.db_password.result
  sensitive   = true
}