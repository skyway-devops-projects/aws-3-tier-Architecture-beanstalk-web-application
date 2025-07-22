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

resource "aws_elastic_beanstalk_environment" "vprofile_app_env" {
  name =  "${local.name}-vprofile-app-environment"
  application = aws_elastic_beanstalk_application.vprofile_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.11 running Tomcat 8.5 Corretto 11"


  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private_subnet_ids[*].id)
  }

    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.key_name  # or hardcoded like "my-key-pair"
  }

   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = vat.security_group_id.id
  }


    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.subject_profile.name
  }


  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "Basic"
  }



   # Root volume size (in GB)
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = "20" # Example: 20 GB
  }

  # Root volume type (e.g., gp2, gp3, io1)
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp3"
  }



   ##################
  # LOAD BALANCER  #
  ##################

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = var.lb_security_group_id
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "LoadBalancerHTTPPort"
    value     = "80"
  }



  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "LoadBalancerScheme"
    value     = "internet-facing"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "InstancePort"
    value     = "80"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "InstanceProtocol"
    value     = "HTTP"
  }

  ##################
  # HEALTH CHECK   #
  ##################

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "Target"
    value     = "HTTP:80/"
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "Interval"
    value     = "30"
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "Timeout"
    value     = "5"
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "HealthyThreshold"
    value     = "3"
  }

  setting {
    namespace = "aws:elb:healthcheck"
    name      = "UnhealthyThreshold"
    value     = "5"
  }


  ####################
  # AUTOSCALING CONF #
  ####################

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "8"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Cooldown"
    value     = "300"
  }
   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  ########################
  # Auto Scaling Trigger #
  ########################

   setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "NetworkOut"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "Average"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Bytes"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Period"
    value     = "60"  # in seconds
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "EvaluationPeriods"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Threshold"
    value     = "50000000"  # 50 MB
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "BreachDuration"
    value     = "120"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "ScalingAdjustment"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "AdjustmentType"
    value     = "ChangeInCapacity"
  }

   ########################################
  # Rolling Updates and Deployment Policy
  ########################################

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "50"  # deploy to 50% of instances at a time
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "IgnoreHealthCheck"
    value     = "false"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "Timeout"
    value     = "600"
  }
  tags                   = merge(local.common_tags, { Name = "${local.name}-web-app" })
}