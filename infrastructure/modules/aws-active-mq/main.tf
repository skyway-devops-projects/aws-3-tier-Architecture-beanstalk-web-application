locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
}

resource "aws_mq_broker" "activemq" {
  broker_name         = "${local.name}-activemq-broker"
  engine_type         = "ActiveMQ"
  engine_version      = "5.18"
  host_instance_type  = "mq.t3.micro"
  deployment_mode     = "SINGLE_INSTANCE"
  publicly_accessible = false
  user {
    username = var.username
    password = var.password # Store in SSM in production
  }
  subnet_ids      = var.private_subnet_ids
  security_groups = [var.security_group_id]

  logs {
    general = true
  }
  tags = merge(local.common_tags, { Name = "${local.name}-activemq" })
}