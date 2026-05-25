variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "web_service_name" {
  description = "ECS web service name"
  type        = string
}

variable "app_service_name" {
  description = "ECS app service name"
  type        = string
}

variable "db_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

variable "external_alb_arn_suffix" {
  type = string
}

variable "sns_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}
