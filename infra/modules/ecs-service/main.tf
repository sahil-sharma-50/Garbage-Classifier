# IAM Role for ECS Task Execution
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# CloudWatch Log Group for ECS Task
# resource "aws_cloudwatch_log_group" "logs" {
#   name              = "/ecs/${var.app_name}-task"
#   retention_in_days = 30
# }

data "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/${var.app_name}-task"
  retention_in_days = 30
}

# ECS Task Definition for frontend
resource "aws_ecs_task_definition" "task" {
  # depends_on = [
  #   aws_cloudwatch_log_group.logs
  # ]
  family                    = "${var.app_name}-task"
  requires_compatibilities  = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  network_mode              = "awsvpc"
  cpu    = "1024"
  memory = "3072"
  execution_role_arn        = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-container"
      image     = var.docker_image_uri
      essential = true
      cpu       = 1024
      memory    = 3072
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = data.aws_cloudwatch_log_group.logs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          # "awslogs-create-group"  = "true"
        }
      }
    },
  ])
}


# Application Load Balancer
# resource "aws_lb" "alb" {
#   name               = "${var.app_name}-alb"
#   load_balancer_type = "application"
#   subnets            = var.subnets
#   # security_groups    = [aws_security_group.alb_sg.id]
#   security_groups    = [var.default_sg_id]
# }

data "aws_lb" "alb" {
  name = "${var.app_name}-alb"
}

# Target Group for ECS
# resource "aws_lb_target_group" "tg" {
#   name        = "${var.app_name}-tg"
#   port        = var.container_port
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = var.vpc_id

#   health_check {
#     path                = "/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     matcher             = "200-399"
#   }
# }

data "aws_lb_target_group" "tg" {
  name = "${var.app_name}-tg"
}

# Listener for ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.tg.arn
  }
}


# ECS Service
resource "aws_ecs_service" "service" {
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  name            = "${var.app_name}-service"
  cluster         = var.cluster_id
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = var.subnets
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_task_definition.task,
    aws_lb_listener.listener
  ]

  load_balancer {
    target_group_arn = data.aws_lb_target_group.tg.arn
    container_name   = "${var.app_name}-container"
    container_port   = var.container_port
  }
}
