locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
}

resource "aws_elastic_beanstalk_application" "vprofile_app" {
  name        = "${local.name}-web-app"
  description = "Vprofile Java application"
}

resource "aws_iam_role" "role" {
  name = "${local.name}-web-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
      }
    ]
  })
}

resource "aws_iam_instance_profile" "subject_profile" {
  name = "${local.name}-web-app-role"
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
    for_each = toset([
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
  ])
  role = aws_iam_role.role.name
  policy_arn = each.value
}

resource "aws_elastic_beanstalk_environment" "name" {
  
}