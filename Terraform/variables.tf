variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "db_password" {
  sensitive = true
}

variable "grafana_password" {
  default = "REMOVED"
}

variable "admin_ssh_public_key" {
  description = "Chave publica SSH para acesso a VM de monitoring"
  type        = string
}
