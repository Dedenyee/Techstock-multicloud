output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "backend_sg_id" {
  value = aws_security_group.backend.id
}

output "frontend_sg_id" {
  value = aws_security_group.frontend.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

