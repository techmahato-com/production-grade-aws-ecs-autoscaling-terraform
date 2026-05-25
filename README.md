# production-grade-aws-ecs-autoscaling-terraform

Production-grade AWS ECS Fargate infrastructure using Terraform with ECS Auto Scaling, Application Load Balancer (ALB), modular Terraform architecture, CloudWatch monitoring, secure VPC networking, remote backend state management, and DevOps best practices for scalable cloud deployments.

## Architecture

3-tier ECS Fargate architecture:

```
Internet → External ALB → ECS Web Service (Nginx/Fargate) → Internal ALB → ECS App Service (Tomcat/Fargate) → RDS MySQL
```

## Modules

| Module | Purpose |
|--------|---------|
| `vpc` | VPC with public, web, app, and DB subnets across 2 AZs |
| `security` | Security groups + ECS IAM roles (execution + task) + NACLs |
| `alb` | External ALB (internet-facing) + Internal ALB (app tier) |
| `ecs` | ECS Cluster, Task Definitions, Services, Auto Scaling |
| `rds` | MySQL RDS with Secrets Manager |
| `monitoring` | CloudWatch dashboard, alarms, SNS notifications |
| `waf` | AWS WAF attached to external ALB |

## Usage

```bash
# Initialize
terraform init

# Plan for dev
terraform plan -var-file=environments/dev/terraform.tfvars

# Apply
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Environments

- `environments/dev/terraform.tfvars` — minimal resources for development
- `environments/staging/terraform.tfvars` — staging with moderate scaling
- `environments/prod/terraform.tfvars` — production-grade with HA

## Container Images

Replace the default images in tfvars with your ECR repository URLs:

```hcl
web_container_image = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/ecommerce-nginx:latest"
app_container_image = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/ecommerce-app:latest"
```

## Debugging (replaces SSH/Bastion)

```bash
aws ecs execute-command \
  --cluster ecommerce-dev-cluster \
  --service ecommerce-dev-web \
  --task <task-id> \
  --container nginx \
  --interactive \
  --command /bin/sh
```
