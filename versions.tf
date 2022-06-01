terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "~> 2.22.0"

    }
    
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
     tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
    
  }
  required_version = ">= 1.0"
}
