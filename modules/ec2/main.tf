################################################################################
# EC2 security group pour ASG et ALB
###############################################################################
#Créez une Data Source aws_ami pour sélectionner l'ami disponible dans votre région
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security group for ALB
resource "aws_security_group" "sg-alb" {
  vpc_id        = var.vpc_id
  name          = "lb-sg"
  description   = "security group for the load balancer"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.namespace}-sg-alb"
  }
}

# Security group for ASG instances
resource "aws_security_group" "sg-instances" {
  vpc_id            = var.vpc_id
  name              = "wordpress-sg"
  description       = "security group for the ASG instances"
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-alb.id]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-alb.id]
  }

  tags = {
    Name = "${var.namespace}-sg-webserver"
  }
}
################################################################################
# AWS autoscaling group
###############################################################################
# ASG launch configuration
resource "aws_launch_template" "my_launch_template" {
  name          = "my-launch-template"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name      = "asmaa"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg-instances.id]
  }
  
  block_device_mappings {
    device_name = "/dev/xvdb"  # Device pour AZ1
    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }

  block_device_mappings {
    device_name = "/dev/xvdc"  # Device pour AZ2
    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }

  user_data = filebase64("${path.module}/../install_wordpress.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.namespace}-launch-template"
    }
  }
}
# ASG
resource "aws_autoscaling_group" "my-autoscaling" {
  name                      = "autoscaling"
  vpc_zone_identifier       = [var.private_subnet_a_id, var.private_subnet_b_id]
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.my-alb-target-group.arn]
  force_delete              = true

  # Use Launch Template instead of Launch Configuration
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  tag {
    key                     = "Name"
    value                   = "ASG_Instance"
    propagate_at_launch     = true
  }
}
################################################################################
# application load balancer
###############################################################################

resource "aws_lb" "my-alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets         = [var.public_subnet_a_id, var.public_subnet_b_id]  # Correction ici
  security_groups    = [aws_security_group.sg-alb.id]

  tags = {
    Name = "${var.namespace}-my-alb-tf"
  }
}


# ALB Targets
resource "aws_lb_target_group" "my-alb-target-group" {
  name     = "tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
}

# ALB listener
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn  = "${aws_lb.my-alb.arn}"
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my-alb-target-group.arn}"
  }
}

################################################################################
# Bastion host avec  autoscaling Group
###############################################################################
# Security Group pour Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-bastion_sg"
  }
}

# Launch Template pour Bastion Host
resource "aws_launch_template" "bastion_launch_template" {
  name          = "bastion-launch-template"
  image_id      = data.aws_ami.amazon-linux-2.id  # AMI Amazon Linux 2
  instance_type = "t2.micro"  # Taille de l'instance Bastion
  key_name      = "asmaa"  # Clé SSH pour accès Bastion

  network_interfaces {
    associate_public_ip_address = true  # Le Bastion Host a besoin d'une IP publique
    security_groups             = [aws_security_group.bastion_sg.id]  # Associe le Security Group
    subnet_id                   = var.public_subnet_a_id  # Déploie dans un sous-réseau public
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.namespace}-bastion"
    }
  }
}

# Auto Scaling Group pour Bastion Host
resource "aws_autoscaling_group" "bastion_asg" {
  name                      = "bastion-asg"
  vpc_zone_identifier       = [var.public_subnet_a_id]  # Déploie dans un sous-réseau public
  min_size                  = 1  # Minimum 1 Bastion Host
  desired_capacity          = 1  # Capacité désirée de 1 Bastion Host
  max_size                  = 2  # Maximum 2 Bastion Hosts
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.namespace}-bastion"
    propagate_at_launch = true
  }
}



	
	













