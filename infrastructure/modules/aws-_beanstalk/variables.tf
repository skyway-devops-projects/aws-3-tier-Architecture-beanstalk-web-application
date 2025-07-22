variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "private subnet ids"
}
variable "security_group_id" {
  type = string
  description = "security group id"
}

variable "lb_security_group_id" {
  type = string
  description = "security group id"
}

variable "key_name" {
  type = string
  description = "Key Name"
}