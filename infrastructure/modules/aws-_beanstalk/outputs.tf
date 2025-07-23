output "beanstalk_end_point" {
  value = aws_elastic_beanstalk_environment.vprofile_app_env.endpoint_url
}