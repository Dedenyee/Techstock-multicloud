output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "backend_private_ip" {
  value = module.ec2.backend_private_ip
}

output "frontend_private_ip" {
  value = module.ec2.frontend_private_ip
}

output "monitoring_private_ip" {
  value = module.ec2.monitoring_private_ip
}

output "private_route_table_id" {
  description = "ID da route table privada (VPC principal)"
  value       = module.vpc.private_route_table_id
}
