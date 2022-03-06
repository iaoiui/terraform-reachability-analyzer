
# Create security group for alb
module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "alb"
  description = "Security group for alb"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}


# create Application load balancer  (ALB) with ec2 target groups using vpc module
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "my-alb"

  subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  security_groups = [module.alb_sg.security_group_id]

  vpc_id = module.vpc.vpc_id

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = module.ec2_instance.id
          port = 80
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "outbound_all_alb" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb_sg.security_group_id
}

output "alb_dns" {
  value = module.alb.lb_dns_name
}