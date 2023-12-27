# AWS provider configuration
provider "aws" {
    region = var.region                                             # Set the AWS region based on the 'region' variable
    alias = "main"
}

# AWS EC2 instance resource
resource "aws_instance" "Mumbai_First_Server" {

    ami = "ami-0a7cf821b91bcccbc"                                   # Specify the Amazon Machine Image (AMI)
    instance_type = "t2.micro"                                      # Specify the instance type
    subnet_id = "subnet-05160f5164e900466"                          # Specify the subnet ID
    vpc_security_group_ids = [ "${aws_security.allow_ssh.id}" ]     # Specify the security group ID
    associate_public_ip_address = true                              # Assign a public IP address to the instance
    disable_api_termination = true                                  # Disable API termination for the instance

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

# AWS security group resource to allow SSH traffic
resource "aws_security_group" "allow_ssh" {
    name = "Mumbai_First_Server-SG"
    description = "Control Traffic"
    vpc_id = "vpc-0e5c7dd3912759f92"

    # Ingress rule to allow SSH traffic
    ingress {
        description = "Allow SSH traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Tags for the security group
    tags = {
        Name = "Mumbai_First_Server-SG"
    }
}
