variable "private_subnet_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}

variable "frontend_sg_id" {
  type = string
}

variable "monitoring_sg_id" {
  type = string
}

variable "tg_backend_arn" {
  type = string
}

variable "tg_frontend_arn" {
  type = string
}

variable "tg_monitoring_arn" {
  type = string
}
