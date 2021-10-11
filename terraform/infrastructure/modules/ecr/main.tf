# ecr repository
resource "aws_ecr_repository" "this" {
  name = var.ecr_repo_name
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
 
  policy = jsonencode({
   rules = [{
     rulePriority = 1
     description = "keep last 10 images"
     action = {
       type = "expire"
     }
     selection = {
       tagStatus = "any"
       countType = "imageCountMoreThan"
       countNumber = 10
     }
   }]
  })
}
