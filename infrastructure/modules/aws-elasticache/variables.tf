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
  description = "Database  private subnetids"
}


variable "db_security_group_id" {
  type        = string
  description = "database security group id"
}

variable "engine" {
  type        = string
  description = "Redis Engine"
}

variable "engine_version" {
  type        = string
  description = "Redis Engine Version"
}

variable "node_type" {
  type        = string
  description = "Node Type"
}

variable "parameter_group_name" {
  type        = string
  description = "Parameter Group Name"
}

variable "port" {
  type        = string
  description = "redis port"
}