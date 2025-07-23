locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "${local.name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name}-bastion-sg" })
}

resource "aws_security_group" "alb_sg" {
  name        = "${local.name}-elb-sg"
  vpc_id      = var.vpc_id
  description = "Security group for application load balancer"
  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    to_port     = 443
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name}-alb-sg" })
}

resource "aws_security_group" "app_sg" {
  name        = "${local.name}-app-sg"
  vpc_id      = var.vpc_id
  description = "Security group for application servers"
  ingress {
    description     = "Allow 8080 from application loadbalancer"
    to_port         = 8080
    from_port       = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    description     = "Allow 22 from bastion"
    to_port         = 22
    from_port       = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.name}-app-sg" })
}




resource "aws_security_group" "backend_sg" {
  name        = "${local.name}-backend-sg"
  description = "Security group for application backend services"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow 22 from bastion"
    to_port         = 22
    from_port       = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Allow DB access from bastion host"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

   ingress {
    description     = "Allow 11211 from application servers"
    to_port         = 11211
    from_port       = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description     = "Allow 5672 from application servers"
    to_port         = 5671
    from_port       = 5671
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    description = "Allow Internal traffic to flow on all ports"
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(local.common_tags, { Name = "${local.name}-backend-sg" })
}


