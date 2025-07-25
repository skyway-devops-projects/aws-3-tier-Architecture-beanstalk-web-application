locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = "${var.environment}"
    CreatedBy   = "Terraform"
  }
}
data "aws_acm_certificate" "existing_cert" {
  domain   = var.root_domain_name
  statuses = ["ISSUED"]
  most_recent = true
}

resource "aws_s3_object" "upload_file" {
  bucket = var.bucket_artifact_storage
  key    = "artifact/vprofile-v2.war"
  source = "../target/vprofile-v2.war" # Path to local file
}

data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_artifact_storage
}


module "vpc" {
  source          = "./modules/vpc"
  environment     = var.environment
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  azs             = var.availability_zones
}

module "security" {
  source       = "./modules/security"
  environment  = var.environment
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "rds_mysq" {
  source                = "./modules/aws-rds"
  environment           = var.environment
  project_name          = var.project_name
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  db_name               = var.db_name
  username              = var.username
  password              = var.password
  db_private_subnet_ids = module.vpc.private_subnet_ids
  db_security_group_id  = module.security.db_security_group_id
  depends_on            = [module.vpc]
}



module "elasticache_radis" {
  source                = "./modules/aws-elasticache"
  environment           = var.environment
  project_name          = var.project_name
  engine                = var.memcached_engine
  engine_version        = var.memcached_engine_version
  node_type             = var.memcached_node_type
  port                  = var.memcached_port
  db_private_subnet_ids = module.vpc.private_subnet_ids
  db_security_group_id  = module.security.db_security_group_id
  # parameter_group_name  = var.redis_parameter_group_name
  depends_on = [module.vpc]
}

module "activemq" {
  source            = "./modules/aws-active-mq"
  environment       = var.environment
  project_name      = var.project_name
  security_group_id = module.security.db_security_group_id
  private_subnet_id = element(module.vpc.private_subnet_ids, 0)
  username          = var.active_mq_username
  password          = var.active_mq_password
  depends_on        = [module.vpc]
}

module "beanstalk" {
  source               = "./modules/aws-_beanstalk"
  environment          = var.environment
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  lb_security_group_id = module.security.alb_security_group_id
  security_group_id    = module.security.app_security_group_id
  key_name             = var.key_name
  private_subnet_ids   = join(",", module.vpc.private_subnet_ids)
  public_subnet_ids    = join(",", module.vpc.public_subnet_ids)
  solution_stack_name = "64bit Amazon Linux 2023 v5.7.1 running Tomcat 9 Corretto 11"
  certificate_arn = data.aws_acm_certificate.existing_cert.arn
  bucket_id = data.aws_s3_bucket.existing_bucket.id
  bucket_key = "artifact/vprofile-v2.war"
}

resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ami.amzn_linux_2023_latest.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security.bastion_security_group_id]
  subnet_id              = element(module.vpc.public_subnet_ids, 0)
  key_name               = var.key_name
  user_data              = templatefile("${path.module}/scripts/install-mysql-client.sh", {})
  # iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  tags = merge(local.common_tags, { Name = "${local.name}-baston-host" })
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/private_key/vprofile-dev.pem")
      host        = self.public_ip
    }
    source      = "${path.module}/private_key/vprofile-dev.pem"
    destination = "/home/ec2-user/vprofile-dev.pem"
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/private_key/vprofile-dev.pem")
      host        = self.public_ip
    }
    source      = "${path.module}/scripts/db_backup.sql"
    destination = "/home/ec2-user/db_backup.sql"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/private_key/vprofile-dev.pem")
      host        = self.public_ip
    }
    inline = [
      "chmod 400 /home/ec2-user/vprofile-dev.pem",

    ]
  }
  depends_on = [module.vpc]
}

data "aws_route53_zone" "selected_zone" {
  name         =var.root_domain_name
  private_zone = false
}
resource "aws_route53_record" "beanstalk_alias" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "vprofile.${var.root_domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [module.beanstalk.beanstalk_end_point]
}
