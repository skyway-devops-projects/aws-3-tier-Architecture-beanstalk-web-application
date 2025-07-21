terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5" # or latest
    }
  }
  #   backend "s3" {
  #   bucket                = "vprofile_terraform_state_backend"
  #   key                   = "vprofile/terraform.tfstate"
  #   region                = "us-east-1"
  #   dynamodb_table        = "vprofile_terraform_state_locks"
  # }
}