# AWS provider configuration
provider "aws" {
    region = var.region                                             # Set the AWS region based on the 'region' variable
    alias  = "main"
}

# AWS key pair resource for secure SSH access
resource "aws_key_pair" "Mumbai_First_Server" {
    key_name   = "Mumbai_First_Server"
    public_key = tls_private_key.rsa.public_key_openssh
}

# TLS private key resource for the AWS key pair
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

# Local file resource to save the private key locally
resource "local_file" "Mumbai_Key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "Mumbai_First_Server.pem"
}

# AWS EC2 instance resource
resource "aws_instance" "Mumbai_First_Server" {
    ami                          = "ami-0a7cf821b91bcccbc"
    instance_type                = "t2.micro"
    subnet_id                    = "subnet-05160f5164e900466"
    vpc_security_group_ids       = ["${aws_security_group.allow_ssh.id}"]
    associate_public_ip_address  = true
    disable_api_termination      = true
    key_name                     = "Mumbai_First_Server"

    # Root block device configuration
    root_block_device {
        volume_size           = 10
        volume_type           = "gp2"
        delete_on_termination = false
    }

    # Volume tag for Root 
    volume_tags = {
    Name = "Mumbai_First_Server_Root" 
  }

    # Additional EBS volume configuration
    ebs_block_device {
        device_name           = "/dev/sdf"  # Specify the device name
        volume_type           = "gp2"
        volume_size           = 3
        delete_on_termination = false
        tags = {
            Name = "Mumbai_First_Server_EBS"
        }
    }

    # Tags for the EC2 instance
    tags = {
        Name = "Mumbai_First_Server"
    }
}

# AWS security group resource to allow SSH traffic
resource "aws_security_group" "allow_ssh" {
    name        = "Mumbai_First_Server-SG"
    description = "Control Traffic"
    vpc_id      = "vpc-0e5c7dd3912759f92"

    # Ingress rule to allow SSH traffic
    ingress {
        description = "Allow SSH traffic"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Egress rule to allow traffic outside
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Tags for the security group
    tags = {
        Name = "Mumbai_First_Server-SG"
    }
}

# Output block to expose relevant information
output "public_key" {
    value = aws_instance.Mumbai_First_Server.public_ip
}

output "private_key" {
    value = aws_instance.Mumbai_First_Server.private_ip
}

output "ec2_id" {
    value = aws_instance.Mumbai_First_Server.id
}