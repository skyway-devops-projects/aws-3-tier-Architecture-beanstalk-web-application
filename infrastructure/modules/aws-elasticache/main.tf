locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${local.name}-redis-subnet-group"
  subnet_ids = var.db_private_subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${local.name}-redis-cluster"
  engine               = var.engine
  # engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = 1
  # parameter_group_name = var.parameter_group_name
  port                 = var.port
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [var.db_security_group_id]
  tags                 = merge(local.common_tags, { Name = "${local.name}-redis-cluster" })
}