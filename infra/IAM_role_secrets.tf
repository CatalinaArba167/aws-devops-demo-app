resource "aws_iam_policy" "secret_policy" {
  name = "secret_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:us-east-1:767397826387:secret:MyFirstSecret-*"
        ]
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "secret_push_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secret_policy.arn
}
