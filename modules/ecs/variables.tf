variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

# Network
variable "web_subnet_ids" {
  type = list(string)
}

variable "app_subnet_ids" {
  type = list(string)
}

# Security
variable "web_sg_id" {
  type = string
}

variable "app_sg_id" {
  type = string
}

# IAM
variable "ecs_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

# ALB
variable "web_target_group_arn" {
  type = string
}

variable "app_target_group_arn" {
  type = string
}

variable "internal_alb_dns" {
  type = string
}

# Container images
variable "web_container_image" {
  description = "Docker image for web tier (nginx)"
  type        = string
  default     = "nginx:latest"
}

variable "app_container_image" {
  description = "Docker image for app tier (tomcat)"
  type        = string
  default     = "tomcat:11-jdk21"
}

# Task sizing
variable "web_cpu" {
  description = "CPU units for web task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "web_memory" {
  description = "Memory in MB for web task"
  type        = number
  default     = 512
}

variable "app_cpu" {
  description = "CPU units for app task"
  type        = number
  default     = 512
}

variable "app_memory" {
  description = "Memory in MB for app task"
  type        = number
  default     = 1024
}

# Scaling
variable "web_desired_count" {
  type    = number
  default = 2
}

variable "web_min_count" {
  type    = number
  default = 2
}

variable "web_max_count" {
  type    = number
  default = 6
}

variable "app_desired_count" {
  type    = number
  default = 2
}

variable "app_min_count" {
  type    = number
  default = 2
}

variable "app_max_count" {
  type    = number
  default = 6
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}
