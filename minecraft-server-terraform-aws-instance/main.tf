terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

resource "random_id" "suffix" {
  byte_length = 2
}

# Use the account's default VPC (172.31.0.0/16).
# The default VPC has no subnet in the Honolulu Local Zone, so we create one.
resource "aws_default_vpc" "default" {}

# Explicit subnet pinned to the Honolulu Local Zone.
# 172.31.48.0/20 is the next free /20 block after the three standard
# us-west-2 default subnets (…0/20, …16/20, …32/20).
# Prerequisite: opt the Local Zone into your account before applying —
# AWS Console → EC2 → Settings → Zones → us-west-2-hnl-1a → Enable.
resource "aws_subnet" "honolulu" {
  vpc_id                  = aws_default_vpc.default.id
  cidr_block              = "172.31.48.0/20"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "minecraft-hnl-subnet"
  }
}

# Resolve the latest Canonical Ubuntu 22.04 LTS AMI for the parent region.
# Local Zones share the parent region's AMI catalog.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg-${random_id.suffix.hex}"
  description = "Allow Minecraft and SSH access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Minecraft"
    from_port   = var.minecraft_port
    to_port     = var.minecraft_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.honolulu.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = var.key_name

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    apt-get update -y
    apt-get install -y docker.io git
    systemctl enable docker
    systemctl start docker

    cd /home/ubuntu
    git clone https://github.com/Drones507/Minecwaft.git
    cd Minecwaft
    docker build -t minecraft .
    docker run -d --restart unless-stopped --name mc -p ${var.minecraft_port}:${var.minecraft_port} minecraft
  EOF

  tags = {
    Name = "MinecraftEC2-Honolulu"
  }
}
