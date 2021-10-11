# builds:
#   - backend s3 bucket to store main application terraform state
#   - dynamodb table to lock state during changes

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62"
    }
  }
  required_version = ">= 1.0.8"
}

provider "aws" {
  region = var.tf_state_bucket_region
  profile = "ecs-rollback-hello-world"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.tf_state_s3_bucket
  acl = "private"
  tags = {}

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = var.tf_state_lock_table 
  read_capacity = 1
  write_capacity = 1
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
