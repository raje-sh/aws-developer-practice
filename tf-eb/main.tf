terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eb-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# resource "aws_iam_role" "beanstalk_ec2" {
#     name = "beanstalk-ec2-role"
#     assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "s3.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_instance_profile" "beanstalk_ec2" {
#     name = "beanstalk-ec2-user"
#     role = aws_iam_role.beanstalk_ec2.name
# }


resource "aws_elastic_beanstalk_application" "go-app" {
  name        = "go-app"
  description = "go-app-desc"
}

resource "aws_elastic_beanstalk_environment" "go-app-dev" {
  name                = "go-app-dev"
  application         = aws_elastic_beanstalk_application.go-app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.4 running Go 1"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = element(module.vpc.public_subnets, 0)
  }
#   setting {
#       namespace = "aws:autoscaling:launchconfiguration"
#       name = "IamInstanceProfile"
#       value = aws_iam_instance_profile.beanstalk_ec2.name
#   }
}



# OUTPUTS
output "eb_endpoint" {
  value = aws_elastic_beanstalk_environment.go-app-dev.endpoint_url
}