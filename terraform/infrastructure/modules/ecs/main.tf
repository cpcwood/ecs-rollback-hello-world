
resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.ecs_cluster_name}-ecsTaskExecutionRole"
 
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "this" {
  family = var.ecs_cluster_name
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([{
    image = "${var.container_image_uri}:${var.container_image_tag}"
    name = var.ecr_repo_name
    essential = true
    portMappings = [{
      protocol = "tcp"
      containerPort = var.application_port
      hostPort = var.application_port
    }]
  }])
}

# add security group for vpc
resource "aws_security_group" "ecs_service" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = var.application_port
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

resource "aws_ecs_service" "this" {
  name = var.ecs_cluster_name
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  
  network_configuration {
    security_groups = [aws_security_group.ecs_service.id]
    subnets = var.ecs_service_subnets
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = var.ecr_repo_name
    container_port = var.application_port
  }
  
  lifecycle {
    ignore_changes = [task_definition]
  }
}
