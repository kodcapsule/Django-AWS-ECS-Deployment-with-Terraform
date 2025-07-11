
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}