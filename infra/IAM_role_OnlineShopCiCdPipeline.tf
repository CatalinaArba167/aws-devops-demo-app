resource "aws_iam_role" "online_shop_ci_cd_pipeline" {
  name = "OnlineShopCiCdPipeline"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" 
        }
        Sid       = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.online_shop_ci_cd_pipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
