output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "web_service_name" {
  value = aws_ecs_service.web.name
}

output "app_service_name" {
  value = aws_ecs_service.app.name
}

output "web_log_group" {
  value = aws_cloudwatch_log_group.web.name
}

output "app_log_group" {
  value = aws_cloudwatch_log_group.app.name
}
