data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ── User data: instala e inicia o SSM Agent ────────────────────────────────
# Necessário porque a AMI "al2023-ami-minimal" não vem com o agente
# pré-instalado, diferente da AMI completa do Amazon Linux 2023.
locals {
  ssm_agent_user_data = <<-EOF
    #!/bin/bash
    dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF
}

# ── Backend ──────────────────────────────────────────────────────────────────
resource "aws_instance" "backend" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id                   = var.private_subnet_id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    var.backend_sg_id
  ]

  iam_instance_profile = "LabInstanceProfile"
  user_data            = local.ssm_agent_user_data

  tags = {
    Name = "techstock-backend"
  }
}

# ── Frontend ─────────────────────────────────────────────────────────────────
resource "aws_instance" "frontend" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id                   = var.private_subnet_id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    var.frontend_sg_id
  ]

  iam_instance_profile = "LabInstanceProfile"
  user_data            = local.ssm_agent_user_data

  tags = {
    Name = "techstock-frontend"
  }
}

# ── Monitoring ───────────────────────────────────────────────────────────────
resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id                   = var.private_subnet_id
  associate_public_ip_address = false

  vpc_security_group_ids = [
    var.monitoring_sg_id
  ]

  iam_instance_profile = "LabInstanceProfile"
  user_data            = local.ssm_agent_user_data

  tags = {
    Name = "techstock-monitoring"
  }
}

# ── Target Group Attachments (ALB) ──────────────────────────────────────────
resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = var.tg_backend_arn
  target_id        = aws_instance.backend.id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = var.tg_frontend_arn
  target_id        = aws_instance.frontend.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "monitoring" {
  target_group_arn = var.tg_monitoring_arn
  target_id        = aws_instance.monitoring.id
  port             = 80
}

