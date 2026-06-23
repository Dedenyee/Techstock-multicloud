output "peer_vpc_id" {
  value = aws_vpc.peer.id
}

output "monitoring_private_ip" {
  value       = aws_instance.monitoring.private_ip
  description = "IP privado da VM de monitoring — use para testar ping via peering"
}

output "monitoring_public_ip" {
  value       = aws_instance.monitoring.public_ip
  description = "IP publico temporario — apenas para validacao inicial"
}

output "peering_connection_id" {
  value = aws_vpc_peering_connection.main.id
}
