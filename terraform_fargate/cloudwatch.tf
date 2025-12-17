# Alarm: High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "aadith-strapi-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 80   # 80% CPU
  alarm_description   = "This metric monitors ECS CPU utilization"


  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }

  tags = {
    Name        = "aadith-strapi-high-cpu-alarm"
    Environment = "production"
  }
}

# Alarm: High Memory Utilization
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "aadith-strapi-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 85   # 85% Memory
  alarm_description   = "This metric monitors ECS memory utilization"


  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }

  tags = {
    Name        = "aadith-strapi-high-memory-alarm"
    Environment = "production"
  }
}

# Alarm: Task Count (detect if no tasks running)
resource "aws_cloudwatch_metric_alarm" "ecs_task_count_low" {
  alarm_name          = "aadith-strapi-no-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60   # 1 minute
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when no tasks are running"

  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }

  tags = {
    Name        = "aadith-strapi-task-count-alarm"
    Environment = "production"
  }
}

resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "aadith-strapi-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      # CPU Utilization Widget
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", {
              stat = "Average"
              dimensions = {
                ClusterName = aws_ecs_cluster.strapi_cluster.name
                ServiceName = aws_ecs_service.strapi_service.name
              }
            }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 0
      },
      # Memory Utilization Widget
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", {
              stat = "Average"
              dimensions = {
                ClusterName = aws_ecs_cluster.strapi_cluster.name
                ServiceName = aws_ecs_service.strapi_service.name
              }
            }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Memory Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        width  = 12
        height = 6
        x      = 12
        y      = 0
      },
      # Running Task Count Widget
      {
        type = "metric"
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", {
              stat = "Average"
              dimensions = {
                ClusterName = aws_ecs_cluster.strapi_cluster.name
                ServiceName = aws_ecs_service.strapi_service.name
              }
            }],
            [".", "DesiredTaskCount", {
              stat = "Average"
              dimensions = {
                ClusterName = aws_ecs_cluster.strapi_cluster.name
                ServiceName = aws_ecs_service.strapi_service.name
              }
            }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Task Count (Running vs Desired)"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 6
      },
      # Network In Widget
      {
        type = "metric"
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "NetworkRxBytes", {
              stat = "Sum"
              dimensions = {
                ClusterName = aws_ecs_cluster.strapi_cluster.name
                ServiceName = aws_ecs_service.strapi_service.name
              }
            }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Network In (Bytes)"
        }
        width  = 12
        height = 6
        x      = 12
        y      = 6
      },
      # Network Out Widget
      {
        type = "metric"
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "NetworkTxBytes", {
              stat = "Sum"
              dimensions = {
                ClusterName = aws_ecs_cluster.strapi_cluster.name
                ServiceName = aws_ecs_service.strapi_service.name
              }
            }]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Network Out (Bytes)"
        }
        width  = 12
        height = 6
        x      = 0
        y      = 12
      }
    ]
  })
}

