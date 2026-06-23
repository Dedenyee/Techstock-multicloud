# ─────────────────────────────────────────────────────────────
# Provider secundário (us-west-2)
# ─────────────────────────────────────────────────────────────

provider "aws" {
  alias  = "peer"
  region = var.peer_region
}

# ─────────────────────────────────────────────────────────────
# VPC Secundária (simulação multi-cloud)
# ─────────────────────────────────────────────────────────────

resource "aws_vpc" "peer" {
  provider             = aws.peer
  cidr_block           = var.peer_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "techstock-simulated-remote-vpc"
  }
}

# ─────────────────────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────────────────────

resource "aws_internet_gateway" "peer" {
  provider = aws.peer
  vpc_id   = aws_vpc.peer.id

  tags = {
    Name = "techstock-peer-igw"
  }
}

# ─────────────────────────────────────────────────────────────
# Subnet Pública
# 10.1.0.0/24
# ─────────────────────────────────────────────────────────────

resource "aws_subnet" "peer_public" {
  provider = aws.peer

  vpc_id                  = aws_vpc.peer.id
  cidr_block              = "10.1.0.0/24"
  availability_zone       = "${var.peer_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "techstock-peer-public-subnet"
  }
}

# ─────────────────────────────────────────────────────────────
# Subnet Privada
# 10.1.1.0/24
# ─────────────────────────────────────────────────────────────

resource "aws_subnet" "peer_private" {
  provider = aws.peer

  vpc_id            = aws_vpc.peer.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.peer_region}a"

  tags = {
    Name = "techstock-peer-private-subnet"
  }
}

# ─────────────────────────────────────────────────────────────
# Elastic IP para NAT Gateway
# ─────────────────────────────────────────────────────────────

resource "aws_eip" "nat" {
  provider = aws.peer
  domain   = "vpc"

  tags = {
    Name = "techstock-peer-nat-eip"
  }
}

# ─────────────────────────────────────────────────────────────
# NAT Gateway
# ─────────────────────────────────────────────────────────────

resource "aws_nat_gateway" "peer" {
  provider = aws.peer

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.peer_public.id

  depends_on = [
    aws_internet_gateway.peer
  ]

  tags = {
    Name = "techstock-peer-nat"
  }
}

# ─────────────────────────────────────────────────────────────
# Route Table Pública
# ─────────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  provider = aws.peer

  vpc_id = aws_vpc.peer.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.peer.id
  }

  route {
    cidr_block                = var.aws_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "techstock-peer-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  provider = aws.peer

  subnet_id      = aws_subnet.peer_public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────────────────────────────────────────────────────
# Route Table Privada
# ─────────────────────────────────────────────────────────────

resource "aws_route_table" "private" {
  provider = aws.peer

  vpc_id = aws_vpc.peer.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.peer.id
  }

  route {
    cidr_block                = var.aws_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  }

  tags = {
    Name = "techstock-peer-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  provider = aws.peer

  subnet_id      = aws_subnet.peer_private.id
  route_table_id = aws_route_table.private.id
}

# ─────────────────────────────────────────────────────────────
# VPC Peering
# ─────────────────────────────────────────────────────────────

resource "aws_vpc_peering_connection" "main" {
  vpc_id      = var.aws_vpc_id
  peer_vpc_id = aws_vpc.peer.id
  peer_region = var.peer_region

  auto_accept = false

  tags = {
    Name = "techstock-vpc-peering-multicloud-sim"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider = aws.peer

  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
  auto_accept               = true

  tags = {
    Name = "techstock-peering-accepter"
  }
}

resource "aws_route" "main_to_peer" {
  route_table_id            = var.aws_route_table_id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# ─────────────────────────────────────────────────────────────
# Security Group
# ─────────────────────────────────────────────────────────────

resource "aws_security_group" "monitoring" {
  provider = aws.peer

  name        = "techstock-monitoring-sg"
  description = "Monitoring via VPC Peering"
  vpc_id      = aws_vpc.peer.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techstock-monitoring-sg"
  }
}

# ─────────────────────────────────────────────────────────────
# Amazon Linux
# ─────────────────────────────────────────────────────────────

data "aws_ami" "amazon_linux_peer" {
  provider    = aws.peer
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ─────────────────────────────────────────────────────────────
# Key Pair
# ─────────────────────────────────────────────────────────────

resource "aws_key_pair" "monitoring" {
  provider = aws.peer

  key_name   = "techstock-monitoring-key"
  public_key = var.admin_ssh_public_key
}

# ─────────────────────────────────────────────────────────────
# IAM para SSM
# ─────────────────────────────────────────────────────────────




# ─────────────────────────────────────────────────────────────
# EC2 Monitoring Privada
# ─────────────────────────────────────────────────────────────

resource "aws_instance" "monitoring" {
  provider = aws.peer

  ami           = data.aws_ami.amazon_linux_peer.id
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.peer_private.id
  vpc_security_group_ids = [aws_security_group.monitoring.id]

  associate_public_ip_address = false

  iam_instance_profile = "LabInstanceProfile"

  key_name = aws_key_pair.monitoring.key_name

  user_data = <<-USERDATA
#!/bin/bash

dnf update -y

dnf install -y wget curl unzip tar git

dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
USERDATA

  tags = {
    Name = "techstock-monitoring"
  }
}
