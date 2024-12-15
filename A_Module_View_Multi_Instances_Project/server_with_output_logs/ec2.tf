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
  instance_type = var.t2micro
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [ "${aws_security_group.allow_ssh.id}" ]
  associate_public_ip_address = true
  disable_api_termination = true
  key_name = var.instance_name

  # root block device configuration
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    delete_on_termination = false
  }

  volume_tags = {
    Name = var.instance_name
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

# username and password generation
resource "null_resource" "generate_credentials" {
  provisioner "local-exec" {
#     command = <<EOF
# PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*()+' < /dev/urandom | head -c 20)
# USERNAME=$(tr -dc 'a-z' < /dev/urandom | head -c 6)
# echo "Generated Password: $PASSWORD" > ./credentials.txt
# echo "Generated Username: $USERNAME" >> ./credentials.txt
# echo $PASSWORD
# echo $USERNAME
# EOF
      command = "powershell.exe -File generate_credentials.ps1"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

#Transfer the credentials.txt file to the remote server
resource "null_resource" "transfer_credentials" {
  provisioner "file" {
    source = "credentials.txt"
    destination = "/tmp/credentials.txt"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("${var.instance_name}.pem")
      host = aws_instance.instance_details.public_ip
    }
  }

  triggers = {
    instance_id = aws_instance.instance_details.id
  }

  depends_on = [null_resource.generate_credentials]
}

# user data script excution
resource "null_resource" "copy_script" {
  depends_on = [ aws_instance.instance_details ]
  provisioner "file" {
    source = "script.sh"
    destination = "/home/ec2-user/script.sh"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("${var.instance_name}.pem")
      host = aws_instance.instance_details.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /home/ec2-user/script.sh",
      "/home/ec2-user/script.sh"
     ]
     connection {
       type = "ssh"
       user = "ec2-user"
       private_key = file("${var.instance_name}.pem")
       host = aws_instance.instance_details.public_ip
     }
  }
}