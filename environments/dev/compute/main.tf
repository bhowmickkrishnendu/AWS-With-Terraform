data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "krish-terraform-state-ap-south-1"
    key    = "dev/networking/terraform.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_key_pair" "deployer" {
  key_name = "${var.environment}-key"

  public_key = var.public_key
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [var.bastion_ssh_cidr]
  }

  egress {
    description = "SSH to private EC2 within the VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [var.bastion_ssh_cidr]
  }

  egress {
    description = "HTTPS access for package updates and SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = var.environment
  }
}


resource "aws_instance" "bastion" {
  ami                         = "ami-0f58b397bc5c1f2e8"
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnets[0]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = var.environment
  }
}

resource "aws_security_group" "private_ec2_sg" {
  name        = "${var.environment}-private-ec2-sg"
  description = "Security group for private EC2"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description = "SSH from bastion"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
    ]
  }

  egress {
    description = "HTTPS access for SSM and package updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-private-ec2-sg"
    Environment = var.environment
  }
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}


resource "aws_instance" "private_ec2" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.networking.outputs.private_subnets[0]
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name        = "${var.environment}-private-ec2"
    Environment = var.environment
  }
}

