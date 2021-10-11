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


# Networking
# ==========================

module "vpc" {
  source = "./modules/vpc"

  vpc_name = var.ecs_cluster_name
}


# ECR
# ==========================

module "ecr" {
  source = "./modules/ecr"

  ecr_repo_name = var.ecr_repo_name
}


# ECS
# ==========================

module "ecs" {
  source = "./modules/ecs"

  ecs_cluster_name = var.ecs_cluster_name
  container_image_uri = module.ecr.ecr_repository_endpoint
  container_image_tag = "latest"
  vpc_id = module.vpc.vpc_id
  ecs_service_subnets = module.vpc.public_subnet_ids
  ecr_repo_name = var.ecr_repo_name
  target_group_arn = module.alb.target_group_ecs.arn
  application_port = var.application_port
}


# Load Balancing
# ==========================

module "alb" {
  source = "./modules/alb"

  alb_name = var.ecs_cluster_name
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  application_port = var.application_port
}
