output "database_hostname" {
  value = aws_db_instance.OnlineShopDatabase.address
}

output "database_port" {
  value = aws_db_instance.OnlineShopDatabase.port
}

output "cache_hostname" {
  value = aws_elasticache_cluster.terraform_online_shop_cache_cluster.cache_nodes[0].address
}

output "cache_port" {
  value = aws_elasticache_cluster.terraform_online_shop_cache_cluster.cache_nodes[0].port
}

output "application_base_url" {
  value = "http://${aws_lb.terraform_load_balancer.dns_name}"
}

output "ecr_repo_url" {
  value = aws_ecr_repository.terraform_ecr_repo.repository_url
}

