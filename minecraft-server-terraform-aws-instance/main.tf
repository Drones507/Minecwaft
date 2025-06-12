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
  byte_length = 4
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg-${random_id.suffix.hex}"
  description = "Allow Minecraft and SSH"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Allow Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from anywhere"
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

  tags = {
    Name = "minecraft-sg-${random_id.suffix.hex}"
  }
}



# Use default VPC
data "aws_availability_zones" "available" {}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

# EC2 Instance (no user_data)
resource "aws_instance" "minecraft" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name = "CourseProject2"

  tags = {
    Name = "MinecraftEC2"
  }
}

# Create Elastic IP
resource "aws_eip" "minecraft_eip" {
  instance = aws_instance.minecraft.id
  vpc      = true
}
