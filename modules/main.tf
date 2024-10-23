terraform {
  required_providers {
      aws = {
            source  = "hashicorp/aws"
              version = "~> 5.0"
              }
                }
            }
            # la région aws ou nous voulons déployer nos différentes ressources
provider "aws" {
    region = "eu-west-3"
    access_key = "*********************" # la clé d'acces crée pour l'utilisateur qui sera utilisé par terraform
    secret_key = "*************************" # la clé sécrète crée pour l'utilisateur qui sera utilisé par terraform
            }

# appel du modules networking
module "networking" {
  source    = "./networking"
  namespace = var.namespace
}

module "ec2" {
  source = "./ec2"

  namespace               = var.namespace
  vpc_id                  = module.networking.vpc_id
  public_subnet_a_id      = module.networking.public_subnet_a_id
  public_subnet_b_id      = module.networking.public_subnet_b_id
  private_subnet_a_id     = module.networking.private_subnet_a_id
  private_subnet_b_id     = module.networking.private_subnet_b_id
  
  
}


module "rds" {
  source                  = "./rds"
  namespace               = var.namespace
  vpc_id                  = module.networking.vpc_id
  instance_class          = "db.t3.micro"
  database_name           = "wordpressdb"
  database_user           = "asmaa123"
  database_password       = "datascientest2024"
  private_subnet_a_id     = module.networking.private_subnet_a_id 
  private_subnet_b_id     = module.networking.private_subnet_b_id 
  webserver_sg_id         =module.ec2.webserver_sg_id
  
}

