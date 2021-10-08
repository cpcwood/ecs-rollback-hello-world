terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62"
    }
  }

  required_version = ">= 1.0.8"
  backend 's3' {}
}

