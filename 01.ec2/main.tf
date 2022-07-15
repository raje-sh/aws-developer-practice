module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami           = "ami-098e42ae54c764c35"
  instance_type = "t2.micro"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
