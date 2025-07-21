variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Database  private subnetids"
}


variable "security_group_id" {
  type        = string
  description = "active mq security group id"
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