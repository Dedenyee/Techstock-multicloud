variable "db_password" {
  sensitive = true
}

variable "private_subnets" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}
