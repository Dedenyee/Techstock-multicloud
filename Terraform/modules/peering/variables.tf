variable "aws_vpc_id" {
  description = "ID da VPC principal (us-east-1)"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "CIDR da VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "peer_vpc_cidr" {
  description = "CIDR da VPC secundaria (simulando Azure)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "peer_region" {
  description = "Regiao da VPC secundaria"
  type        = string
  default     = "us-west-2"
}

variable "aws_route_table_id" {
  description = "ID da route table privada da VPC principal"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "Conteudo da chave publica SSH"
  type        = string
}
