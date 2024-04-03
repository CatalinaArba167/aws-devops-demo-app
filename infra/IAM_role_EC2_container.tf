resource "aws_iam_role" "ec2_container_service_for_ec2_role" {
  name = "ec2_container_service_for_ec2_role"

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

resource "aws_iam_role_policy_attachment" "ec2_container_service_for_ec2_role_attachment" {
  role       = aws_iam_role.ec2_container_service_for_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "ec2_container_service_for_ec2_role_profile" {
  name = "ec2_container_service_for_ec2_role_profile"
  role = aws_iam_role.ec2_container_service_for_ec2_role.name
}
