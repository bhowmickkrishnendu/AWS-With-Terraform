# AWS provider configuration
provider "aws" {
    region = var.region                                             # Set the AWS region based on the 'region' variable
    alias = "main"
}

# AWS key pair resource for secure SSH access
resource "aws_key_pair" "Mumbai_First_Server" {
    key_name = "Mumbai_First_Server"
    public_key = tls_private_key.rsa.public_key_openssh
}

# TLS private key resource for the AWS key pair
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# Local file resource to save the private key locally
resource "local_file" "Mumbai_Key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "Mumbai_First_Server.pem"
}


# AWS EC2 instance resource
resource "aws_instance" "Mumbai_First_Server" {
    ami = "ami-0a7cf821b91bcccbc"
    instance_type = "t2.micro"
    subnet_id = "subnet-05160f5164e900466"
    vpc_security_group_ids = [ "${aws_security_group.allow_ssh.id}" ]
    associate_public_ip_address = true
    disable_api_termination = true
    key_name = "Mumbai_First_Server"

    user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y apache2
                apt-get install -y mysql-server
                apt-get install -y php libapache2-mod-php php-mysql
                systemctl enable apache2
                systemctl start apache2
                systemctl enable mysql
                systemctl start mysql
                EOF

    # Root block device configuration
    root_block_device {
      volume_size = 10
      volume_type = "gp2"
      delete_on_termination = false
    }

    # Tags for the EC2 instance
    tags = {
      Name = "Mumbai_First_server"
    }

    # Tags for the attached volume
    volume_tags = {
      Name = "Mumbai_First_Server"
    }
}

