# Terraform AWS EC2 Instance Deployment

This Terraform configuration automates the deployment of an AWS EC2 instance along with necessary resources. The EC2 instance is configured to run a bash script during launch, installing Apache2, MySQL, and PHP for a comprehensive development environment. Additionally, a security group is created to allow SSH traffic.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
- AWS credentials configured on your system.

## Usage

1. **Clone the repository:**

   ```bash
   git clone <repository_url>
   cd <repository_directory>
    ```
2. **Create a terraform.tfvars file and specify the required variables:**

```
region = "your_aws_region"

```
3. **Initialize the Terraform configuration:**

```
terraform init

```
4. **Review the planned changes:**

```
terraform plan

```
5. **Apply the changes to deploy the EC2 instance:**

```
terraform apply
```

6. **After the deployment is complete, you can access the EC2 instance using the generated private key (Mumbai_First_Server.pem) and the public IP address.**

### Cleanup

**To destroy the created resources and avoid incurring additional costs:**
```
terraform destroy
```

## Terraform Configuration Explanation
### AWS Provider Configuration

The AWS provider is configured with the specified region and alias.

```
provider "aws" {
    region = var.region
    alias  = "main"
}
```

### Key Pair and TLS Private Key Resources

An AWS key pair for secure SSH access and a TLS private key resource are created.
```
resource "aws_key_pair" "Mumbai_First_Server" {
    key_name   = "Mumbai_First_Server"
    public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "local_file" "Mumbai_Key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "Mumbai_First_Server.pem"
}
```

### AWS EC2 Instance Resource with User Data
The main EC2 instance resource is configured with the specified AMI, instance type, and subnet. User data is utilized to run a bash script during launch, installing Apache2, MySQL, and PHP.
```
resource "aws_instance" "Mumbai_First_Server" {
    ami                            = "ami-0a7cf821b91bcccbc"
    instance_type                  = "t2.micro"
    subnet_id                      = "subnet-05160f5164e900466"
    vpc_security_group_ids         = [ "${aws_security_group.allow_ssh.id}" ]
    associate_public_ip_address    = true
    disable_api_termination        = true
    key_name                       = "Mumbai_First_Server"
    user_data                       = <<-EOF
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
    root_block_device {
      volume_size         = 10
      volume_type         = "gp2"
      delete_on_termination = false
    }
    tags = {
      Name = "Mumbai_First_server"
    }
    volume_tags = {
      Name = "Mumbai_First_Server"
    }
}
```

### AWS Security Group Resource
A security group is created to allow SSH traffic.
```
resource "aws_security_group" "allow_ssh" {
    name        = "Mumbai_First_Server-SG"
    description = "Control Traffic"
    vpc_id      = "vpc-0e5c7dd3912759f92"
    ingress {
        description = "Allow SSH traffic"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = {
        Name = "Mumbai_First_Server-SG"
    }
}
```

### Outputs
Output blocks expose relevant information such as the public key, private key, and EC2 instance ID.
```
output "public_key" {
    value = aws_instance.Mumbai_First_Server.public_ip
}

output "private_key" {
    value = aws_instance.Mumbai_First_Server.private_ip
}

output "ec2_id" {
    value = aws_instance.Mumbai_First_Server.id
}
```
## License
This Terraform configuration is licensed under the MIT License.
[MIT](https://choosealicense.com/licenses/mit/)

