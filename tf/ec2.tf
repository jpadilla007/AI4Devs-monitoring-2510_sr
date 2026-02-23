data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.backend_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = base64encode(templatefile("${path.module}/scripts/backend_user_data.sh", {
    DD_API_KEY = var.datadog_api_key
    DD_SITE    = var.datadog_site
    DD_ENV     = var.environment
  }))
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring = true

  tags = {
    Name        = "${var.project_name}-backend"
    Service     = "backend"
    Datadog     = "true"
    Environment = var.environment
  }

  depends_on = [aws_iam_role_policy_attachment.attach_s3_access_policy]
}

resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.frontend_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = base64encode(templatefile("${path.module}/scripts/frontend_user_data.sh", {
    DD_API_KEY = var.datadog_api_key
    DD_SITE    = var.datadog_site
    DD_ENV     = var.environment
  }))
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring = true

  tags = {
    Name        = "${var.project_name}-frontend"
    Service     = "frontend"
    Datadog     = "true"
    Environment = var.environment
  }

  depends_on = [aws_iam_role_policy_attachment.attach_s3_access_policy]
}
