resource "aviatrix_account" "aws-account" {
  account_name       = var.aws_account_name
  cloud_type         = 1
  aws_account_number = var.aws_account_number
  aws_iam            = true
  aws_role_app       = "arn:aws:iam::${var.aws_account_number}:role/aviatrix-role-app"
  aws_role_ec2       = "arn:aws:iam::${var.aws_account_number}:role/aviatrix-role-ec2"
}


module "mc_transit_aws-us-east-1-transit-1" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  
  
  cloud                  = "AWS"
  cidr                   = "10.100.0.0/16"
  region                 = "us-east-1"
  account                = aviatrix_account.aws-account.account_name
  enable_transit_firenet = true
  insane_mode = true
  enable_segmentation = true
}

module "firenet_1" {
  count = var.firenet ? 1 : 0
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"

  transit_module = module.mc_transit_aws-us-east-1-transit-1
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
}




module "spoke_aws-us-east-1-dev-1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  

  cloud           = "AWS"
  name            = "aws-us-east-1-dev-1"
  cidr            = "10.1.0.0/16"
  region          = "us-east-1"
  account         = aviatrix_account.aws-account.account_name
  transit_gw      = module.mc_transit_aws-us-east-1-transit-1.transit_gateway.gw_name
  ha_gw = false
}

module "spoke_aws-us-east-1-prod-1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  

  cloud           = "AWS"
  name            = "aws-us-east-1-prod-1"
  cidr            = "10.2.0.0/16"
  region          = "us-east-1"
  account         = aviatrix_account.aws-account.account_name
  transit_gw      = module.mc_transit_aws-us-east-1-transit-1.transit_gateway.gw_name
  
}

module "spoke_aws-us-east-1-user-vpn" {
  count = var.uservpn ? 1 : 0
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  
  cloud           = "AWS"
  name            = "aws-us-east-1-user-vpn"
  cidr            = "10.110.0.0/16"
  region          = "us-east-1"
  account         = aviatrix_account.aws-account.account_name
  transit_gw      = module.mc_transit_aws-us-east-1-transit-1.transit_gateway.gw_name
  
}



module "mc_transit_aws-us-east-2-transit-1" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  
  
  cloud                  = "AWS"
  cidr                   = "10.120.0.0/16"
  region                 = "us-east-2"
  account                = aviatrix_account.aws-account.account_name
  enable_transit_firenet = true
  insane_mode = true
  enable_segmentation = true

}

module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  

  transit_gateways = [
    module.mc_transit_aws-us-east-1-transit-1.transit_gateway.id,
    module.mc_transit_aws-us-east-2-transit-1.transit_gateway.id
    
  ]
}

module "spoke_aws-us-east-2-shared-svcs" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  

  cloud           = "AWS"
  name            = "aws-us-east-2-shared-svcs"
  cidr            = "10.3.0.0/16"
  region          = "us-east-2"
  account         = aviatrix_account.aws-account.account_name
  transit_gw      = module.mc_transit_aws-us-east-2-transit-1.transit_gateway.gw_name
  ha_gw = false
}
module "avx-demo-onprem-aws" {
  count               = var.cloud_type == "aws" ? 1 : 0
  source              = "github.com/gleyfer/aviatrix-demo-onprem-aws"
  hostname            = var.hostname
  tunnel_proto        = var.tunnel_proto
  network_cidr        = var.network_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  public_subnet_ids   = var.public_subnet_ids
  private_subnet_ids  = var.private_subnet_ids
  instance_type       = var.aws_instance_type
  public_conns        = ["${module.mc_transit_aws-us-east-1-transit-1.transit_gateway.gw_name}:65001:1"]
  private_conns       = var.private_conns
  csr_bgp_as_num      = var.csr_bgp_as_num
  create_client       = var.create_client
  advertised_prefixes = var.advertised_prefixes
  az1                 = var.az1
  az2                 = var.az2
}




   
