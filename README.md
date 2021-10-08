# AWS ECS Rollback - Hello World


## Building Infrastructure

Create IAM user with S3 and DynamoDB access.

Add `ecs-rollback-hello-world` AWS profile to credentials list:

```sh
sudo vim ~/.aws/credentials
```

```
[ecs-rollback-hello-world]
aws_access_key_id = 
aws_secret_access_key = 
```

### Create infrastructure

Create a `.env` file from the `.env/example` in the project root with required AWS configuration variables.

Run build script:

```sh
./bin/build_infrastructure
```

### Create ECS Infrastructure
