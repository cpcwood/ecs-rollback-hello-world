# AWS ECS Rollback - Hello World

Sample AWS Elastic Container Service (ECS) application with deploy and rollback deploy scripts, referenced in [Rolling back AWS Elastic Container Service (ECS) Deployments](https://www.cpcwood.com/blog/4-rolling-back-aws-elastic-container-service-ecs-deployments).

## Dependencies

Install required dependencies:
- [bash](https://www.gnu.org/software/bash/) - [command-not-found](https://command-not-found.com/bash)
- [aws-cli v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [jq](https://stedolan.github.io/jq/download/)
- [dialog](https://linux.die.net/man/1/dialog) - [command-not-found](https://command-not-found.com/dialog)

## Building Infrastructure

Create IAM user with relevant permissions for Terraform ECS setup (S3, DynamoDB, ECS, ECR, etc), or `AdministratorAccess` for quicker setup.

Add `ecs-rollback-hello-world` AWS profile to credentials list:

```sh
sudo vim ~/.aws/credentials
```

```
[ecs-rollback-hello-world]
aws_access_key_id = <iam user access key id>
aws_secret_access_key = <iam user secret key>
```

### Create infrastructure

Fork or clone the project.

Create a `.env` file from the `.env/example` in the project root with required configuration variables.

Run build script:

```sh
./bin/build_infrastructure
```

### Create ECS Infrastructure

IMPORTANT: The infrastructure required for ECS is not covered by the AWS `Always free` tier, therefore running this command may cost you money. Remember evaluate costs and to teardown project afterwards.

Run the `./bin/build_infrastructure` to build sample ECS infrastructure.

### Initial Deploy

Deploy the first revision of the application to ECR:

```sh
./bin/deploy
```

After a couple minutes the application should be available at the 'Application URL' output at the end of the script.

## Rolling Back

### Update Application

Make noticeable change to the application. For example:

```go
// ./hello.go
// ...

func HelloServer(w http.ResponseWriter, r *http.Request) {
  // fmt.Fprintf(w, "Hello, World!")
  fmt.Fprintf(w, "Roll me back!")
  log.Printf("Received request for path: %s", r.URL.Path)
}
```

Commit with suitable message and deploy changes:

```sh
git add ./hello.go
git commit -m 'updated server welcome message'
./bin/deploy
```

Check the application url for the changes.

### Rollback Application

Once changes have been applied, rollback using either:

- simple rollback script - `./bin/rollback`
- dialog rollback script - `./bin/rollback_dialog`

Rollbacks will take a couple minutes as new tasks are provisioned and started, check the application url for the changes.

## Teardown Infrastructure

Run the `./bin/teardown_infrastructure` to use Terraform to remove the sample ECS application infrastructure.

You may also need to [deregister](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deregister-task-definition.html) any additional ECS task definitions not managed by Terraform.
