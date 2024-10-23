variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "Projet_AWS"
  type        = string
} 
variable "vpc_id" {
  description = "The VPC ID where the RDS instance will be created."
  type        = string
}

# RDS Configuration
variable "instance_class" {
  description = "Classe d'instance pour RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  description = "Nom de la base de données RDS"
  type        = string
}

variable "database_user" {
  description = "Nom d'utilisateur de la base de données RDS"
  type        = string
}

variable "database_password" {
  description = "Mot de passe de la base de données RDS"
  type        = string
  sensitive   = true
}
#variable "WORDPRESS_DIR" {
   # description = "Répertoire du code WordPress"
 #   default     = "/var/www/html"  # ou le chemin de votre choix
#}

variable "private_subnet_a_id" {
  description = "ID of the private subnet A"
  type        = string
}

variable "private_subnet_b_id" {
  description = "ID of the private subnet B"
  type        = string
}
variable "webserver_sg_id" {
  description = "The security group ID for the web server."
  type        = string
}

