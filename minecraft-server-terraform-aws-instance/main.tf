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

resource "random_id" "suffix" {
  byte_length = 2
}

resource "aws_default_vpc" "default" {}

data "aws_availability_zones" "available" {}

resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg-${random_id.suffix.hex}"
  description = "Allow Minecraft and SSH access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "minecraft" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = "CourseProject2"

  tags = {
    Name = "MinecraftEC2"
  }
}

output "minecraft_server_ip" {
  value = aws_instance.minecraft.public_ip
}
