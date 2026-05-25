output "external_alb_sg_id" {
  value = aws_security_group.external_alb.id
}

output "web_sg_id" {
  value = aws_security_group.web.id
}

output "internal_alb_sg_id" {
  value = aws_security_group.internal_alb.id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}

output "web_nacl_id" {
  value = aws_network_acl.web.id
}

output "app_nacl_id" {
  value = aws_network_acl.app.id
}

output "db_nacl_id" {
  value = aws_network_acl.db.id
}
