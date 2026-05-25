# =============================================================================
# Root Module — ECS Fargate 3-Tier Architecture
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Phase 1: Network & Foundation
# -----------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  web_subnet_cidrs    = var.web_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
}

# -----------------------------------------------------------------------------
# Phase 2: Security Configuration
# -----------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  vpc_cidr       = module.vpc.vpc_cidr
  web_subnet_ids = module.vpc.web_subnet_ids
  app_subnet_ids = module.vpc.app_subnet_ids
  db_subnet_ids  = module.vpc.db_subnet_ids
}

# -----------------------------------------------------------------------------
# Phase 3: Load Balancers
# -----------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  web_subnet_ids     = module.vpc.web_subnet_ids
  app_subnet_ids     = module.vpc.app_subnet_ids
  external_alb_sg_id = module.security.external_alb_sg_id
  internal_alb_sg_id = module.security.internal_alb_sg_id
}

# -----------------------------------------------------------------------------
# Phase 4: ECS Fargate (Web + App)
# -----------------------------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # Network
  web_subnet_ids = module.vpc.web_subnet_ids
  app_subnet_ids = module.vpc.app_subnet_ids

  # Security
  web_sg_id = module.security.web_sg_id
  app_sg_id = module.security.app_sg_id

  # IAM
  ecs_execution_role_arn = module.security.ecs_execution_role_arn
  ecs_task_role_arn      = module.security.ecs_task_role_arn

  # ALB
  web_target_group_arn = module.alb.web_target_group_arn
  app_target_group_arn = module.alb.app_target_group_arn
  internal_alb_dns     = module.alb.internal_alb_dns

  # Container images
  web_container_image = var.web_container_image
  app_container_image = var.app_container_image

  # Task sizing
  web_cpu    = var.web_cpu
  web_memory = var.web_memory
  app_cpu    = var.app_cpu
  app_memory = var.app_memory

  # Scaling
  web_desired_count = var.web_desired_count
  web_min_count     = var.web_min_count
  web_max_count     = var.web_max_count
  app_desired_count = var.app_desired_count
  app_min_count     = var.app_min_count
  app_max_count     = var.app_max_count
  cpu_target_value  = var.cpu_target_value
}

# -----------------------------------------------------------------------------
# Phase 5: Database (RDS)
# -----------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  environment          = var.environment
  db_subnet_ids        = module.vpc.db_subnet_ids
  db_sg_id             = module.security.db_sg_id
  db_instance_class    = var.db_instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_allocated_storage = var.db_allocated_storage
  db_backup_retention  = var.db_backup_retention
}

# -----------------------------------------------------------------------------
# Phase 6: Monitoring & Observability
# -----------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name            = var.project_name
  environment             = var.environment
  ecs_cluster_name        = module.ecs.cluster_name
  web_service_name        = module.ecs.web_service_name
  app_service_name        = module.ecs.app_service_name
  db_instance_id          = "${var.project_name}-${var.environment}-mysql"
  external_alb_arn_suffix = module.alb.external_alb_arn
  sns_email               = var.sns_email
}

# -----------------------------------------------------------------------------
# Phase 7: WAF
# -----------------------------------------------------------------------------
module "waf" {
  source = "./modules/waf"

  project_name = var.project_name
  environment  = var.environment
  alb_arn      = module.alb.external_alb_arn
}
