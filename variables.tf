#Provide the IP address or FQDN of the Aviatrix controller
variable "avx_controller_ip" {
  description = "AVX Controller IP Address"
  default = ""
}
#Provide the Aviatrix Controller username
variable "avx_controller_username" {
  description = "AVX Controller username"
  default = ""
}
#Provide the Aviatrix Controller password
variable "avx_controller_password" {
  description = "AVX Controller password"
  default = ""
}


variable "aws_region_1" {
  default = "us-east-1"
}  

variable "aws_region_2" {
  default = "us-east-2"
}  

#Provide the Home/Office Public IP that you will be accessing the setup from
variable "home_ip" {
  default = ""
}

#Provide the AWS Account Number
variable "aws_account_number" {
  default = ""
}

variable "aws_account_name" {
  default = "aws-account"
}

#Provide the EC2 Key Pair Name
variable "ec2_key_name" {
  default = "ec2-kp-us-east-1"
}

#This variable creates firenet if true
variable "firenet" {
  default = true
}

#These variables are for deploying the CSR1Kv Router
variable "cloud_type" {
  description = "Which CSP to deploy the CSR1Kv in"
  type        = string
  default     = "aws"
}
variable "aws_region" {
  description = "AWS Region in which to deploy the CSR 1KV"
  type        = string
  default     = "us-east-1"
}


variable "hostname" {
  description = "CSR hostname"
  type        = string
  default     = "onprem-csr"
}
variable "tunnel_proto" {
  type    = string
  default = "IPsec"
}
variable "prioritize" {
  description = "Possible values: price, performance. Instance ami adjusted depending on this"
  type        = string
  default     = "price"
}
variable "network_cidr" {
  description = "Virtual Network CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnets" {
  description = "Public Subnet CIDR"
  type        = list(string)
  default     = ["172.16.0.0/24"]
}
variable "public_subnet_ids" {
  description = "Use existing CSR Public subnet ids"
  type        = list(string)
  default     = null
}
variable "private_subnets" {
  description = "Public Subnet CIDR"
  type        = list(string)
  default     = ["172.16.1.0/24"]
}
variable "private_subnet_ids" {
  description = "Use existing CSR Private subnet ids"
  type        = list(string)
  default     = null
}
variable "aws_instance_type" {
  description = "AWS CSR Instance type"
  type        = string
  default     = "t3.medium"
}

variable "public_conns" {
  description = "List of public External Conns"
  type        = list(string)
  default     = []
}
variable "private_conns" {
  description = "List of private External Conns"
  type        = list(string)
  default     = []
}
variable "csr_bgp_as_num" {
  description = "CSR BGP AS Number"
  type        = string
  default     = "64528"
}
variable "create_client" {
  description = "Create Test Client"
  type        = bool
  default     = false
}
variable "advertised_prefixes" {
  type        = list(string)
  description = "List of custom advertised prefixes to send over BGP to Transits"
  default     = []
}
variable "az1" {
  type        = string
  description = "Primary AZ"
  default     = "a"
}
variable "az2" {
  type        = string
  description = "Secondary AZ"
  default     = "b"
}