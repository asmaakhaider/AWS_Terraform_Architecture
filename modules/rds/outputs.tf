# Récupérer l'endpoint de l'instance RDS
output "rds_endpoint" {
  value = aws_db_instance.wordpressdb.endpoint
}
