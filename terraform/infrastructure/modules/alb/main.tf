
resource "aws_security_group" "ecs_alb" {
  name = "${var.alb_name}-alb"
  vpc_id = var.vpc_id

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.alb_name}-alb"
  }
}

resource "aws_lb" "ecs_alb" {
  name = var.alb_name
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.ecs_alb.id]
  subnets = var.subnet_ids
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "ecs" {
  name = var.alb_name
  port = var.application_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"
  deregistration_delay = 3
 
  health_check {
    healthy_threshold = "3"
    interval = "10"
    protocol = "HTTP"
    matcher = "200"
    timeout = "3"
    path = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.id
  port = 80
  protocol = "HTTP"
 
  default_action {
    target_group_arn = aws_alb_target_group.ecs.id
    type = "forward"
  }
}
