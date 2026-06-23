output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}

output "frontend_private_ip" {
  value = aws_instance.frontend.private_ip
}

output "monitoring_private_ip" {
  value = aws_instance.monitoring.private_ip
}

output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "frontend_instance_id" {
  value = aws_instance.frontend.id
}

output "monitoring_instance_id" {
  value = aws_instance.monitoring.id
}
