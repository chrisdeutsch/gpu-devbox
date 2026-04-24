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

data "aws_ec2_instance_type_offerings" "gpu" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }

  location_type = "availability-zone"
}

locals {
  availability_zone = sort(data.aws_ec2_instance_type_offerings.gpu.locations)[0]
}

resource "aws_vpc" "devbox" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "gpu-devbox-vpc"
  }
}

resource "aws_internet_gateway" "devbox" {
  vpc_id = aws_vpc.devbox.id

  tags = {
    Name = "gpu-devbox-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.devbox.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "gpu-devbox-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devbox.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devbox.id
  }

  tags = {
    Name = "gpu-devbox-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ssh" {
  name        = "gpu-devbox-ssh"
  description = "SSH from my IP only"
  vpc_id      = aws_vpc.devbox.id

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

resource "aws_instance" "devbox" {
  ami                         = data.aws_ami.gpu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/cloud-init.yaml")

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = 150
    volume_type = "gp3"
  }

  tags = {
    Name = "gpu-devbox"
  }
}
