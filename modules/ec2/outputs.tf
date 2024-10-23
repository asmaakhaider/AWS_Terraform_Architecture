################################################################################
# Outputs pour EC2, Bastion Host, Load Balancer, rds
################################################################################
output "alb_dns_name" {
  value = aws_lb.my-alb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.my-autoscaling.name
}


# Output de l'instance Bastion
#output "bastion_instance_id" {
 # description = "ID de l'instance Bastion"
  #value       = aws_instance.bastion.id
#}

output "webserver_sg_id" {
  description = "Security Group ID for the webserver instances"
  value       = aws_security_group.sg-instances.id  # ou l'ID correct du Security Group
}
################################################################################
# Outputs RDS
################################################################################





