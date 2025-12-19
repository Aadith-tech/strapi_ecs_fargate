
# Application Load Balancer
resource "aws_lb" "strapi_alb" {
  name               = "aadith-strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.subnets

  enable_deletion_protection = false

  tags = {
    Name = "aadith-strapi-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "strapi_tg" {
  name        = "aadith-strapi-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/_health"
    protocol            = "HTTP"
    matcher             = "200,204"
  }

  deregistration_delay = 30

  tags = {
    Name = "aadith-strapi-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "strapi_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }

  tags = {
    Name = "aadith-strapi-listener"
  }
}