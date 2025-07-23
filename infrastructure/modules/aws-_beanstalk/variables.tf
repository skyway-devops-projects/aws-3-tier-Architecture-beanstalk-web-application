variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = string
  description = "private subnet ids"
}
variable "security_group_id" {
  type        = string
  description = "security group id"
}

variable "lb_security_group_id" {
  type        = string
  description = "security group id"
}

variable "key_name" {
  type        = string
  description = "Key Name"
}

variable "solution_stack_name" {
  type = string
  description = "solution stack_ ame"
}

variable "public_subnet_ids" {
  type = string
  description = "public subnet ids"
}

variable "certificate_arn" {
  type = string
  description = "acm certificate arn"
}


variable "bucket_id" {
  type = string
  description = "bucket id"
}

variable "bucket_key" {
  type = string
  description = "bucket key"
}