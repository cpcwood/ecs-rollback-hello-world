output "ecr_repository_endpoint" {
  value = module.ecr.ecr_repository_endpoint
}

output "task_definition_family" {
  value = module.ecs.task_definition_family
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "application_url" {
  value = module.alb.dns_name
}
