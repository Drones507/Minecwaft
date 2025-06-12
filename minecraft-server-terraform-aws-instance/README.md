
# Minecwaft  
**Christopher Harvey**  
CS312 System Administration  
Instructor: Sisavath Virasak  
Course Project 2  

## Project Overview

This repository contains infrastructure provisioning scripts using Terraform to automate the deployment of a Minecraft server on AWS EC2. Due to IAM limitations in the AWS Learner Lab, ECS was not feasible, so this project uses a Dockerized Minecraft server on a provisioned EC2 instance.

All resources are created and configured entirely through code — no AWS Console, no manual SSH, and no manual server setup.

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

Set them in your shell or using GitHub Secrets.

## Setup Instructions

### 1. Clone the Repo

```bash
git clone https://github.com/yourusername/Minecwaft.git
cd Minecwaft
```

### 2. Configure AWS CLI (if running locally)

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
export AWS_DEFAULT_REGION=us-east-1
```

Or store these in GitHub repository secrets before running GitHub Actions.

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
- Output the public IP for GitHub Actions to connect
- Let GitHub Actions install Docker and start the Minecraft server via SSH

## How to Connect

### Verify Port is Open

```bash
nmap -sV -Pn -p T:25565 <public-ip>
```

### Connect from Minecraft

1. Open Minecraft
2. Multiplayer → Add Server
3. Enter your public IP and port 25565
4. Click Join Server

## Project Structure

```bash
Minecwaft/
└── minecraft-server-terraform-aws-instance/
    ├── .terraform/                   # Terraform plugin/cache files
    ├── main.tf                       # Terraform config to provision EC2 and networking
    ├── outputs.tf                    # Outputs public IP for Minecraft connection
    ├── terraform.tfstate             # Current state of provisioned infrastructure
    ├── terraform.tfstate.backup      # Backup state
    ├── .terraform.lock.hcl           # Dependency lockfile
    └── README.md                     # Project overview and usage instructions
```

## High-Level Flow

```text
1. GitHub Repo → GitHub Actions
2. Terraform provisions AWS EC2 + Security Group + Elastic IP
3. EC2 boots → IP is extracted from Terraform output
4. GitHub Actions SSHes in → Installs Docker
5. Minecraft server container starts
6. Port 25565 exposed → You connect via Minecraft
```

## Helpful Links

- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build
- https://hub.docker.com/r/itzg/minecraft-server

## GitHub Actions: Docker Build Automation

This project includes a `.github/workflows/main.yml` pipeline that:

- Automatically provisions AWS EC2 and networking on every push to `main`
- SSHes into the EC2 instance using a GitHub secret key
- Installs Docker and runs the Minecraft container
- Does not push any images to Docker Hub (for privacy and grading compliance)

The `Dockerfile` (if used) pulls the official Minecraft server JAR (version 1.20.1) directly from Mojang and sets `eula=true` automatically.