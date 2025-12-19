terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }

  backend "s3" {
    bucket         = "aadith-terraform-state-bucket"
    key            = "strapi/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

locals {
  subnets = [
    "subnet-0dcf98e23a5861550",
    "subnet-0342cfb028d6aff5a"
  ]
}
