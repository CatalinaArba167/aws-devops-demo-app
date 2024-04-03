resource "aws_ecs_cluster" "terraform_ecs_cluster" {
  name = "terraform_ecs_cluster"
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_logs.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/online-shop-task"
}


resource "aws_ecs_task_definition" "terraform-ecs-task" {
  family                   = "online-shop-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn


  container_definitions = jsonencode([{
    name         = "my-first-container",
    image        = "${aws_ecr_repository.terraform_ecr_repo.repository_url}:${var.docker_image_tag}",
    essential    = true,
    portMappings = [{
      containerPort = 8080,
      hostPort      = 8080
    }],
     logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name,
        "awslogs-region"        = "us-east-1",
        "awslogs-stream-prefix" = "ecs"
      }
    }
    secrets = [
      {
        name      = "SPRING_DATASOURCE_PASSWORD",
        valueFrom = "arn:aws:secretsmanager:us-east-1:767397826387:secret:MyFirstSecret:SPRING_DATASOURCE_PASSWORD::"
      }
    ]
    environment  = [
      { name = "SPRING_DATASOURCE_USERNAME", value = "postgres" },
      { name = "SPRING_DATASOURCE_URL", value = local.rds_endpoint },
      { name = "SPRING_REDIS_HOST", value = local.radis_endpoint },  
      { name = "SPRING_REDIS_PORT", value = "6379" },
      { name = "SPRING_SESSION_STORETYPE", value = "redis" },
      { name = "SPRING_SESSION_REDIS_CONFIGUREACTION", value = "none" }
    ],
    cpu          = 256  
    memory       = 512   
  }])
}





resource "aws_ecs_service" "terraform_ecs_service" {
  name="terraform_ecs_service"
  cluster = aws_ecs_cluster.terraform_ecs_cluster.id
  task_definition = aws_ecs_task_definition.terraform-ecs-task.arn
  desired_count = 1
  force_new_deployment = true

  
  load_balancer {
    target_group_arn = aws_lb_target_group.terraform_target_group_for_ecs.arn
    container_name = "my-first-container"
    container_port = 8080
  }

   network_configuration {
    subnets = [aws_subnet.private_subnet_1.id,aws_subnet.private_subnet_2.id,aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    #security_groups = [ aws_security_group.terraform_online_shop_ecs_security_group.id]
   }
   
   capacity_provider_strategy {
     capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
     weight = 100
   }
}


resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "shop-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.terraform_auto_scaling_group.arn

    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}


resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.terraform_ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}