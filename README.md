# MCNS & FireNet

## Summary

This repository builds out a sample topology for a demo on Multi-Cloud Network Segmentation (MCNS) and FireNet.

It builds the following:

Aviatrix Transit with FireNet having Palo Alto Networks VM-series Firewalls.   
Another Aviatrix Transit without FireNet   
2 Spoke VPCs (Prod/Dev) attached to Aviatrix Transit with FireNet   
1 Spoke VPC (Shared Services) attached to the other Aviatrix Transit (Without Firenet)   
3 x Ubuntu VMs with Key Pairs where each Ubuntu VM lies in one spoke    
Site2Cloud connection between AWS Transit with FireNet and on-prem (emulated by CSR in AWS). For Site2Cloud you will just need to download the configuration on the CSR as the Aviatrix side is already configured  

The general objective was to showcase Multi-Cloud Network Segmentation (MCNS) and FireNet but it could be used for different purposes. 

## Component	Version:
Aviatrix Controller	UserConnect-6.7.1186   
Aviatrix Terraform Provider	= 2.22.0   
Terraform	> 1.0   
AWS Terraform Provider	= 4.16.0   

## Dependencies:
Software version requirements met     
Aviatrix Controller & Copilot (Optional) need to be up and running   
Onboarding the AWS Account is automated       
Sufficient limits in place for CSPs and regions in scope (EIPs, Compute quotas, etc.)   
Active subscriptions for the NGFW firewall images in scope   

## Usage
1. Clone the repository: [https://github.com/karimjamal](https://github.com/karimjamali/aviatrix-demo.git)
2. Update the below variable details in the variables.tf file
variable "avx_controller_ip" {
  description = "AVX Controller IP Address"
  default = ""
}

variable "avx_controller_username" {
  description = "AVX Controller username"
  default = ""
}
variable "avx_controller_password" {
  description = "AVX Controller password"
  default = ""
}

variable "aws_account_number" {
  default = ""
}

variable "aws_acess_key" {
  description = "AWS Access Key"
  default = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  default = ""
}

variable "home_ip" {
  default = ""
}


![Lab Setup - Page 8 (9)](https://user-images.githubusercontent.com/16576150/171320244-84c8af17-88f6-491f-b304-a6c58ce2413f.png)
