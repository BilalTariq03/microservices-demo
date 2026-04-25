# ─────────────────────────────────────────────────────────────
# providers.tf  —  Tells Terraform WHICH cloud to talk to
# ─────────────────────────────────────────────────────────────
# A "provider" is a plugin that lets Terraform communicate
# with a specific platform (AWS, GCP, Azure, etc.)

terraform {
  required_version = ">= 1.5.0"   # Minimum Terraform version needed

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"           # Use AWS provider version 5.x
    }
  }
}

# Configure the AWS provider with our region
# Credentials come from environment variables (see README — never hardcode keys!)
provider "aws" {
  region = var.aws_region
}
