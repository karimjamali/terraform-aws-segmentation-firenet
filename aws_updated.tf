


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

data "aws_ami" "nginx_proxy" {
  most_recent = true
   tags = {"env" = "kj909192-proxy-image"}
  owners = ["830582736210"] 
}

data "aws_ami" "web_server" {
  most_recent = true
   tags = {"env" = "kj909192-web-image"}
  owners = ["830582736210"] 
}

data "aws_ami" "db_server" {
  provider = aws.west
  most_recent = true
   tags = {"env" = "kj909192-db-image"}
  owners = ["830582736210"] 
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

/*
locals {
  web_server_user_data = templatefile("${path.module}/aws_vm_config/webserver.tpl", {db_ip = aws_instance.aws-us-east-2-shared-svcs-1-vm.private_ip})
}
*/

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
/*
resource "aws_network_interface" "dev_eni" {
  subnet_id   = module.spoke_aws-us-east-1-dev-1.vpc.public_subnets[1].subnet_id
  private_ips = ["10.1.0.100"]

  tags = {
    Name = "dev_eni_primary"
  }
}

resource "aws_network_interface" "prod_eni" {
  subnet_id   = module.spoke_aws-us-east-1-dev-1.vpc.public_subnets[1].subnet_id
  private_ips = ["10.2.0.100"]

  tags = {
    Name = "prod_eni_primary"
  }
}

resource "aws_network_interface" "shared_svc_eni" {
  subnet_id   = module.spoke_aws-us-east-1-dev-1.vpc.public_subnets[1].subnet_id
  private_ips = ["10.3.0.100"]

  tags = {
    Name = "prod_eni_primary"
  }
}
*/



resource "aws_instance" "aws-us-east-1-dev-1-vm" {
  ami           = data.aws_ami.nginx_proxy.id
  instance_type = "t3.micro"
  subnet_id = module.spoke_aws-us-east-1-dev-1.vpc.public_subnets[1].subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.aws-us-east-1-dev-1-vm-sg.id]
  key_name = aws_key_pair.kp.key_name
  user_data =  templatefile("${path.module}/aws_vm_config/nginx_proxy.tpl", {web_ip = aws_instance.aws-us-east-1-prod-1-vm.private_ip})
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
  user_data =  templatefile("${path.module}/aws_vm_config/webserver.tpl", {db_ip = aws_instance.aws-us-east-2-shared-svcs-1-vm.private_ip})
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
  user_data = file("${path.module}/aws_vm_config/database.sh")
  tags = {
    Name = "aws-us-east-2-shared-svcs-1-vm"
  }
  provider = aws.west
}



