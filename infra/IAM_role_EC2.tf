resource "aws_iam_policy" "EC2_pull_policy" {
  name        = "EC2_pull_policy"
  description = "Policy that allows pulling images from ECR"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ],
        "Resource": [
            "*"
          #  "arn:aws:ecr:us-east-1:767397826387:repository/terraform_ecr_repo"
        ]

      }
    ]
  })
}

resource "aws_iam_role" "EC2_pull_role" {
  name = "ec2_pull_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "EC2_pull_attach" {
  role       = aws_iam_role.EC2_pull_role.name
  policy_arn = aws_iam_policy.EC2_pull_policy.arn
}


resource "aws_iam_instance_profile" "ec2_ecr_role_profile" {
  name = "ec2-ecr-role-profile"
  role = aws_iam_role.EC2_pull_role.name
}
