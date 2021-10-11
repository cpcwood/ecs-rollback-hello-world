output "tf_state_s3_bucket" {
  value = aws_s3_bucket.terraform_state.id
}

output "tf_state_lock_table" {
  value = aws_dynamodb_table.terraform_state_lock.id
}
