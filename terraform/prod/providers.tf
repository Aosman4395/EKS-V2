terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.0"
    }
  }

  backend "s3" {
    bucket       = "ahamed-eks-project-s3"
    key          = "eksV2-project/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "eu-west-2"
}