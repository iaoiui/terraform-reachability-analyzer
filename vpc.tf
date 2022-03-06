module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}c", "${local.region}d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


#  (Required) ID of the resource which is the source of the path. Can be an 
#  Instance, Internet Gateway, Network Interface, Transit Gateway, VPC Endpoint, VPC Peering Connection or VPN Gateway.

resource "aws_ec2_network_insights_path" "instance_to_igw" {
  source      = module.ec2_instance.id
  destination = data.aws_internet_gateway.this.id
  protocol    = "tcp"
}

resource "aws_ec2_network_insights_path" "instance_to_natgw" {
  source      = module.ec2_instance.id
  destination = data.aws_network_interface.nat.id
  protocol    = "tcp"
}


data "aws_internet_gateway" "this" {
  filter {
    name   = "attachment.vpc-id"
    values = [module.vpc.vpc_id]
  }
  depends_on = [
    module.vpc
  ]
}

# TODO ハードコード
data "aws_network_interface" "nat" {
  id = "eni-0f32125db61d0324d"
  depends_on = [
    module.vpc
  ]
}