# ─────────────────────────────────────────────────────────────
# variables.tf  —  All configurable inputs for our infrastructure
# ─────────────────────────────────────────────────────────────
# Variables let you change settings without touching main.tf.
# Think of them like function parameters.

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"   # Northern Virginia — cheapest & most common
}

variable "instance_type" {
  description = "EC2 instance size. t3.medium gives 2 vCPUs + 4GB RAM (enough for k8s)"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for us-east-1. Change if using a different region."
  type        = string
  default     = "ami-0261755bbcb8c4a84"   # Ubuntu 22.04 LTS in us-east-1
}

variable "public_key_path" {
  description = "Path to your local SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"   # Default location on most machines
}
