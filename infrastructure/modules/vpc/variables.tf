variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones"
}

# variable "common_tags" {
#   type = map(string)
#   default = {
#     "name" = "value"
#   }
# }