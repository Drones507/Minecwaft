
# Minecwaft
**Christopher Harvey**
CS312 System Administration
Instructor: Sisavath Virasak
Course Project 2

## Project Overview

This repository provisions a Dockerized Minecraft server on AWS EC2 using Terraform.
All resources are created entirely through code — no AWS Console, no manual SSH, and no manual server setup.

The server runs on **Ubuntu 22.04 LTS** in the **Honolulu AWS Local Zone (`us-west-2-hnl-1a`)** — a physical data center in Honolulu managed by the us-west-2 (Oregon) region. This minimizes latency for players connecting from Hawaiʻi.

> **What is a Local Zone?** It is an AWS facility in a specific city (Honolulu) that extends the us-west-2 region. The parent region stays `us-west-2`; the Local Zone just controls *where the hardware physically sits*. EC2, EBS, VPC, and security groups all work normally. The only extra step is a one-time opt-in described in Setup Step 1.

## Requirements

### Tools to Install

| Tool      | Purpose                          |
|-----------|----------------------------------|
| Terraform | Provision AWS resources          |
| AWS CLI   | Programmatic AWS authentication  |
| Git       | Version control                  |
| nmap      | Verify port 25565 is open        |
| Minecraft | Connect to the deployed server   |

### AWS Credentials

You will need a standalone IAM user with programmatic access. Required credentials:

| Variable                | Description                              |
|-------------------------|------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | IAM user access key                      |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key                      |
| `AWS_DEFAULT_REGION`    | Set to `us-west-2`                       |

No `AWS_SESSION_TOKEN` is needed — that is only required for temporary credentials in AWS Academy Learner Labs.

## Setup Instructions

### 1. Enable the Honolulu Local Zone (one-time, manual)

Local Zones are disabled by default. Before running `terraform apply` for the first time:

1. AWS Console → **EC2** → **Settings** (left sidebar) → **Zones**
2. Find `us-west-2-hnl-1a` in the list
3. Click **Manage** → toggle **Enabled** → **Update zone group**

You only need to do this once per AWS account.

### 2. Create an IAM User

1. Sign in to the AWS Console → **IAM** → **Users** → **Create user**
2. Attach the **AmazonEC2FullAccess** managed policy (sufficient for this project)
3. Under **Security credentials**, create an **Access key** (CLI use case)
4. Save the Access Key ID and Secret Access Key — you will not see the secret again

> **Principle of least privilege:** For a hardened setup, scope the policy to only the specific EC2, VPC, and Security Group actions this project uses. AmazonEC2FullAccess is a practical starting point.

### 3. Create an EC2 Key Pair in us-west-2

1. AWS Console → **EC2** → **Key Pairs** → **Create key pair**
2. Name it something memorable (e.g. `minecwaft-key`)
3. Download the `.pem` file and keep it safe — it is never committed to this repo
4. Note the key pair name; you will set it as `key_name` in your `terraform.tfvars`

### 4. Clone the Repo

```bash
git clone https://github.com/Drones507/Minecwaft.git
cd Minecwaft
```

### 5. Configure Terraform Variables

```bash
cp minecraft-server-terraform-aws-instance/terraform.tfvars.example \
   minecraft-server-terraform-aws-instance/terraform.tfvars
```

Edit `terraform.tfvars` and fill in your values:

```hcl
key_name         = "minecwaft-key"       # the key pair name you created above
allowed_ssh_cidr = "203.0.113.5/32"     # your IP — or "0.0.0.0/0" to allow all
```

`terraform.tfvars` is listed in `.gitignore` — it will never be committed.

### 6. Configure AWS CLI (local runs)

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-west-2
```

Or set these in GitHub repository secrets for CI (see GitHub Actions section below).

### 7. Initialize Terraform

```bash
cd minecraft-server-terraform-aws-instance
terraform init
```

### 8. Apply Terraform Plan

```bash
terraform apply
```

Terraform will:
- Resolve the latest Ubuntu 22.04 LTS AMI for the region automatically
- Create a subnet in the default VPC pinned to `us-west-2-hnl-1a` (Honolulu)
- Launch a `t3.medium` EC2 instance in that subnet
- Create a security group with port 25565 (Minecraft) open to the world and port 22 (SSH) open to your configured CIDR
- Output the public IP and a ready-to-paste connection string

## How to Connect

### Verify Port is Open

```bash
nmap -sV -Pn -p T:25565 <public-ip>
```

Allow 2–3 minutes after `terraform apply` completes for the instance to boot and the Docker container to start.

### Connect from Minecraft

1. Open Minecraft → **Multiplayer** → **Add Server**
2. Enter `<public-ip>:25565` (also printed by `terraform output minecraft_connection_string`)
3. Click **Join Server**

## Project Structure

```
Minecwaft/
├── .github/workflows/
│   └── main.yml                      # CI/CD: provision EC2 and verify server on push to main
├── minecraft-server-terraform-aws-instance/
│   ├── main.tf                       # EC2, security group, Honolulu subnet, Ubuntu AMI lookup
│   ├── variables.tf                  # Input variables (region, AZ, instance type, key name, …)
│   ├── outputs.tf                    # Public IP and Minecraft connection string
│   ├── terraform.tfvars.example      # Template — copy to terraform.tfvars and fill in
│   ├── terraform.tfstate             # Live state (do not commit; keep for manual teardown)
│   ├── terraform.tfstate.backup      # Backup state
│   └── .terraform.lock.hcl          # Dependency lockfile
├── Dockerfile                        # Builds the Minecraft 1.20.1 server image
├── .gitignore
└── README.md
```

## High-Level Flow

```
1. GitHub push → GitHub Actions
2. Terraform creates a Honolulu-pinned subnet + EC2 instance in us-west-2-hnl-1a
3. EC2 boots → user_data installs Docker, clones repo, builds image, starts container
4. Port 25565 exposed → connect via Minecraft client from Hawaiʻi with low latency
```

## GitHub Actions

The `.github/workflows/main.yml` pipeline runs on every push to `main`.

### Required GitHub Secrets

| Secret                  | Value                                              |
|-------------------------|----------------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | IAM user access key                                |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key                                |
| `AWS_KEY_NAME`          | EC2 key pair name (e.g. `minecwaft-key`)           |
| `AWS_SSH_KEY`           | Contents of the `.pem` file (for SSH verification) |

Set these under **Settings → Secrets and variables → Actions** in your GitHub repo.

## Helpful Links

- [Terraform AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Local Zones — Features](https://aws.amazon.com/about-aws/global-infrastructure/localzones/features/)
- [AWS Local Zones — Getting Started](https://docs.aws.amazon.com/local-zones/latest/ug/getting-started.html)
- [itzg/minecraft-server Docker image](https://hub.docker.com/r/itzg/minecraft-server)
- [AWS EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
