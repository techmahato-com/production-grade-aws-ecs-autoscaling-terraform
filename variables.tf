# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the infrastructure (for tagging)"
  type        = string
  default     = "DevOps-Team"
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "web_subnet_cidrs" {
  description = "CIDR blocks for web-tier private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for app-tier private subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for database-tier private subnets"
  type        = list(string)
  default     = ["10.0.31.0/24", "10.0.32.0/24"]
}

# -----------------------------------------------------------------------------
# ECS — Container Images
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# ECS — Task Sizing
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# ECS — Scaling
# -----------------------------------------------------------------------------
variable "web_desired_count" {
  description = "Desired number of web tasks"
  type        = number
  default     = 2
}

variable "web_min_count" {
  description = "Minimum number of web tasks"
  type        = number
  default     = 2
}

variable "web_max_count" {
  description = "Maximum number of web tasks"
  type        = number
  default     = 6
}

variable "app_desired_count" {
  description = "Desired number of app tasks"
  type        = number
  default     = 2
}

variable "app_min_count" {
  description = "Minimum number of app tasks"
  type        = number
  default     = 2
}

variable "app_max_count" {
  description = "Maximum number of app tasks"
  type        = number
  default     = 6
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

# -----------------------------------------------------------------------------
# Database (RDS)
# -----------------------------------------------------------------------------
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "javaapp"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for RDS"
  type        = number
  default     = 20
}

variable "db_backup_retention" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

# -----------------------------------------------------------------------------
# Monitoring
# -----------------------------------------------------------------------------
variable "sns_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Domain (Optional)
# -----------------------------------------------------------------------------
variable "domain_name" {
  description = "Domain name for the application (optional)"
  type        = string
  default     = ""
}
