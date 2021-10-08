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

variable "container_image_name" {
  description = "Name of container image to be deployed in ECS"
  default = "hello-world-go"
}

variable "aws_region" {
  description = "AWS region to build ecs cluster in"
  default = "eu-west-2"
}

variable "availability_zones" {
  description = "list of availability zones"
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "public_subnets" {
  description = "list of CIDRs for public subnets in your VPC"
  default = ["10.1.1.0/24", "10.1.2.0/24"]
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



# Networking
# ==========================

# vpc for ecs
resource "aws_vpc" "ecs-rollback-hello-world" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-rollback-hello-world"
  }
}

# vpc subnet - public
resource "aws_subnet" "ecs-rollback-hello-world-subnet-public" {
  vpc_id = aws_vpc.ecs-rollback-hello-world.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-rollback-hello-world-subnet-public"
  }
}

# connect vpc to internet
resource "aws_internet_gateway" "ecs-rollback-hello-world" {
  vpc_id = aws_vpc.ecs-rollback-hello-world.id

  tags = {
    Name = "ecs-rollback-hello-world"
  }
}

# route traffic from vpc to internet gateway
resource "aws_route_table" "ecs-rollback-hello-world" {
  vpc_id = aws_vpc.ecs-rollback-hello-world.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs-rollback-hello-world.id
  }
}

# add route table to subnet
resource "aws_route_table_association" "ecs-rollback-hello-world-ig-to-pubic" {
  count = length(var.public_subnets)
  subnet_id = element(aws_subnet.ecs-rollback-hello-world-subnet-public.*.id, count.index)
  route_table_id = aws_route_table.ecs-rollback-hello-world.id
}

# add security group for vpc
resource "aws_security_group" "ecs-rollback-hello-world-ecs" {
  vpc_id = aws_vpc.ecs-rollback-hello-world.id

  ingress {
    from_port = 80
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ECR
# ==========================

# ecr repository
resource "aws_ecr_repository" "ecs-rollback-hello-world" {
  name = "ecs-rollback-hello-world"
}

resource "aws_ecr_lifecycle_policy" "ecs-rollback-hello-world" {
  repository = aws_ecr_repository.ecs-rollback-hello-world.name
 
  policy = jsonencode({
   rules = [{
     rulePriority = 1
     description = "keep last 5 images"
     action = {
       type = "expire"
     }
     selection = {
       tagStatus = "any"
       countType = "imageCountMoreThan"
       countNumber = 5
     }
   }]
  })
}

# output ecr repo endpoint
output "ecs-rollback-hello-world-endpoint" {
  value = aws_ecr_repository.ecs-rollback-hello-world.repository_url
}


# ECS
# ==========================

resource "aws_ecs_cluster" "ecs-rollback-hello-world" {
  name = "ecs-rollback-hello-world"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-rollback-hello-world-ecsTaskExecutionRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs-rollback-hello-world" {
  family = "ecs-rollback-hello-world"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([{
    image = "${var.container_image_name}:latest"
    name = var.container_image_name
    essential = true
    portMappings = [{
      protocol = "tcp"
      containerPort = 8080
      hostPort = 8080
    }]
  }])
}

resource "aws_ecs_service" "ecs-rollback-hello-world" {
  name = "ecs-rollback-hello-world"
  cluster = aws_ecs_cluster.ecs-rollback-hello-world.id
  task_definition = aws_ecs_task_definition.ecs-rollback-hello-world.arn
  desired_count = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  
  network_configuration {
    security_groups = [aws_security_group.ecs-rollback-hello-world-ecs.id]
    subnets = aws_subnet.ecs-rollback-hello-world-subnet-public.*.id
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_alb_target_group.ecs-rollback-hello-world.arn
    container_name = var.container_image_name
    container_port = 8080
  }
  
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

# Load Balancing
# ==========================

resource "aws_security_group" "ecs-rollback-hello-world-alb" {
  name = "ecs-rollback-hello-world-alb"
  vpc_id = aws_vpc.ecs-rollback-hello-world.id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ecs-rollback-hello-world-alb"
  }
}

resource "aws_lb" "ecs-rollback-hello-world" {
  name = "ecs-rollback-hello-world"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.ecs-rollback-hello-world-alb.id]
  subnets = aws_subnet.ecs-rollback-hello-world-subnet-public.*.id
 
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "ecs-rollback-hello-world" {
  name = "ecs-rollback-hello-world"
  port = 8080
  protocol = "HTTP"
  vpc_id = aws_vpc.ecs-rollback-hello-world.id
  target_type = "ip"
 
  health_check {
    healthy_threshold = "3"
    interval = "30"
    protocol = "HTTP"
    matcher = "200"
    timeout = "3"
    path = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.ecs-rollback-hello-world.id
  port = 80
  protocol = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.ecs-rollback-hello-world.id
    type = "forward"
  }
}
