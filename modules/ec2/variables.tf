variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "Projet_AWS"
  type        = string
}
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}
variable "public_subnet_a_id" {
  type        = string
  description = "The ID of the first public subnet"
}

variable "public_subnet_b_id" {
  type        = string
  description = "The ID of the first public subnet"
}
variable "private_subnet_a_id" {
  description = "ID of the private subnet A"
  type        = string
}

variable "private_subnet_b_id" {
  description = "ID of the private subnet B"
  type        = string
}
################################################################################
# Variables RDS
################################################################################

