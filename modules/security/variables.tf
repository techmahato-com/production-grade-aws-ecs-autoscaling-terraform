variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "web_subnet_ids" {
  description = "Web tier subnet IDs for NACL association"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "App tier subnet IDs for NACL association"
  type        = list(string)
}

variable "db_subnet_ids" {
  description = "DB tier subnet IDs for NACL association"
  type        = list(string)
}
