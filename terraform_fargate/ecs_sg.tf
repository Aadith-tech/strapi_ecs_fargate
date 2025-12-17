resource "aws_security_group" "ecs_tasks_sg" {
  name        = "aadith-strapi-ecs-tasks-sg"
  description = "Security group for Strapi ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Allow traffic to Strapi (from ALB or the internet)"
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aadith-strapi-ecs-tasks-sg"
  }
}

