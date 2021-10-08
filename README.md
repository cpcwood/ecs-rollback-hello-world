# AWS ECS Rollback - Hello World


## Building Infrastructure

Add `ecs-rollback-hello-world` AWS profile to credentials list:

```sh
sudo vim ~/.aws/credentials
```

### Create remote state infrastructure

Move to infrastructure dir:

```sh
cd .infrastructure/install
```

Set init variables:

```sh
TF_VAR_tf_state_s3_bucket=<your-tf-state-bucket-name>
```

Create remote backend:

```sh
terraform init && terraform apply -var "tf_state_s3_bucket=$TF_VAR_tf_state_bucket"
```

### Create ECS Infrastructure
