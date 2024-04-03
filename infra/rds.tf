resource "aws_security_group" "terraform_online_shop_database_security_group" {
  name        = "terraform_online_shop_database_security_group"
  description = "Security group for online shop database"
  vpc_id      = aws_vpc.terraform_vpc.id 

  tags = {
    Name = "terraform_online_shop_database_security_group"
  }
}

# Ingress rule to allow tcp traffic from backend security group
resource "aws_vpc_security_group_ingress_rule" "allow_tcp_5432" {
  security_group_id            = aws_security_group.terraform_online_shop_database_security_group.id
  referenced_security_group_id = aws_security_group.terraform_online_shop_backend_security_group.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "rds_sg_ingress_all" {
  security_group_id = aws_security_group.terraform_online_shop_database_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.terraform_online_shop_database_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_db_instance" "OnlineShopDatabase" {
  identifier           = "online-shop-database"
  db_name              = "OnlineShopDatabase"
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = var.rds_instance_type
  allocated_storage    = 20
  storage_type         = "gp2"
  username             = "postgres"
  password             = "postgres"
  publicly_accessible  = false
  multi_az             = false
  apply_immediately    = true
  vpc_security_group_ids = [aws_security_group.terraform_online_shop_database_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_private_subnets.name 

  lifecycle {
    #prevent_destroy=true
  }
  
}

resource "aws_db_subnet_group" "db_private_subnets" {
  name       = "terraform private subnests"
  subnet_ids = [aws_subnet.private_subnet_1.id,aws_subnet.private_subnet_2.id]

  tags = {
    Name = "My terraform DB subnet group"
  }
}