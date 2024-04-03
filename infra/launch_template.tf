# resource "aws_instance" "terraform_instance" {
#   ami           = "ami-07761f3ae34c4478d" 
#   instance_type = "t2.micro"
#   key_name      = "MyFirstSSHKeyPair"
#   subnet_id     = aws_subnet.public_subnet_1.id

#   user_data = templatefile("/userdata.tftpl",{})

#   vpc_security_group_ids = [aws_security_group.terraform_online_shop_backend_security_group.id]

#   tags = {
#     Name = "TerraformInstance"
#   }

#   associate_public_ip_address = true
# }

resource "aws_key_pair" "terraform-ssh-key" {
  key_name   = var.ssh_key_name
  public_key = ""

  lifecycle {
    #prevent_destroy = true
    
  }
}


resource "aws_launch_template" "terraform_launch_template" {
  name = "TerraformLaunchTemplate"
  image_id        = "ami-07761f3ae34c4478d" 
  key_name        = aws_key_pair.terraform-ssh-key.key_name
  instance_type   = var.ec2_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr_role_profile.name
  }

  user_data       =  base64encode(templatefile("/userdata_ECR.tftpl",{
    # rds_endpoint  = local.rds_endpoint,
    # radis_endpoint= local.radis_endpoint,
    # jar_url       =  local.jar_url
    tag             = var.docker_image_tag

  }))
  vpc_security_group_ids = [aws_security_group.terraform_online_shop_backend_security_group.id]
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}


resource "aws_launch_template" "terraform_launch_template_for_ecs" {
  name            = "TerraformLaunchTemplateForECS"
  image_id        = data.aws_ssm_parameter.ecs_optimized_ami.value
  key_name        = aws_key_pair.terraform-ssh-key.key_name
  instance_type   = var.ec2_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_container_service_for_ec2_role_profile.name
  }

  user_data       =  base64encode(templatefile("/userdata_ECS.tftpl",{
    terraform_ecs_cluster_name = local.ecs_cluster_name
  }))

  vpc_security_group_ids = [aws_security_group.terraform_online_shop_backend_security_group.id]
}