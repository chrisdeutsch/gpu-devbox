terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.11"
}

provider "aws" {
  profile = "personal"
  region  = "eu-central-1"
}

data "aws_ami" "gpu" {
  most_recent = true
  owners      = ["898082745236"] # Amazon Deep Learning AMI

  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 24.04)*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "gpu-devbox-ssh"
  description = "SSH from my IP only"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.gpu.id
  instance_type          = "g6.xlarge"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  user_data              = file("${path.module}/cloud-init.yaml")

  root_block_device {
    volume_size = 150
    volume_type = "gp3"
  }

  tags = {
    Name = "gpu-devbox"
  }
}
