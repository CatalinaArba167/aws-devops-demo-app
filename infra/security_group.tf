resource "aws_security_group" "terraform_online_shop_backend_security_group" {
  name        = "terraform_online_shop_backend_security_group"
  description = "Allows SSH traffic from your IP and allow any TPC traffic over port 8080"
  vpc_id      = aws_vpc.terraform_vpc.id


   # SSH access from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] 
    description = "Allows SSH traffic from your IP"
  }

  # Allow all TCP traffic on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow any TPC traffic over port 8080"
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "terraform_online_shop_backend_security_group"
  }
}


resource "aws_security_group" "terraform_online_shop_ecs_security_group" {
  name        = "terraform_online_shop_ecs_security_group"
  description = "Allows all inbound and outbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_sg_ingress_all_internal" {
  security_group_id = aws_security_group.terraform_online_shop_ecs_security_group.id
  cidr_ipv4         = aws_vpc.terraform_vpc.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "ecs_sg_egress_all" {
  security_group_id = aws_security_group.terraform_online_shop_ecs_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
