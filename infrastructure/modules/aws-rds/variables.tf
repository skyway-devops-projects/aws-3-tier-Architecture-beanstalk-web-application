variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "db_private_subnet_ids" {
  type        = list(string)
  description = "Database rds private subnetids"
}

variable "db_security_group_id" {
  type        = string
  description = "database security group id"
}

variable "engine" {
  type        = string
  description = "RDS Engine"
}

variable "engine_version" {
  type        = string
  description = "RDS Engine Version"
}

variable "instance_class" {
  type        = string
  description = "Instance Class"
}

variable "db_name" {
  type        = string
  description = "database name"
}

variable "username" {
  type        = string
  description = "database username"
}

variable "password" {
  type        = string
  description = "database password"
  sensitive   = true
}

