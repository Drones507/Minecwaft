variable "region" {
  description = "AWS region for all resources. Parent region for the Honolulu Local Zone (us-west-2-hnl-1a) is us-west-2."
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type. t3.medium is recommended for a smooth Minecraft experience."
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in the target region. Create one in the AWS console under EC2 → Key Pairs, then set this value in terraform.tfvars."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to reach port 22. Defaults to open (0.0.0.0/0) for convenience — restrict to your IP (e.g. 1.2.3.4/32) in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "availability_zone" {
  description = "AZ or Local Zone to deploy into. us-west-2-hnl-1a is the Honolulu Local Zone — requires opt-in before apply (AWS Console → EC2 → Settings → Zones)."
  type        = string
  default     = "us-west-2-hnl-1a"
}

variable "minecraft_port" {
  description = "TCP port the Minecraft server listens on."
  type        = number
  default     = 25565
}
