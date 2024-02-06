module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = local.vpc_name
  cidr = "10.40.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.40.1.0/24", "10.40.2.0/24", "10.40.3.0/24"]
  public_subnets  = ["10.40.101.0/24", "10.40.102.0/24", "10.40.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name = local.vpc_name
  }
}