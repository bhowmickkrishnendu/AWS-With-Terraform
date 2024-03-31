provider "aws" {
  region = var.region
  alias = "main"
}

resource "aws_key_pair" "keyname" {
  key_name = "${var.instance_name}"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Local file resource to save the private key locally
resource "local_file" "key_store_locally" {
  content = tls_private_key.rsa.private_key_pem
  filename = "${var.instance_name}.pem"
}

# AWS security group resource to control traffic
resource "aws_security_group" "allow_ssh" {
  name = "${var.instance_name}-SG"
  vpc_id = var.vpc_id

  # Ingress rule allow SSH traffic
  ingress {
    description = "Allow default SSH traffic"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Ingress rule allow custom SSH traffic
  ingress {
    description = "Allow custom port SSH traffic"
    from_port = 244
    to_port = 244
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Allow outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # add security group tags
  tags = {
    Name = "${var.instance_name}-SG"
  }
}

# AWS EC2 instance resource
resource "aws_instance" "instance_details" {
  ami = var.amazon_linux_2023_ami
  instance_type = var.t2.micro
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [ "${aws_security_group.allow_ssh}" ]
  associate_public_ip_address = true
  disable_api_termination = true
  key_name = var.instance_name

  # root block device configuration
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    delete_on_termination = false
  }

  # tags for ec2 instace
  tags = {
    Name = var.instance_name
  }
}

# output block to expose relevant information
output "public_ip" {
  value = aws_instance.instance_details.public_ip
}

output "ec2_id" {
  value = aws_instance.instance_details.id
}