resource "aws_autoscaling_group" "terraform_auto_scaling_group" {
  name = "TerraformAutoScalingGroup"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  launch_template {
    id      = aws_launch_template.terraform_launch_template_for_ecs.id
    version = "$Latest"
  }

}