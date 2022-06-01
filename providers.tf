# Configure Aviatrix provider source and version
terraform {
  required_providers {
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
      
    }
  }
}

provider "aviatrix" {
  controller_ip           = var.avx_controller_ip
  username                = var.avx_controller_username
  password                = var.avx_controller_password
  skip_version_validation = true 
}


#You need to input your access and secret key and decide on which region
provider "aws" {
  region = var.aws_region_1
  access_key = ""
  secret_key = ""
  
}
#You need to input your access and secret key and decide on which region
provider "aws" {
  alias  = "west"
  region = var.aws_region_2
  access_key = ""
  secret_key = ""
  
}

