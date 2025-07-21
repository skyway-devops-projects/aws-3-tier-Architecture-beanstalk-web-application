locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = var.db_private_subnet_ids
  tags       = merge(local.common_tags, { Name = "${local.name}-db-subnet-group" })
}

resource "aws_db_instance" "rds_db_instance" {
  identifier             = "${local.name}-rds-mysql"
  allocated_storage      = 20
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  vpc_security_group_ids = [var.db_security_group_id]
  tags                   = merge(local.common_tags, { Name = "${local.name}-rds-db-instance" })
}