terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62"
    }
  }
  required_version = ">= 1.0.8"
  backend "s3" {
    profile = "ecs-rollback-hello-world"
  }
}

provider "aws" {
  region = var.aws_region
  profile = "ecs-rollback-hello-world"
}

# data "terraform_remote_state" "state" {
#   backend = "s3"
#   config {
#     region = var.aws_region
#     bucket = var.tf_state_bucket
#     lock_table = var.tf_state_table
#     key = "ecs-rollback-hello-world.tfstate"
#   }
# }



