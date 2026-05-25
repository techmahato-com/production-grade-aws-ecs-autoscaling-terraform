locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Security Group — External ALB
# -----------------------------------------------------------------------------
resource "aws_security_group" "external_alb" {
  name        = "${local.name_prefix}-ext-alb-sg"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-ext-alb-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — Web Tier (ECS Fargate - Nginx)
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow HTTP from External ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from External ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-web-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — Internal ALB
# -----------------------------------------------------------------------------
resource "aws_security_group" "internal_alb" {
  name        = "${local.name_prefix}-int-alb-sg"
  description = "Allow traffic from Web tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-int-alb-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — App Tier (ECS Fargate - Tomcat)
# -----------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allow 8080 from Internal ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Tomcat from Internal ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-app-sg" }
}

# -----------------------------------------------------------------------------
# Security Group — Database Tier (RDS)
# -----------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Allow MySQL from App tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from App tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-db-sg" }
}

# -----------------------------------------------------------------------------
# IAM — ECS Task Execution Role (pulls images, writes logs)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ecs_execution" {
  name = "${local.name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = { Name = "${local.name_prefix}-ecs-execution-role" }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------------------------------------------------------
# IAM — ECS Task Role (permissions for the running container)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = { Name = "${local.name_prefix}-ecs-task-role" }
}

# Allow ECS Exec for debugging (replaces bastion/SSH access)
resource "aws_iam_role_policy" "ecs_exec" {
  name = "${local.name_prefix}-ecs-exec"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Resource = "*"
    }]
  })
}

# -----------------------------------------------------------------------------
# NACLs — Web Tier
# -----------------------------------------------------------------------------
resource "aws_network_acl" "web" {
  vpc_id = var.vpc_id
  tags   = { Name = "${local.name_prefix}-web-nacl" }
}

resource "aws_network_acl_rule" "web_inbound_http" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "web_inbound_ephemeral" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "web_outbound_all" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# -----------------------------------------------------------------------------
# NACLs — App Tier
# -----------------------------------------------------------------------------
resource "aws_network_acl" "app" {
  vpc_id = var.vpc_id
  tags   = { Name = "${local.name_prefix}-app-nacl" }
}

resource "aws_network_acl_rule" "app_inbound_tomcat" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 8080
  to_port        = 8080
}

resource "aws_network_acl_rule" "app_inbound_ephemeral" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "app_outbound_all" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# -----------------------------------------------------------------------------
# NACLs — Database Tier
# -----------------------------------------------------------------------------
resource "aws_network_acl" "db" {
  vpc_id = var.vpc_id
  tags   = { Name = "${local.name_prefix}-db-nacl" }
}

resource "aws_network_acl_rule" "db_inbound_mysql" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "db_inbound_ephemeral" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "db_outbound_ephemeral" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

# -----------------------------------------------------------------------------
# NACL Associations
# -----------------------------------------------------------------------------
resource "aws_network_acl_association" "web" {
  count          = length(var.web_subnet_ids)
  network_acl_id = aws_network_acl.web.id
  subnet_id      = var.web_subnet_ids[count.index]
}

resource "aws_network_acl_association" "app" {
  count          = length(var.app_subnet_ids)
  network_acl_id = aws_network_acl.app.id
  subnet_id      = var.app_subnet_ids[count.index]
}

resource "aws_network_acl_association" "db" {
  count          = length(var.db_subnet_ids)
  network_acl_id = aws_network_acl.db.id
  subnet_id      = var.db_subnet_ids[count.index]
}
