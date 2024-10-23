################################################################################
# RDS
################################################################################
# Security group for RDS
resource "aws_security_group" "RDS_allow_rule" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.webserver_sg_id]

  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.namespace}-sg-database"
  }

}
 # Create RDS Subnet group
resource "aws_db_subnet_group" "RDS_subnet_grp" {
  
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_b_id]

}

# Create RDS instance
resource "aws_db_instance" "wordpressdb" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.RDS_subnet_grp.id
  vpc_security_group_ids = ["${aws_security_group.RDS_allow_rule.id}"]
  db_name                   = var.database_name
  username               = var.database_user
  password               = var.database_password
  skip_final_snapshot    = true

 # make sure rds manual password chnages is ignored
  lifecycle {
     ignore_changes = [password]
   }
}



# change USERDATA varible value after grabbing RDS endpoint info
data "template_file" "user_data" {
  template =  file("${path.module}/../install_wordpress.sh")
  vars = {
    db_username      = var.database_user
    db_user_password = var.database_password
    db_name          = var.database_name
    db_RDS           = aws_db_instance.wordpressdb.endpoint
    #WORDPRESS_DIR    = var.WORDPRESS_DIR
  }
}

################################################################################
# Clé SSH
################################################################################
#resource "aws_key_pair" "asmaa" {
 # key_name   = "asmaa"
# public_key = file(var.public_key_path)
  
 # tags = {
  #  Name = "${var.namespace}-keypair"
 # }
#}






