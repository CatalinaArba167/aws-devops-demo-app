
resource "aws_security_group" "terraform_online_shop_cache_security_group" {
  name        = "terraform_online_shop_cache_security_group"
  description = "Security group for ElastiCache Redis cluster"
  vpc_id      = aws_vpc.terraform_vpc.id

  tags={
    name="Terraform online shop redis security group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_6379" {
  security_group_id            = aws_security_group.terraform_online_shop_cache_security_group.id
  referenced_security_group_id = aws_security_group.terraform_online_shop_backend_security_group.id
  from_port                    = 6379
  ip_protocol                  = "tcp"
  to_port                      = 6379
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_ipv4_to_redis" {
  security_group_id = aws_security_group.terraform_online_shop_cache_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_to_redis" {
  security_group_id = aws_security_group.terraform_online_shop_cache_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_elasticache_subnet_group" "terraform-online-shop-cache-subnet-group" {
  name       = "terraform-online-shop-cache-subnet-group"
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id] 

  tags = {
    Name = "Online Shop Cache Subnet Group"
  }
}


resource "aws_elasticache_cluster" "terraform_online_shop_cache_cluster" {
  cluster_id           = "terraform-online-shop-cache-cluster"
  engine               = "redis"
  node_type            = var.elasticache_instance_type
  engine_version       = "7.1" 
  num_cache_nodes      = 1 
  apply_immediately    =true
  subnet_group_name    = aws_elasticache_subnet_group.terraform-online-shop-cache-subnet-group.name
  security_group_ids   = [aws_security_group.terraform_online_shop_cache_security_group.id]

  tags = {
    Name = "Online Shop Cache Cluster"
  }
}
