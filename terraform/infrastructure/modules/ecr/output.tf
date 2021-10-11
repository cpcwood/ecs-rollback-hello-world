output "ecr_repository_endpoint" {
  value = aws_ecr_repository.this.repository_url
}
