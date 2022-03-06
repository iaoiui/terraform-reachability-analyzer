
# ami-0756e018e393c1323	Cloud9AmazonLinux2-2022-02-17T10-52	amazon/Cloud9AmazonLinux2-2022-02-17T10-52
#  Cloud9 Amazon Linux AMI

data aws_ssm_parameter amzn2_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}


# outboundの0.0.0.0/0 sg
resource "aws_security_group_rule" "outbound_all_ec2" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.web_server_sg.security_group_id
}



resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# ec2_instance in private subnet
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name  = "my-instance"

  ami                    = data.aws_ssm_parameter.amzn2_ami.value
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2-key.key_name
  vpc_security_group_ids = [module.web_server_sg.security_group_id]

  subnet_id              = module.vpc.private_subnets[0]

  iam_instance_profile = aws_iam_instance_profile.ssm.id

  user_data = <<-EOF
    yum install docker -y
    systemctl enable docker
    systemctl start docker
    docker run -d --rm --name web-test -p 80:8000 crccheck/hello-world
  EOF

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}




resource "aws_iam_instance_profile" "ssm" {
  name = "ssm"
  role = aws_iam_role.ssm.name
}

resource "aws_iam_role" "ssm" {
  name = "ssm"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
# AWSCloud9SSMInstanceProfileつける or Cloud9用のRoleつけるといけた
resource "aws_iam_policy_attachment" "ssm_attachment" {
  name       = "ssm_attachment"
  roles      = [aws_iam_role.ssm.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
