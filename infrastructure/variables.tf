variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "iam_user_name" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "table_name" {
  type = string
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}



variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
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

variable "redis_engine" {
  type        = string
  description = "Redis Engine"
}

variable "redis_engine_version" {
  type        = string
  description = "Redis Engine Version"
}

variable "redis_node_type" {
  type        = string
  description = "Node Type"
}

variable "redis_parameter_group_name" {
  type        = string
  description = "Parameter Group Name"
}

variable "redis_port" {
  type        = string
  description = "redis port"
}

variable "active_mq_username" {
  type        = string
  description = "database username"
}

variable "active_mq_password" {
  type        = string
  description = "database password"
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# variable "record" {
#   description =  "Records Ip"
#   type = list(string)
# }