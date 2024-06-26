resource "aws_launch_template" "terraform_launch_template" {
  name          = "TerraformLaunchTemplate"
  image_id      = "ami-07761f3ae34c4478d"
  key_name      = var.ssh-key-pair
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr_role_profile.name
  }

  user_data = base64encode(templatefile("./userdata_ECR.tftpl", {
    tag = var.docker_image_tag

  }))
  vpc_security_group_ids = [aws_security_group.terraform_online_shop_backend_security_group.id]
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}


resource "aws_launch_template" "terraform_launch_template_for_ecs" {
  name          = "TerraformLaunchTemplateForECS"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  key_name      = var.ssh-key-pair
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_container_service_for_ec2_role_profile.name
  }

  user_data = base64encode(templatefile("./userdata_ECS.tftpl", {
    terraform_ecs_cluster_name = local.ecs_cluster_name
  }))

  vpc_security_group_ids = [aws_security_group.terraform_online_shop_backend_security_group.id]
}