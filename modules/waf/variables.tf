variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb_arn" {
  description = "ARN of the ALB to associate WAF with"
  type        = string
}
