
# Minecwaft  
**Christopher Harvey**  
CS312 System Administration  
Instructor: Sisavath Virasak  
Course Project 2  

## Project Overview

This repository contains infrastructure provisioning scripts using Terraform to automate the deployment of a Minecraft server on AWS EC2. Due to IAM limitations in the AWS Learner Lab, ECS was not feasible, so this project uses a Dockerized Minecraft server on a provisioned EC2 instance.

All resources are created and configured entirely through code — no AWS Console, no SSH, and no manual setup.

## Requirements

### Tools to Install

| Tool       | Purpose                            |
|------------|-------------------------------------|
| Terraform  | Provision AWS resources             |
| AWS CLI    | Programmatic AWS authentication     |
| Git        | Version control                     |
| Docker     | Runs the Minecraft container        |
| nmap       | To verify open port 25565           |
| Minecraft  | To connect to the deployed server   |

### AWS Credentials

You will need:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_SESSION_TOKEN (for temporary credentials)
- AWS_DEFAULT_REGION (must be set to us-east-1)

Set them in your shell or using a .env file.

## Setup Instructions

### 1. Clone the Repo

```bash
git clone https://github.com/yourusername/Minecwaft.git
cd Minecwaft
```

### 2. Configure AWS CLI

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
export AWS_DEFAULT_REGION=us-east-1
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Apply Terraform Plan

```bash
terraform apply
```

Terraform will:
- Launch an EC2 instance
- Assign a security group with port 25565 open
- Attach an Elastic IP
- Install Docker via user_data
- Start the Minecraft server container

### 5. Connect via Minecraft

1. Open Minecraft
2. Multiplayer → Add Server
3. Use the Elastic IP output by Terraform
4. Port: 25565

You can also verify availability with:
```bash
nmap -sV -Pn -p T:25565 <public-ip>
```

## Project Structure

```bash
Minecwaft/
└── minecraft-server-terraform-aws-instance/
    ├── .terraform/
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── .terraform.lock.hcl
    └── README.md
```

## High-Level Flow

```text
1. GitHub Repo → Terraform
2. Terraform → AWS EC2 + Security Group + Elastic IP
3. EC2 boots → user_data installs Docker
4. Docker starts Minecraft container
5. Port 25565 exposed → You connect via Minecraft
```

## Helpful Links

- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build
- https://hub.docker.com/r/itzg/minecraft-server
