#It's a logical grouping of ec2 where your containers will run
# ECS Cluster
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "aadith-strapi-cluster"

  setting {
    name  = "containerInsights" # metrics about your containers
    value = "enabled"
  }

  tags = {
    Name = "aadith-strapi-cluster"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/aadithstrapi"
  retention_in_days = 7

  tags = {
    Name = "aadith-strapi-logs"
  }
}


resource "aws_ecs_cluster_capacity_providers" "strapi_spot" {
  cluster_name = aws_ecs_cluster.strapi_cluster.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}


#A Task Definition in AWS ECS is basically the blueprint that tells ECS how to run your container.
# ECS Task Definition
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "aadith-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # launch env
  cpu                      = "2048"  # 2 vCPU
  memory                   = "4096"  # 4 GB
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.docker_image
      essential = true

      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "HOST"
          value = "0.0.0.0"
        },
        {
          name  = "PORT"
          value = "1337"
        },
        {
          name  = "DATABASE_CLIENT"
          value = "postgres"
        },
        {
          name  = "DATABASE_HOST"
          value = aws_db_instance.aadith_strapi_postgres.address
        },
        {
          name  = "DATABASE_PORT"
          value = tostring(aws_db_instance.aadith_strapi_postgres.port)
        },
        {
          name  = "DATABASE_NAME"
          value = var.db_name
        },
        {
          name  = "DATABASE_USERNAME"
          value = var.db_username
        },
        {
          name  = "DATABASE_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DATABASE_SSL"
          value = "true"
        },
        {
          name  = "DATABASE_SSL_REJECT_UNAUTHORIZED"
          value = "false"
        },
        {
          name  = "APP_KEYS"
          value = var.app_keys
        },
        {
          name  = "API_TOKEN_SALT"
          value = var.api_token_salt
        },
        {
          name  = "ADMIN_JWT_SECRET"
          value = var.admin_jwt_secret
        },
        {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        }
      ]

      logConfiguration = {
        logDriver = "awslogs" #ECS will send stdout / stderr of the container to CloudWatch Logs.
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs" # ecs/TaskID
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:1337/_health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 120
      }
    }
  ])

  tags = {
    Name = "aadith-strapi-task"
  }
}

# An ECS Service ensures a specified number of tasks are running at all times.
# It launches tasks based on your task definition and keeps that number healthy and steady.
# ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "aadith-strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 2

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn  # Links to Target Group
    container_name   = "strapi"                            # Container name from task definition
    container_port   = 1337                                # Port Strapi listens on
  }

  depends_on = [
    aws_ecs_cluster_capacity_providers.strapi_spot,
    aws_lb_listener.strapi_listener,
    aws_db_instance.aadith_strapi_postgres
  ]

  tags = {
    Name = "aadith-strapi-service"
  }
}
