variable "tf_state_bucket_region" {
  description = "AWS region the backend s3 bucket is created in"
  default = "eu-west-2"
}

variable "tf_state_s3_bucket" {
  description = "AWS S3 bucket to store main application terraform state in"
  default = "ecs-rollback-hello-world"
}

variable "tf_state_lock_table" {
  description = "AWS DynamoDB state lock table name"
  default = "ecs-rollback-hello-world-state-lock-table"
}
