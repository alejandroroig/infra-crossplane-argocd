# variables.tf
# Región de AWS donde desplegar la infraestructura (por defecto us-east-1)

variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type = string
  default = "us-east-1"
}

# Prefijo para nombres de recursos (por ejemplo, usar tus iniciales oproyecto)
variable "project_name" {
  description = "Prefijo identificador para nombres de recursos en AWS"
  type = string
  default = "gitops"
}

# Tipo de instancia EC2
variable "instance_type" {
  description = "Tipo de instancia EC2 para los servidores web"
  type = string
  default = "t3.medium"
}

