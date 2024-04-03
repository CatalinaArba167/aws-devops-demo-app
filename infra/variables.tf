variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "rds_instance_type" {
  description = "RDS instance type"
  default     = "db.t3.micro"
}

variable "elasticache_instance_type" {
  description = "ElastiCache instance type"
  default     = "cache.t3.micro"
}

variable "application_version" {
  description = "Version of the application to deploy"
  type        = string
  default     = "v0.0.1"
}

data "http" "myIp" {
  url = "http://icanhazip.com/"
}

variable "docker_image_tag" {
  description = "Docker image tag to pull from ECR and run on EC2 instances"
  default     = "4c8c8cb4fd631656cf072723d7da5d7e0a4de73f"
  type        = string
}

variable "ssh-key-pair" {
  type = string
  default = "online-shop-ssh-key-pair"
}

locals {
  ecs_cluster_name = aws_ecs_cluster.terraform_ecs_cluster.name
  rds_endpoint  = "jdbc:postgresql://${aws_db_instance.OnlineShopDatabase.endpoint}/postgres"
  radis_endpoint = aws_elasticache_cluster.terraform_online_shop_cache_cluster.cache_nodes[0].address
  jar_url = "https://github.com/msg-CareerPaths/aws-devops-demo-app/releases/download/${var.application_version}/online-shop-${var.application_version}.jar"
}