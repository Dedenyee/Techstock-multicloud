terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

########################
# VPC
########################

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
}

########################
# SECURITY GROUPS
########################

module "security_groups" {
  source = "./modules/security-groups"

  vpc_id = module.vpc.vpc_id
}

########################
# RDS
########################

module "rds" {
  source = "./modules/rds"

  db_password = var.db_password

  private_subnets = [
    module.vpc.private_subnet_a_id,
    module.vpc.private_subnet_b_id
  ]

  rds_sg_id = module.security_groups.rds_sg_id
}

########################
# ALB
########################

module "alb" {
  source = "./modules/alb"

  vpc_id = module.vpc.vpc_id

  public_subnets = [
    module.vpc.public_subnet_a_id,
    module.vpc.public_subnet_b_id
  ]

  alb_sg_id = module.security_groups.alb_sg_id
}

########################
# EC2
########################

module "ec2" {
  source = "./modules/ec2"

  private_subnet_id = module.vpc.private_subnet_a_id

  backend_sg_id    = module.security_groups.backend_sg_id
  frontend_sg_id   = module.security_groups.frontend_sg_id
  monitoring_sg_id = module.security_groups.monitoring_sg_id

  tg_backend_arn    = module.alb.backend_tg_arn
  tg_frontend_arn   = module.alb.frontend_tg_arn
  tg_monitoring_arn = module.alb.monitoring_tg_arn
}

module "peering" {
  source               = "./modules/peering"
  aws_vpc_id           = module.vpc.vpc_id
  aws_vpc_cidr         = "10.0.0.0/16"
  aws_route_table_id   = module.vpc.private_route_table_id
  admin_ssh_public_key = var.admin_ssh_public_key
}
