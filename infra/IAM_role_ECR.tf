resource "aws_iam_policy" "ECR_push_policy" {
  name        = "ECR_push_policy"
  description = "Policy that allows pushing images to ECR"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": [
                  "*"
               #"arn:aws:ecr:us-east-1:767397826387:repository/terraform_ecr_repo"
            ]

        }
    ]
})
}

resource "aws_iam_role" "ECR_push_role" {
  name = "ECR_push_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::767397826387:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:CatalinaArba167/aws-devops-demo-app:*"
          }
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ECR_push_attach" {
  role       = aws_iam_role.ECR_push_role.name
  policy_arn = aws_iam_policy.ECR_push_policy.arn
}

