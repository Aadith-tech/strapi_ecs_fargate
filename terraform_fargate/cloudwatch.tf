# Alarm: High CPU Utilization
#Average ECS CPU utilization is greater than 80% for 2 consecutive 5-minute periods
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "aadith-strapi-high-cpu"
  comparison_operator = "GreaterThanThreshold" #when the alarm should trigger.
  evaluation_periods  = 2  #Number of consecutive periods the condition must be met.
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

  }
}

# Alarm: Task Count
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

  }
}

resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "aadith-strapi-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              "${aws_ecs_cluster.strapi_cluster.name}",
              "ServiceName",
              "${aws_ecs_service.strapi_service.name}",
              { stat = "Average" }
            ]
          ]
          period = 300
          region = var.aws_region
          title  = "ECS CPU Utilization"
          yAxis = { left = { min = 0, max = 100 } }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 0
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              "${aws_ecs_cluster.strapi_cluster.name}",
              "ServiceName",
              "${aws_ecs_service.strapi_service.name}",
              { stat = "Average" }
            ]
          ]
          period = 300
          region = var.aws_region
          title  = "ECS Memory Utilization"
          yAxis = { left = { min = 0, max = 100 } }
        }
        width  = 12
        height = 6
        x      = 12
        y      = 0
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [
              "ECS/ContainerInsights",
              "RunningTaskCount",
              "ClusterName",
              "${aws_ecs_cluster.strapi_cluster.name}",
              "ServiceName",
              "${aws_ecs_service.strapi_service.name}",
              { stat = "Average" }
            ],
            [
              "ECS/ContainerInsights",
              "DesiredTaskCount",
              "ClusterName",
              "${aws_ecs_cluster.strapi_cluster.name}",
              "ServiceName",
              "${aws_ecs_service.strapi_service.name}",
              { stat = "Average" }
            ]
          ]
          period = 300
          region = var.aws_region
          title  = "Task Count (Running vs Desired)"
          yAxis = { left = { min = 0 } }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 6
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [
              "ECS/ContainerInsights",
              "NetworkRxBytes",
              "ClusterName",
              "${aws_ecs_cluster.strapi_cluster.name}",
              "ServiceName",
              "${aws_ecs_service.strapi_service.name}",
              { stat = "Sum" }
            ]
          ]
          period = 300
          region = var.aws_region
          title  = "Network In (Bytes)"
          yAxis = { left = { min = 0 } }
        }
        width  = 12
        height = 6
        x      = 12
        y      = 6
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [
              "ECS/ContainerInsights",
              "NetworkTxBytes",
              "ClusterName",
              "${aws_ecs_cluster.strapi_cluster.name}",
              "ServiceName",
              "${aws_ecs_service.strapi_service.name}",
              { stat = "Sum" }
            ]
          ]
          period = 300
          region = var.aws_region
          title  = "Network Out (Bytes)"
          yAxis = { left = { min = 0 } }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 12
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              "${aws_lb.strapi_alb.arn_suffix}",
              "TargetGroup",
              "${aws_lb_target_group.strapi_tg.arn_suffix}",
              { stat = "Average" }
            ]
          ]
          period = 300
          region = var.aws_region
          title  = "ALB Response Time (seconds)"
          yAxis = { left = { min = 0 } }
        }
        width  = 12
        height = 6
        x      = 0
        y      = 18
      }
    ]
  })
}


