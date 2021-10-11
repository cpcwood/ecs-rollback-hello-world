output "target_group_ecs" {
  value = aws_alb_target_group.ecs
}

output "dns_name" {
  value = aws_lb.ecs_alb.dns_name
}
