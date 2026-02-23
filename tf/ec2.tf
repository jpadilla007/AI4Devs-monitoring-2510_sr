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
    timestamp  = timestamp()
    DD_API_KEY = var.datadog_api_key
    DD_SITE    = var.datadog_site
    DD_ENV     = var.environment
  }))
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  
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
    timestamp  = timestamp()
    DD_API_KEY = var.datadog_api_key
    DD_SITE    = var.datadog_site
    DD_ENV     = var.environment
  }))
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  
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

output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "backend_instance_public_ip" {
  value = aws_instance.backend.public_ip
}

output "frontend_instance_id" {
  value = aws_instance.frontend.id
}

output "frontend_instance_public_ip" {
  value = aws_instance.frontend.public_ip
}
