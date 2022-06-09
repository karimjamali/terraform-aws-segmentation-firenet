


resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "ec2-ue1-key"      
  public_key = tls_private_key.pk.public_key_openssh


provisioner "local-exec" { 
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./ec2-ue1-key.pem"
  }

}


resource "tls_private_key" "pk2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp2" {
  key_name   = "ec2-ue2-key"       
  public_key = tls_private_key.pk2.public_key_openssh
  provider = aws.west

provisioner "local-exec" { 
    command = "echo '${tls_private_key.pk2.private_key_pem}' > ./ec2-ue2-key.pem"
  }

}





data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

data "aws_ami" "ubuntu2" {
  most_recent = true
  provider = aws.west
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
  
}


resource "aws_security_group_rule" "ingress_ssh_rule" {
  for_each = local.security_groups

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.home_ip]
  security_group_id = each.value["name"]
}
resource "aws_security_group_rule" "incoming_https_rule" {
  for_each = local.security_groups

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.home_ip]
  security_group_id = each.value["name"]
}

resource "aws_security_group_rule" "incoming_http_rule" {
  for_each = local.security_groups
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.home_ip]
  security_group_id = each.value["name"]
}

resource "aws_security_group_rule" "incoming_traffic_from_10_cidr" {
  for_each = local.security_groups
  type              = "ingress"
  from_port         = 0 
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = each.value["name"]
}

resource "aws_security_group_rule" "allow_from_same_sg" {
  for_each = local.security_groups
  type              = "ingress"
  from_port         = 0 
  to_port           = 65535
  protocol          = "-1"
  source_security_group_id       = each.value["name"]
  security_group_id = each.value["name"]
}

resource "aws_security_group_rule" "outgoing_allow_all" {
  for_each = local.security_groups
  type              = "egress"
  from_port         = 0 
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = each.value["name"]
}





locals { 
  security_groups = {
    "dev" = {
      "name" = aws_security_group.aws-us-east-1-dev-1-vm-sg.id
    },
    "prod" = {
      "name" = aws_security_group.aws-us-east-1-prod-1-vm-sg.id
    },
   
}
}


resource "aws_security_group_rule" "ingress_ssh_rule2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.home_ip]
  security_group_id = aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id
  provider = aws.west
}
resource "aws_security_group_rule" "incoming_https_rule2" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.home_ip]
  security_group_id = aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id
  provider = aws.west
}

resource "aws_security_group_rule" "incoming_http_rule2" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.home_ip]
  security_group_id = aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id
  provider = aws.west
}

resource "aws_security_group_rule" "incoming_traffic_from_10_cidr2" {
  type              = "ingress"
  from_port         = 0 
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8","172.16.0.0/16"]
  security_group_id = aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id
  provider = aws.west
}

resource "aws_security_group_rule" "allow_from_same_sg2" {
  type              = "ingress"
  from_port         = 0 
  to_port           = 65535
  protocol          = "-1"
  source_security_group_id       = aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id
  security_group_id = aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id
  provider = aws.west
}

resource "aws_security_group_rule" "outgoing_allow_all2" {
  type              = "egress"
  from_port         = 0 
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id
  
  provider = aws.west
}










resource "aws_security_group" "aws-us-east-1-dev-1-vm-sg" {
  name        = "dev-instance-sg"
  description = "security group for instance in dev VPC"
  vpc_id      = module.spoke_aws-us-east-1-dev-1.vpc.vpc_id
  tags = {
    Name = "aws-us-east-1-dev-1-vm-sg"
  }
}

resource "aws_security_group" "aws-us-east-1-prod-1-vm-sg" {
  name        = "prod-instance-sg"
  description = "security group for instance in prod VPC"
  vpc_id      = module.spoke_aws-us-east-1-prod-1.vpc.vpc_id
  tags = {
    Name = "aws-us-east-1-prod-1-vm-sg"
  }
}

resource "aws_security_group" "aws-us-east-2-shared-svcs-vm-sg" {
  name        = "shared-svcs-vm-sg"
  description = "security group for instance in shared VPC"
  vpc_id      = module.spoke_aws-us-east-2-shared-svcs.vpc.vpc_id
  tags = {
    Name = "aws-us-east-2-shared-svcs-vm-sg"
  }
    provider = aws.west

}


resource "aws_instance" "aws-us-east-1-dev-1-vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = module.spoke_aws-us-east-1-dev-1.vpc.public_subnets[1].subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.aws-us-east-1-dev-1-vm-sg.id]
  key_name = aws_key_pair.kp.key_name
  user_data = file("${path.module}/aws_vm_config/aws_bootstrap.sh")
  tags = {
    Name = "aws-us-east-1-dev-1-vm"
  }
}

resource "aws_instance" "aws-us-east-1-prod-1-vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = module.spoke_aws-us-east-1-prod-1.vpc.public_subnets[1].subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.aws-us-east-1-prod-1-vm-sg.id]
  key_name = aws_key_pair.kp.key_name
  user_data = file("${path.module}/aws_vm_config/aws_bootstrap.sh")
  tags = {
    Name = "aws-us-east-1-prod-1-vm"
  }
}

resource "aws_instance" "aws-us-east-2-shared-svcs-1-vm" {
  ami           = data.aws_ami.ubuntu2.id
  instance_type = "t3.micro"
  subnet_id = module.spoke_aws-us-east-2-shared-svcs.vpc.public_subnets[1].subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.aws-us-east-2-shared-svcs-vm-sg.id]
  key_name = aws_key_pair.kp2.key_name
  user_data = file("${path.module}/aws_vm_config/aws_bootstrap.sh")
  tags = {
    Name = "aws-us-east-2-shared-svcs-1-vm"
  }
  provider = aws.west
}

resource "aws_route53_zone" "private" {
  name = "avx-labs.com"

  vpc {
    vpc_id = module.spoke_aws-us-east-1-prod-1.vpc.vpc_id
    
}
lifecycle {
    ignore_changes = [vpc]
  }
  }


resource "aws_route53_zone_association" "dev" {
  zone_id = aws_route53_zone.private.zone_id
  vpc_id  = module.spoke_aws-us-east-1-dev-1.vpc.vpc_id
}

resource "aws_route53_zone_association" "shared" {
  zone_id = aws_route53_zone.private.zone_id
  vpc_id  = module.spoke_aws-us-east-2-shared-svcs.vpc.vpc_id
  vpc_region = "us-east-2"
}

resource "aws_route53_record" "prod" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "prod.avx-labs.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.aws-us-east-1-prod-1-vm.private_ip]
}

resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "dev.avx-labs.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.aws-us-east-1-dev-1-vm.private_ip]
}

resource "aws_route53_record" "shared" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "shared.avx-labs.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.aws-us-east-2-shared-svcs-1-vm.private_ip]
}
