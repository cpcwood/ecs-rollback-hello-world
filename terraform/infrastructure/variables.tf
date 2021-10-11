variable "aws_region" {
  description = "AWS region to build application in"
  default = "eu-west-2"
}

variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
  default = "ecs-rollback-hello-world"
}

variable "ecr_repo_name" {
  description = "Name of container image to be deployed in ECS"
  default = "hello-world-go"
}

variable "availability_zones" {
  description = "list of availability zones"
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "public_subnets" {
  description = "list of CIDRs for public subnets in your VPC"
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "application_port" {
  description = "application port to forward http requests to"
  default = 8080
}
