# =============================================================================
# Outputs
# =============================================================================

# Network
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_gateway_ips
}

# Load Balancers
output "external_alb_dns" {
  description = "External ALB DNS name — access your application here"
  value       = module.alb.external_alb_dns
}

output "internal_alb_dns" {
  description = "Internal ALB DNS name"
  value       = module.alb.internal_alb_dns
}

# ECS
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "web_service_name" {
  description = "ECS web service name"
  value       = module.ecs.web_service_name
}

output "app_service_name" {
  description = "ECS app service name"
  value       = module.ecs.app_service_name
}

# Database
output "db_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.db_endpoint
}

output "db_secret_arn" {
  description = "ARN of Secrets Manager secret with DB credentials"
  value       = module.rds.db_secret_arn
}

# Monitoring
output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

# ECS Exec command helper
output "ecs_exec_web" {
  description = "Command to exec into a web container"
  value       = "aws ecs execute-command --cluster ${module.ecs.cluster_name} --service ${module.ecs.web_service_name} --task <task-id> --container nginx --interactive --command /bin/sh"
}

output "ecs_exec_app" {
  description = "Command to exec into an app container"
  value       = "aws ecs execute-command --cluster ${module.ecs.cluster_name} --service ${module.ecs.app_service_name} --task <task-id> --container tomcat --interactive --command /bin/bash"
}
