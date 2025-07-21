output "db_endpoint" {
  value = aws_db_instance.rds_db_instance.endpoint
}

output "db_identifier" {
  value = aws_db_instance.rds_db_instance.id
}