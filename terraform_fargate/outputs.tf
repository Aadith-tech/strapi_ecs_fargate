output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.strapi_cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.strapi_service.name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.aadith_strapi_postgres.endpoint
  sensitive   = true
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for ECS tasks"
  value       = aws_cloudwatch_log_group.strapi_logs.name
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch Dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.strapi_dashboard.dashboard_name}"
}

output "cloudwatch_logs_url" {
  description = "URL to CloudWatch Logs"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.strapi_logs.name, "/", "$252F")}"
}