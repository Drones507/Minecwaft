terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Security Group for Minecraft
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg"
  description = "Allow Minecraft port"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use default VPC
data "aws_availability_zones" "available" {}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

# EC2 Instance with Minecraft Docker server
resource "aws_instance" "minecraft" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 25565:25565 -e EULA=TRUE -e MEMORY=1G --restart unless-stopped itzg/minecraft-server
              EOF

  tags = {
    Name = "MinecraftEC2"
  }
}

# Create Elastic IP
resource "aws_eip" "minecraft_eip" {
  instance = aws_instance.minecraft.id
  vpc      = true
}
